#!/bin/bash
# Conversation reflector — periodically analyzes the conversation for durable
# learnings and writes them to Claude's project memory.
#
# Triggered as an async Stop hook. Uses turn-counting + lock files to avoid
# running too often or overlapping with itself.

set -euo pipefail

INPUT=$(cat)

# Never re-enter from a stop-hook continuation
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
CWD=$(echo "$INPUT" | jq -r '.cwd')

[ ! -f "$TRANSCRIPT" ] && exit 0
command -v claude >/dev/null 2>&1 || exit 0

# --- gate: only reflect every INTERVAL transcript lines ----------------------

STATE_DIR="$HOME/.claude/reflect-state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$SESSION_ID"
LOCK_FILE="$STATE_DIR/${SESSION_ID}.lock"

# Skip if another reflection is already running for this session (mkdir is atomic)
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    # Stale lock guard: if lock is older than 5 minutes, reclaim it
    if [ "$(uname)" = "Darwin" ]; then
        lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_FILE") ))
    else
        lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") ))
    fi
    [ "$lock_age" -lt 300 ] && exit 0
    rm -rf "$LOCK_FILE"
    mkdir "$LOCK_FILE" 2>/dev/null || exit 0
fi
trap 'rm -rf "$LOCK_FILE"' EXIT

LINE_COUNT=$(wc -l < "$TRANSCRIPT" | tr -d ' ')
LAST_REFLECTED=0
[ -f "$STATE_FILE" ] && LAST_REFLECTED=$(cat "$STATE_FILE")

INTERVAL=20
DELTA=$((LINE_COUNT - LAST_REFLECTED))
[ "$DELTA" -lt "$INTERVAL" ] && exit 0

# Commit early so slow LLM calls don't cause re-triggers
echo "$LINE_COUNT" > "$STATE_FILE"

# --- derive project memory path ----------------------------------------------

# Claude Code's scheme: replace / and . with -
SAFE_CWD=$(echo "$CWD" | tr '/.' '-')
MEMORY_DIR="$HOME/.claude/projects/$SAFE_CWD/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
mkdir -p "$MEMORY_DIR"

EXISTING_MEMORY=""
[ -f "$MEMORY_FILE" ] && EXISTING_MEMORY=$(head -200 "$MEMORY_FILE")

# --- extract recent conversation ---------------------------------------------

# Last 200 lines, capped at 100 KB
RECENT=$(tail -200 "$TRANSCRIPT" | head -c 100000)

# --- analyze with a cheap model ----------------------------------------------

EXTRACT_PROMPT=$(cat <<'EOF'
You are a meta-observer reviewing a Claude Code conversation transcript (JSONL).

Extract DURABLE learnings that would help in FUTURE sessions with this user:
- User preferences and workflow patterns
- Corrections the user made (misunderstandings, wrong assumptions by Claude)
- Project conventions discovered during the conversation
- Debugging insights or gotchas encountered
- Tools, libraries, or patterns the user prefers or avoids

RULES:
- Only extract things useful across sessions, not task-specific context
- Skip anything already captured in the existing memory below
- Be extremely concise — short bullet points only
- If nothing new is worth remembering, respond with exactly: NOTHING
- Output only markdown bullet points, no preamble
EOF
)

RESULT=$(printf 'EXISTING MEMORY:\n%s\n\nRECENT TRANSCRIPT:\n%s' \
    "${EXISTING_MEMORY:-(empty)}" "$RECENT" \
    | claude -p --model opus "$EXTRACT_PROMPT" 2>/dev/null) || exit 0

# Bail if nothing useful
[ -z "$RESULT" ] && exit 0
echo "$RESULT" | grep -qx "NOTHING" && exit 0

# --- write or merge into memory ----------------------------------------------

if [ -n "$EXISTING_MEMORY" ]; then
    MERGED=$(claude -p --model opus \
        "Merge these two memory documents into one. Remove duplicates and redundancy. Keep under 150 lines. Output only the merged markdown, nothing else.

EXISTING:
$EXISTING_MEMORY

NEW FINDINGS:
$RESULT" 2>/dev/null) || exit 0

    [ -n "$MERGED" ] && printf '%s\n' "$MERGED" > "$MEMORY_FILE"
else
    printf '%s\n' "$RESULT" > "$MEMORY_FILE"
fi
