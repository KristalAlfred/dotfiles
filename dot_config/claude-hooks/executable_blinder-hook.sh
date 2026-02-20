#!/bin/bash
# Sends Claude Code lifecycle events to blinderd over Unix socket.
# Usage: blinder-hook.sh <event_type> [args...]

SOCKET="$HOME/.blinder/blinder.sock"
EVENT="$1"
shift

[ -S "$SOCKET" ] || exit 0
[ -n "$BLINDER_SUPPRESS_HOOKS" ] && exit 0

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[ -z "$SESSION_ID" ] && exit 0

# Grab tmux context if available (non-fatal)
if [ -n "$TMUX_PANE" ]; then
  TMUX_SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S' 2>/dev/null)
  TMUX_WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#I' 2>/dev/null)
fi

# Helper: emit null for empty strings (so Rust deserializes Option<String> correctly)
nullable() { [ -n "$1" ] && printf '"%s"' "$1" || echo null; }

send() {
  echo "$1" | nc -U -w 1 "$SOCKET" 2>/dev/null
}

case "$EVENT" in
  session_start)
    send "$(jq -nc '{
      event: "session_start",
      session_id: $sid,
      working_dir: $cwd,
      pid: ($ppid | tonumber),
      tmux_pane: $tp,
      tmux_session: $ts,
      tmux_window: $tw
    }' --arg sid "$SESSION_ID" \
       --arg cwd "$PWD" \
       --arg ppid "$PPID" \
       --argjson tp "$(nullable "$TMUX_PANE")" \
       --argjson ts "$(nullable "$TMUX_SESSION")" \
       --argjson tw "$(nullable "$TMUX_WINDOW")")"
    ;;
  prompt_submit)
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
    send "$(jq -nc '{
      event: "prompt_submit",
      session_id: $sid,
      prompt: $p
    }' --arg sid "$SESSION_ID" --arg p "$PROMPT")"
    ;;
  tool_use)
    TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
    TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // empty')
    send "$(jq -nc '{
      event: "tool_use",
      session_id: $sid,
      tool: $t,
      tool_use_id: $tuid
    }' --arg sid "$SESSION_ID" --arg t "$TOOL" --arg tuid "$TOOL_USE_ID")"
    ;;
  subagent_start)
    TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // empty')
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty')
    DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // empty')
    send "$(jq -nc '{
      event: "subagent_start",
      session_id: $sid,
      tool_use_id: $tuid,
      agent_type: $at,
      description: $desc
    }' --arg sid "$SESSION_ID" --arg tuid "$TOOL_USE_ID" \
       --arg at "$AGENT_TYPE" --argjson desc "$(nullable "$DESCRIPTION")")"
    ;;
  subagent_stop)
    TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // empty')
    send "$(jq -nc '{
      event: "subagent_stop",
      session_id: $sid,
      tool_use_id: $tuid
    }' --arg sid "$SESSION_ID" --arg tuid "$TOOL_USE_ID")"
    ;;
  tool_end)
    TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // empty')
    send "$(jq -nc '{
      event: "tool_end",
      session_id: $sid,
      tool_use_id: $tuid
    }' --arg sid "$SESSION_ID" --arg tuid "$TOOL_USE_ID")"
    ;;
  status_change)
    STATUS="${1:-idle}"
    send "$(jq -nc '{
      event: "status_change",
      session_id: $sid,
      status: $st
    }' --arg sid "$SESSION_ID" --arg st "$STATUS")"
    ;;
  notification)
    send "$(jq -nc '{
      event: "notification",
      session_id: $sid
    }' --arg sid "$SESSION_ID")"
    ;;
  session_end)
    send "$(jq -nc '{
      event: "session_end",
      session_id: $sid
    }' --arg sid "$SESSION_ID")"
    ;;
esac

exit 0
