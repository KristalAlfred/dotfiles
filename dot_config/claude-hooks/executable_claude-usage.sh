#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/usage.db"
DAYS=7
MODE="summary"

usage() {
  cat <<EOF
Usage: claude-usage [OPTIONS]

Options:
  --days N         Look back N days (default: 7)
  --by-project     Break down by project
  --detail         Full table with all fields
  --topics         Task descriptions per agent type
  --migrate        Import old JSONL logs into the database
  -h, --help       Show this help
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) DAYS="$2"; shift 2 ;;
    --by-project) MODE="by-project"; shift ;;
    --detail) MODE="detail"; shift ;;
    --topics) MODE="topics"; shift ;;
    --migrate) MODE="migrate"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ "$MODE" == "migrate" ]]; then
  LOG_DIR="$HOME/.claude/usage-logs"
  if [[ ! -d "$LOG_DIR" ]]; then
    echo "No JSONL logs directory found."
    exit 0
  fi

  # Ensure DB + table exist
  if [[ ! -f "$DB" ]]; then
    sqlite3 "$DB" <<'SQL'
      CREATE TABLE agent_usage (
        ts TEXT NOT NULL, session_id TEXT, agent_type TEXT,
        description TEXT, prompt_preview TEXT, model TEXT, project TEXT
      );
      CREATE INDEX idx_ts ON agent_usage(ts);
      CREATE INDEX idx_agent ON agent_usage(agent_type);
      CREATE INDEX idx_project ON agent_usage(project);
SQL
  fi

  count=0
  for f in "$LOG_DIR"/*.jsonl; do
    [[ -s "$f" ]] || continue
    jq -r '[.ts, .session_id, .agent_type, .description, .prompt_preview, .model, .project] | @csv' "$f" \
      | sqlite3 "$DB" '.mode csv' '.import /dev/stdin agent_usage'
    n=$(wc -l < "$f" | tr -d ' ')
    count=$((count + n))
  done
  echo "Migrated $count records from JSONL into $DB"
  exit 0
fi

if [[ ! -f "$DB" ]]; then
  echo "No usage database found. Usage will be tracked on next agent invocation."
  exit 0
fi

cutoff=$(date -u -v-"${DAYS}d" +%Y-%m-%dT00:00:00Z 2>/dev/null \
  || date -u -d "$DAYS days ago" +%Y-%m-%dT00:00:00Z)

case "$MODE" in
  summary)
    sqlite3 -column -header "$DB" <<SQL
      SELECT agent_type, COUNT(*) AS count
      FROM agent_usage
      WHERE ts >= '$cutoff'
      GROUP BY agent_type
      ORDER BY count DESC;
SQL
    ;;

  by-project)
    sqlite3 -column -header "$DB" <<SQL
      SELECT project, agent_type, COUNT(*) AS count
      FROM agent_usage
      WHERE ts >= '$cutoff'
      GROUP BY project, agent_type
      ORDER BY project, count DESC;
SQL
    ;;

  detail)
    sqlite3 -column -header "$DB" <<SQL
      SELECT
        substr(ts, 1, 16) AS time,
        substr(session_id, 1, 8) AS session,
        agent_type,
        description,
        COALESCE(model, '-') AS model,
        project
      FROM agent_usage
      WHERE ts >= '$cutoff'
      ORDER BY ts;
SQL
    ;;

  topics)
    sqlite3 -column -header "$DB" <<SQL
      SELECT
        agent_type,
        description,
        COUNT(*) AS count
      FROM agent_usage
      WHERE ts >= '$cutoff'
      GROUP BY agent_type, description
      ORDER BY agent_type, count DESC;
SQL
    ;;
esac
