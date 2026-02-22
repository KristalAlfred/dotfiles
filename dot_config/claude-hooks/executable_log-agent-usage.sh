#!/bin/bash
LOG_DIR="$HOME/.claude/usage-logs"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

LOG_FILE="$LOG_DIR/$(date -u +%Y-%m-%d).jsonl"

echo "$INPUT" | jq -c '{
  ts: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  session_id: .session_id,
  agent_type: .tool_input.subagent_type,
  mode: ((.tool_input.prompt | capture("(?is)mode:\\s*(?<m>Research|Decide|Act)")?.m) // null),
  contexts: ((.tool_input.prompt | capture("(?is)contexts:\\s*(?<c>[^\\n\\r]+)")?.c) // null),
  description: .tool_input.description,
  prompt_preview: (.tool_input.prompt[:200]),
  prompt_full: .tool_input.prompt,
  model: .tool_input.model,
  project: (.cwd | split("/") | last)
}' >> "$LOG_FILE" 2>/dev/null
