#!/usr/bin/env nu

const BAR_WIDTH = 40
const GENERIC_AGENTS = ["Explore", "general-purpose", "Plan", "claude-code-guide"]

def load-logs [days: int]: nothing -> list {
  let log_dir = ($env.HOME | path join ".claude" "usage-logs")

  if not ($log_dir | path exists) {
    print "No usage logs found yet."
    return []
  }

  let files = (glob ($log_dir | path join "*.jsonl"))

  if ($files | is-empty) {
    print "No usage logs found yet."
    return []
  }

  let cutoff = (date now) - ($days | into duration --unit day)

  let logs = ($files
    | each { ls $in | get 0 }
    | where modified >= $cutoff
    | get name
    | each { open --raw $in | lines }
    | flatten
    | where ($it | str length) > 0
    | each { $in | from json })

  if ($logs | is-empty) {
    print $"No agent usage in the last ($days) days."
    return []
  }

  $logs
}

def render-bar [count: int, max_count: int]: nothing -> string {
  let filled = if $max_count > 0 { [($count * $BAR_WIDTH / $max_count), 1] | math max } else { 0 }
  let empty = $BAR_WIDTH - $filled
  let filled_str = if $filled > 0 { 1..$filled | each { '█' } | str join } else { "" }
  let empty_str = if $empty > 0 { 1..$empty | each { '░' } | str join } else { "" }
  $"($filled_str)($empty_str)"
}

def render-chart [rows: list]: nothing -> nothing {
  if ($rows | is-empty) { return }

  let max_count = ($rows | get count | math max)
  let max_label = ($rows | get label | str length | math max)

  $rows | each {|row|
    let padded = ($row.label | fill -a l -w $max_label)
    let bar = (render-bar $row.count $max_count)
    let count_str = ($row.count | into string | fill -a r -w 4)
    print $"  ($padded)  ($bar)  ($count_str)"
  }
  null
}

def show-bar-chart [logs: list]: nothing -> nothing {
  let rows = ($logs
    | group-by agent_type
    | items {|agent, entries| { label: $agent, count: ($entries | length) } }
    | sort-by count -r)

  render-chart $rows
}

def show-bar-chart-by-project [logs: list]: nothing -> nothing {
  $logs | group-by project | items {|project, rows|
    print $"\n($project)"
    let chart_rows = ($rows
      | group-by agent_type
      | items {|agent, entries| { label: $agent, count: ($entries | length) } }
      | sort-by count -r)
    render-chart $chart_rows
  }
  null
}

def show-topics [logs: list]: nothing -> nothing {
  let grouped = ($logs
    | group-by agent_type
    | items {|agent, entries|
      let count = ($entries | length)
      let desc_groups = ($entries
        | get description
        | uniq --count
        | sort-by count -r
        | first 10)
      { agent: $agent, count: $count, descriptions: $desc_groups }
    }
    | sort-by count -r)

  for group in $grouped {
    print $"\n($group.agent) \(($group.count) invocations\)"
    for desc in $group.descriptions {
      let suffix = if $desc.count > 1 { $" \(($desc.count)x\)" } else { "" }
      print $"  ($desc.value)($suffix)"
    }
  }
}

def run-analyze [logs: list]: nothing -> nothing {
  print "Analyzing usage patterns...\n"

  let shards = ($logs
    | group-by agent_type
    | items {|agent, entries| { agent: $agent, entries: $entries } })

  let shard_summaries = ($shards | par-each {|shard|
    let data = ($shard.entries | select description prompt_preview | to json)
    let prompt = $"Summarize the task patterns in these ($shard.entries | length) invocations of the '($shard.agent)' agent.
List the top task categories, note any misrouted tasks \(tasks that would fit a different agent better\), and identify trends.
Be concise — bullet points preferred.

Data:
($data)"

    let summary = (do { try { hide-env CLAUDE_CODE }; claude -p --model sonnet $prompt } | complete | get stdout)
    { agent: $shard.agent, summary: $summary }
  })

  let combined = ($shard_summaries | each {|s| $"## ($s.agent)\n($s.summary)" } | str join "\n\n")

  let final_prompt = $"Given these per-agent usage summaries, provide an overall analysis:
- Cross-agent patterns and workflow shapes
- Misrouting suggestions \(tasks that belong in a different agent\)
- Usage balance insights
- Actionable recommendations

($combined)"

  let final = (do { $env.CLAUDE_CODE = null; claude -p --model sonnet $final_prompt } | complete | get stdout)
  print $final
}

def show-gaps [logs: list, analyze: bool]: nothing -> nothing {
  let generic_logs = ($logs | where agent_type in $GENERIC_AGENTS)

  if ($generic_logs | is-empty) {
    print "No invocations to generic agents found."
    return
  }

  let total = ($generic_logs | length)
  print $"($total) invocations went to generic agents. Recurring patterns:\n"

  let patterns = ($generic_logs
    | select description agent_type
    | uniq --count
    | sort-by count -r
    | where count >= 2
    | first 15)

  if ($patterns | is-empty) {
    print "  No recurring patterns found (all unique descriptions)."
  } else {
    let max_desc = ($patterns | each { $in.value.description | str length } | math max)
    for row in $patterns {
      let desc = ($row.value.description | fill -a l -w $max_desc)
      print $"  ($desc)  → ($row.value.agent_type) \(($row.count)x\)"
    }
  }

  if not $analyze {
    print $"\nRun with --gaps --analyze for AI-powered suggestions."
    return
  }

  print "\nAnalyzing gaps...\n"

  let shards = ($generic_logs
    | group-by agent_type
    | items {|agent, entries| { agent: $agent, entries: $entries } })

  let shard_summaries = ($shards | par-each {|shard|
    let data = ($shard.entries | select description prompt_preview | to json)
    let prompt = $"These are ($shard.entries | length) tasks routed to the generic '($shard.agent)' agent.
Identify recurring task themes that suggest a dedicated custom agent would help.
For each theme, suggest a concrete agent name, role description, and what tools it would need.
Be concise.

Data:
($data)"

    let summary = (do { try { hide-env CLAUDE_CODE }; claude -p --model sonnet $prompt } | complete | get stdout)
    { agent: $shard.agent, summary: $summary }
  })

  let combined = ($shard_summaries | each {|s| $"## ($s.agent)\n($s.summary)" } | str join "\n\n")

  let final_prompt = $"Given these analyses of generic agent usage, synthesize concrete recommendations for new custom agents.
For each suggested agent, provide:
- Agent name and one-line role
- What recurring tasks it would handle
- Estimated invocations it would absorb from the data
Format as a prioritized list.

($combined)"

  let final = (do { $env.CLAUDE_CODE = null; claude -p --model sonnet $final_prompt } | complete | get stdout)
  print $final
}

def main [
  --days: int = 7    # Number of days to look back
  --by-project       # Break down by project
  --detail           # Show full table with all fields
  --topics           # Task descriptions per agent type
  --analyze          # LLM-powered semantic analysis
  --gaps             # Identify missing agent patterns
] {
  let logs = (load-logs $days)

  if ($logs | is-empty) { return }

  if $detail {
    $logs | select ts session_id agent_type description prompt_preview model project
  } else if $topics {
    show-topics $logs
  } else if $gaps {
    show-gaps $logs $analyze
  } else if $analyze {
    run-analyze $logs
  } else if $by_project {
    show-bar-chart-by-project $logs
  } else {
    show-bar-chart $logs
  }
}
