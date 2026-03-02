---
description: Team awareness context for cross-agent delegation, handoffs, and coordination.
---

# Context: Team Awareness

## Agent Registry

The full agent roster lives in `@ROSTER.md`. Read it to discover available agents
and their capabilities before delegating or handing off.

## Delegation Protocol

Route tasks by domain expertise:

| Domain | Primary Role | Backup |
|--------|-------------|--------|
| System design, trade-offs | `role-architect` | `mode-decide-high` |
| Server-side implementation | `role-backend` | `mode-act` |
| UI/UX implementation | `role-frontend` | `mode-act` |
| Test design and coverage | `role-qa` | `mode-act` |
| Code review and security | `role-reviewer` | `mode-research` |
| Requirements and planning | `role-pm` | `mode-decide` |

## Handoff Rules

- Finish your current scope before handing off
- Include context: what was done, what remains, relevant file paths
- Specify which agent should pick up and why
- In team contexts, use task list for coordination (don't just mention it in chat)

## When to Delegate vs Do It Yourself

- **Delegate**: task is outside your domain, or would benefit from specialist knowledge
- **Do it yourself**: task is small, within your domain, and delegation overhead exceeds the work
