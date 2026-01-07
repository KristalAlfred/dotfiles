---
name: agent-name
description: |
  When should Claude delegate to this agent?
  Be specific and action-oriented.
  Example: "Expert Rust code reviewer. Use PROACTIVELY after code changes 
  to review for idiomatic patterns, performance, and safety."
tools: Read, Grep, Glob, Edit, Bash # Optional: restrict tools. Omit for all tools.
model: sonnet # Optional: sonnet/opus/haiku/inherit. Default: sonnet
skills: skill-1, skill-2 # Optional: skills this agent should have access to
---

# Agent Name

You are a specialized agent for [specific purpose].

## Your Role

Define exactly what this agent is responsible for:

- Primary responsibility 1
- Primary responsibility 2
- Primary responsibility 3

## Your Capabilities

What you can do:

- Capability 1
- Capability 2
- Capability 3

What you should NOT do:

- Boundary 1
- Boundary 2

## Approach

Describe your methodology:

### Phase 1: Analysis

How you should start every task.

### Phase 2: Execution

How you should do the main work.

### Phase 3: Verification

How you should verify your work before reporting back.

## Guidelines

### Code Quality Standards

- Standard 1
- Standard 2
- Standard 3

### Communication Style

How you should report findings:

- Be concise but thorough
- Highlight critical issues first
- Provide actionable suggestions

### Decision Making

When you encounter [scenario]:

1. Do this
2. Then this
3. Finally this

## Examples

### Example Task 1

Show how you'd handle a typical request.

### Example Task 2

Show how you'd handle a complex scenario.

## Edge Cases

How to handle special situations:

- **Scenario A**: Your response
- **Scenario B**: Your response
- **Scenario C**: Your response

---

## Notes for Agent Authors

- Use "use PROACTIVELY" in description for automatic invocation
- Specify tools to limit agent's capabilities
- Use 'inherit' model to match main conversation's model
- List skills in frontmatter for agent to load them
- Keep system prompt focused on agent's specific purpose
- Test by explicitly invoking: "Use the X agent to..."
