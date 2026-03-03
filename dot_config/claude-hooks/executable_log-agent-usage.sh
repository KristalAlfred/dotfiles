#!/bin/bash
DB="$HOME/.claude/usage.db"

if [[ ! -f "$DB" ]]; then
  sqlite3 "$DB" <<'SQL'
    CREATE TABLE agent_usage (
      ts           TEXT NOT NULL,
      session_id   TEXT,
      agent_type   TEXT,
      description  TEXT,
      prompt_preview TEXT,
      model        TEXT,
      project      TEXT
    );
    CREATE INDEX idx_ts ON agent_usage(ts);
    CREATE INDEX idx_agent ON agent_usage(agent_type);
    CREATE INDEX idx_project ON agent_usage(project);
SQL
fi

cat | jq -r '[
  (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  .session_id,
  .tool_input.subagent_type,
  .tool_input.description,
  (.tool_input.prompt[:200]),
  (.tool_input.model // ""),
  (.cwd | split("/") | last)
] | @csv' | sqlite3 "$DB" \
  '.mode csv' \
  '.import /dev/stdin agent_usage'
