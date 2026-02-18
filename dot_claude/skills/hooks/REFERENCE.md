# Hooks Reference

Detailed schemas for each event. See SKILL.md for overview and recipes.

## PreToolUse

Fires before a tool call. Matches on tool name.

**Extra input fields**: `tool_name`, `tool_input`, `tool_use_id`

**Tool input schemas**:

- **Bash**: `command`, `description`, `timeout`, `run_in_background`
- **Write**: `file_path`, `content`
- **Edit**: `file_path`, `old_string`, `new_string`, `replace_all`
- **Read**: `file_path`, `offset`, `limit`
- **Glob**: `pattern`, `path`
- **Grep**: `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline`
- **WebFetch**: `url`, `prompt`
- **WebSearch**: `query`, `allowed_domains`, `blocked_domains`
- **Task**: `prompt`, `description`, `subagent_type`, `model`

**Decision control** (via `hookSpecificOutput`):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "...",
    "updatedInput": { "field": "new value" },
    "additionalContext": "..."
  }
}
```

- `"allow"` — bypass permission system
- `"deny"` — block the tool call, reason shown to Claude
- `"ask"` — show the permission prompt to user

`updatedInput` can modify tool arguments before execution.

## PermissionRequest

Fires when a permission dialog is about to be shown. Matches on tool name.

**Extra input fields**: `tool_name`, `tool_input`, `permission_suggestions`

**Decision control**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": { ... },
      "updatedPermissions": [ ... ],
      "message": "deny reason",
      "interrupt": false
    }
  }
}
```

Does NOT fire in non-interactive mode (`-p`). Use PreToolUse instead.

## PostToolUse

Fires after successful tool execution. Matches on tool name.

**Extra input fields**: `tool_name`, `tool_input`, `tool_response`, `tool_use_id`

**Decision control**: top-level `decision: "block"` + `reason`.
Also supports `additionalContext` and `updatedMCPToolOutput` (MCP tools only).

## PostToolUseFailure

Fires when a tool fails. Matches on tool name.

**Extra input fields**: `tool_name`, `tool_input`, `tool_use_id`, `error`, `is_interrupt`

**Decision control**: `additionalContext` only (can't undo the failure).

## UserPromptSubmit

Fires when user submits a prompt, before processing. No matcher support.

**Extra input fields**: `prompt`

**Decision control**:
- `decision: "block"` + `reason` — prevents processing, erases prompt
- `additionalContext` — added to Claude's context
- Plain text stdout also added as context

## Stop / SubagentStop

Fires when Claude/subagent finishes responding. Stop has no matcher;
SubagentStop matches on agent type.

**Extra input fields**: `stop_hook_active` (bool — true if already continuing
from a prior Stop hook). SubagentStop also gets `agent_id`, `agent_type`,
`agent_transcript_path`.

**Decision control**: `decision: "block"` + `reason` — prevents stopping.

**Infinite loop prevention**: Always check `stop_hook_active`:

```bash
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

## SessionStart

Fires when session begins/resumes. Matches on source: `startup`, `resume`,
`clear`, `compact`.

**Extra input fields**: `source`, `model`, optionally `agent_type`

**Output**: stdout added as context. `additionalContext` in hookSpecificOutput.
Has access to `$CLAUDE_ENV_FILE` for persisting env vars.

## SessionEnd

Fires when session terminates. Matches on reason: `clear`, `logout`,
`prompt_input_exit`, `bypass_permissions_disabled`, `other`.

**Extra input fields**: `reason`

Cannot block session termination. Cleanup only.

## Notification

Fires when Claude sends a notification. Matches on type: `permission_prompt`,
`idle_prompt`, `auth_success`, `elicitation_dialog`.

**Extra input fields**: `message`, `title`, `notification_type`

Cannot block notifications. Can add `additionalContext`.

## SubagentStart

Fires when a subagent is spawned. Matches on agent type.

**Extra input fields**: `agent_id`, `agent_type`

Cannot block creation. Can inject `additionalContext` into the subagent.

## TeammateIdle

Fires when an agent team teammate is about to go idle. No matcher.

**Extra input fields**: `teammate_name`, `team_name`

**Decision control**: Exit code 2 only (stderr = feedback, teammate continues).
Does NOT support prompt/agent hook types.

## TaskCompleted

Fires when a task is being marked completed. No matcher.

**Extra input fields**: `task_id`, `task_subject`, `task_description`,
optionally `teammate_name`, `team_name`

**Decision control**: Exit code 2 only (stderr = feedback, task stays open).

## PreCompact

Fires before context compaction. Matches on trigger: `manual`, `auto`.

**Extra input fields**: `trigger`, `custom_instructions`

Cannot block compaction.

## Prompt & Agent Hook Response Schema

Both `prompt` and `agent` type hooks must return:

```json
{ "ok": true }
```

or:

```json
{ "ok": false, "reason": "explanation fed back to Claude" }
```

Agent hooks can use tools (Read, Grep, Glob) for up to 50 turns before deciding.

## Async Hooks

Set `"async": true` on command hooks to run in background.

- Cannot block or return decisions (action already proceeded)
- Output delivered on next conversation turn via `systemMessage`
- Each firing creates a separate background process
- Only `type: "command"` supports async

## MCP Tool Matching

MCP tools follow pattern `mcp__<server>__<tool>`:

- `mcp__memory__create_entities`
- `mcp__github__search_repositories`

Match with regex: `mcp__memory__.*`, `mcp__.*__write.*`

## Monitoring (OpenTelemetry)

Not a hook, but related: Claude Code exports OTel metrics/events when
`CLAUDE_CODE_ENABLE_TELEMETRY=1` is set.

**Metrics**: `claude_code.session.count`, `claude_code.token.usage`,
`claude_code.cost.usage`, `claude_code.lines_of_code.count`,
`claude_code.commit.count`, `claude_code.pull_request.count`,
`claude_code.active_time.total`, `claude_code.code_edit_tool.decision`

**Events**: `claude_code.user_prompt`, `claude_code.tool_result`,
`claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`

All include `session.id` and `user.account_uuid` for multi-instance dashboards.

Exporters: `otlp`, `prometheus`, `console`. Configure via:
`OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`.
