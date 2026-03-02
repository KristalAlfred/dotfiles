---
name: agent-name
description: |
  Functional contract for this mode agent or deprecated compatibility alias.
tools: Read, Grep, Glob, Edit, Bash # Optional: restrict tools. Omit for full access.
model: sonnet # Optional: sonnet/opus/haiku/inherit
skills: [conventions] # Optional: startup skills
---

# Agent Name

State whether this file is an active mode agent or a deprecated alias shim.

## Contract

- **Mode**: `Research` | `Decide` | `Act`
- **Can modify files**: `Yes` or `No`
- **Routing**: how this file is selected

## Scope

- What the agent is responsible for
- Inputs required before execution
- Output required at completion

## Boundaries

- `Research`: read-only
- `Decide`: no edits unless explicitly requested
- `Act`: execute only after decision, except trivial tasks
- Tool restrictions and explicit non-goals

## Execution Pattern

1. Load required context skills.
2. Perform mode-specific work.
3. Return evidence, plan, or execution results.

For deprecated aliases, replace this section with a short route mapping.

## Deliverables

- Required output shape (findings, plan, or patch+validation)
- Evidence expectations (`file:line`, command output)
- Completion checks

## Handoffs

- Next mode when work crosses boundaries
- When to stop and ask for explicit user instruction

## Notes for Authors

- Keep language functional, not anthropomorphic
- Active roster contains mode agents and role agents
- Mode agents: permission-based (research/decide/act)
- Role agents: domain-based (architect/backend/frontend/qa/reviewer/pm)

---

## Role Agent Variant

Role agents follow the same template structure with these additions:

```yaml
---
name: role-<domain>
description: |
  Domain specialist for <domain area>.
model: sonnet # or opus for deep-reasoning roles
memory: user
skills: [conventions, context-team-awareness, context-<domain>]
---
```

- Declare `File edits: Yes/No` in the body (permissions are per-agent, not composed with mode agents)
- Include a `## Memory Protocol` section for knowledge accumulation
- Include a `## Handoffs` section referencing other role agents by name
- Add `context-team-awareness` to skills for cross-agent coordination
- Add domain-specific context skills (e.g., `context-backend`, `context-testing`)
