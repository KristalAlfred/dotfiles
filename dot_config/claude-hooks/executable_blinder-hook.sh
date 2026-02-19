#!/bin/bash
# Sends Claude Code lifecycle events to blinderd via Unix socket.
# Called from Claude Code hooks with event type as $1.

set -euo pipefail

SOCK="${BLINDER_SOCK:-$HOME/.blinder/blinder.sock}"
[ ! -S "$SOCK" ] && exit 0

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
[ -z "$SESSION_ID" ] || [ "$SESSION_ID" = "null" ] && exit 0

send_event() {
    printf '%s' "$1" | nc -w 1 -U "$SOCK" 2>/dev/null || true
}

get_tmux_info() {
    [ -z "${TMUX_PANE:-}" ] && return 1
    TMUX_SESSION_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#S' 2>/dev/null) || return 1
    TMUX_WINDOW_IDX=$(tmux display-message -t "$TMUX_PANE" -p '#I' 2>/dev/null) || return 1
    TMUX_PANE_IDX=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_index}' 2>/dev/null) || return 1
}

find_claude_pid() {
    local pid=$PPID
    while [ "$pid" -gt 1 ] 2>/dev/null; do
        local comm
        comm=$(ps -p "$pid" -o comm= 2>/dev/null | xargs) || break
        case "$comm" in
            node|claude) echo "$pid"; return ;;
        esac
        pid=$(ps -p "$pid" -o ppid= 2>/dev/null | xargs) || break
    done
    echo "$PPID"
}

case "${1:-}" in
    session_start)
        CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
        PID=$(find_claude_pid)
        if get_tmux_info; then
            send_event "$(jq -n \
                --arg sid "$SESSION_ID" \
                --argjson pid "$PID" \
                --arg pane "$TMUX_PANE_IDX" \
                --arg sess "$TMUX_SESSION_NAME" \
                --arg win "$TMUX_WINDOW_IDX" \
                --arg cwd "$CWD" \
                '{event:"session_start",session_id:$sid,pid:$pid,tmux_pane:$pane,tmux_session:$sess,tmux_window:$win,working_dir:$cwd}')"
        else
            send_event "$(jq -n \
                --arg sid "$SESSION_ID" \
                --argjson pid "$PID" \
                --arg cwd "$CWD" \
                '{event:"session_start",session_id:$sid,pid:$pid,working_dir:$cwd}')"
        fi
        ;;

    prompt_submit)
        PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            --arg prompt "$PROMPT" \
            '{event:"prompt_submit",session_id:$sid,prompt:$prompt}')"
        ;;

    tool_use)
        TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
        TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // ""')
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            --arg tool "$TOOL" \
            --arg tuid "$TOOL_USE_ID" \
            '{event:"tool_use",session_id:$sid,tool:$tool,tool_use_id:$tuid}')"
        ;;

    tool_end)
        TOOL_USE_ID=$(echo "$INPUT" | jq -r '.tool_use_id // ""')
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            --arg tuid "$TOOL_USE_ID" \
            '{event:"tool_end",session_id:$sid,tool_use_id:$tuid}')"
        ;;

    subagent_start)
        AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // ""')
        AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""')
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            --arg tuid "$AGENT_ID" \
            --arg atype "$AGENT_TYPE" \
            '{event:"subagent_start",session_id:$sid,tool_use_id:$tuid,agent_type:$atype}')"
        ;;

    subagent_stop)
        AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // ""')
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            --arg tuid "$AGENT_ID" \
            '{event:"subagent_stop",session_id:$sid,tool_use_id:$tuid}')"
        ;;

    notification)
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            '{event:"notification",session_id:$sid}')"
        ;;

    session_end)
        send_event "$(jq -n \
            --arg sid "$SESSION_ID" \
            '{event:"session_end",session_id:$sid}')"
        ;;
esac
