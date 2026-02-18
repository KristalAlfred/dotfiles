---
name: hooks
description: >
  Claude Code hooks reference for writing, debugging, and configuring hooks.
  Use when creating hooks, adding lifecycle automation, writing hook scripts,
  or troubleshooting hook issues. Covers all 14 hook events, configuration
  locations, matchers, decision control, and monitoring via OpenTelemetry.
---

# Claude Code Hooks

Hooks are user-defined shell commands or LLM prompts that execute at specific
points in Claude Code's lifecycle. They provide **deterministic** control,
ensuring actions always happen rather than relying on the LLM.

For full details see REFERENCE.md in this directory.

## Quick Start

Use `/hooks` interactively in Claude Code to create hooks, or add them to a
settings file manually.

## Hook Types

| Type | Description |
|---|---|
| `command` | Runs a shell command. JSON on stdin, exit codes + stdout/stderr out |
| `prompt` | Single-turn LLM evaluation. Returns `{ "ok": bool, "reason": "..." }` |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob). Same response format |

## All 14 Hook Events

| Event | Fires when | Can block? |
|---|---|---|
| `SessionStart` | Session begins/resumes | No |
| `UserPromptSubmit` | User submits prompt, before processing | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `Stop` | Claude finishes responding | Yes |
| `TeammateIdle` | Agent team teammate about to idle | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `PreCompact` | Before context compaction | No |
| `SessionEnd` | Session terminates | No |

## Configuration Locations

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Org-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent YAML frontmatter | Component lifetime | Yes |

## Configuration Shape

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex>",  // optional, filters when hook fires
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "timeout": 600,        // seconds, default varies by type
            "async": false,        // true = background, non-blocking
            "statusMessage": "Running checks..."  // spinner text
          }
        ]
      }
    ]
  }
}
```

## Data Flow

### Input (stdin JSON)

All events get common fields:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/project/root",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse"
}
```

Plus event-specific fields (e.g. `tool_name`, `tool_input` for tool events,
`prompt` for UserPromptSubmit, `source` for SessionStart).

### Output (exit codes)

- **Exit 0**: proceed. Stdout parsed for JSON. For `UserPromptSubmit` and
  `SessionStart`, stdout is added as context for Claude.
- **Exit 2**: block the action. Stderr fed back as error/feedback.
- **Other**: non-blocking error, stderr shown in verbose mode only.

### JSON Output (on exit 0)

```json
{
  "continue": true,          // false = stop Claude entirely
  "stopReason": "...",       // shown to user when continue=false
  "suppressOutput": false,   // hide stdout from verbose mode
  "systemMessage": "..."     // warning shown to user
}
```

## Decision Control by Event

| Events | Pattern | Key fields |
|---|---|---|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code only | Exit 2 blocks, stderr = feedback |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |

## Matcher Reference

| Event | Matches on | Examples |
|---|---|---|
| PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| SessionStart | how session started | `startup`, `resume`, `clear`, `compact` |
| SessionEnd | why session ended | `clear`, `logout`, `prompt_input_exit` |
| Notification | notification type | `permission_prompt`, `idle_prompt` |
| SubagentStart, SubagentStop | agent type | `Bash`, `Explore`, `Plan` |
| PreCompact | compaction trigger | `manual`, `auto` |
| UserPromptSubmit, Stop, TeammateIdle, TaskCompleted | no matcher | always fires |

## Common Recipes

### Desktop notification on idle

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'"
      }]
    }]
  }
}
```

### Auto-format after edits

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

### Block dangerous commands

```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  echo "Blocked: destructive command" >&2
  exit 2
fi
exit 0
```

### Re-inject context after compaction

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "compact",
      "hooks": [{
        "type": "command",
        "command": "echo 'Reminder: use bun not npm. Run tests before committing.'"
      }]
    }]
  }
}
```

### Prompt-based Stop gate

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "Check if all tasks are complete. Respond {\"ok\": false, \"reason\": \"what remains\"} if not."
      }]
    }]
  }
}
```

## Environment Variables

- `$CLAUDE_PROJECT_DIR` — project root (use in command paths)
- `${CLAUDE_PLUGIN_ROOT}` — plugin root directory
- `$CLAUDE_CODE_REMOTE` — `"true"` in remote web environments
- `$CLAUDE_ENV_FILE` — SessionStart only: write `export` statements here
  to persist env vars for all subsequent Bash commands in the session

## Debugging

- `/hooks` — interactive menu to view/add/delete hooks
- `claude --debug` — full execution details
- `Ctrl+O` — toggle verbose mode to see hook output in transcript
- Hooks snapshot at startup; external edits require review in `/hooks`

## Gotchas

- Shell profile `echo` statements break JSON parsing — wrap in `[[ $- == *i* ]]`
- Stop hooks can loop forever — check `stop_hook_active` and exit 0 if true
- PermissionRequest hooks don't fire in non-interactive mode (`-p`)
- PostToolUse can't undo actions (tool already ran)
- Hooks timeout at 10 min by default (configurable via `timeout` field)
