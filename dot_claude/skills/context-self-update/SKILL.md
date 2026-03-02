---
description: Self-update context for refreshing domain knowledge via web research.
---

# Context: Self-Update

## Purpose

Protocol for role agents to refresh their domain knowledge when explicitly asked
(e.g., "update your frontend knowledge", "research latest Go patterns").

## Protocol

1. User triggers update with an explicit request
2. Use `WebSearch` and/or `WebFetch` to gather current information
3. Evaluate findings against existing knowledge in agent memory
4. Write new findings to agent memory files — never modify agent definition files
5. Summarize what was learned and what changed

## Memory Targets

- Write to the agent's memory directory (managed by `memory: user` in frontmatter)
- Use topic-based files (e.g., `go-patterns.md`, `react-19.md`)
- Update existing memory entries when information is superseded
- Remove outdated entries that are no longer accurate

## Boundaries

- Manual trigger only — never self-initiate knowledge updates
- No modifications to agent `.md` definition files
- No freshness tracking or scheduling
- Keep findings concise and actionable, not encyclopedic
