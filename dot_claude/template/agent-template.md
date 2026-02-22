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
- Active roster should contain only mode agents
- Keep deprecated aliases minimal and clearly marked
