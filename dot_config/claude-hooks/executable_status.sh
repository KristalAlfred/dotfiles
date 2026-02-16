#!/bin/bash
STATUS_DIR="$HOME/.claude/hook-status"
STATUS="$1"

[ -z "$TMUX_PANE" ] && exit 0

SESSION_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#S' 2>/dev/null)
[ -z "$SESSION_NAME" ] && exit 0

SAFE_NAME="${SESSION_NAME//\//%}"
mkdir -p "$STATUS_DIR"

if [ "$STATUS" = "cleanup" ]; then
    rm -f "$STATUS_DIR/$SAFE_NAME"
else
    printf '%s' "$STATUS" > "$STATUS_DIR/$SAFE_NAME"
fi
