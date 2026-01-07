---
name: skill-authoring
description: Best practices for writing Claude Code skills and agents. Use when creating, improving, or troubleshooting SKILL.md or agent files.
---

# Skill and Agent Authoring Guide

## Skill Writing Principles

### 1. Strong Descriptions

Good: "Analyze Rust code for unsafe blocks, justify each usage. Use when reviewing Rust code for safety."
Bad: "Helps with Rust" (too vague)

Include trigger keywords users would naturally say.

### 2. Progressive Disclosure

- Keep SKILL.md under 500 lines
- Split large content into separate files
- SKILL.md is the table of contents, not the encyclopedia

### 3. Validation Loops

Always include verify-fix-repeat patterns:

```
1. Run validator (script or checklist)
2. Fix issues
3. Re-validate
4. Only proceed when clean
```

### 4. File Organization

```
skill-name/
├── SKILL.md           # Overview and workflow
├── REFERENCE.md       # Detailed docs (optional)
├── EXAMPLES.md        # Code examples (optional)
└── validate.sh        # Utility scripts (optional)
```

## Agent Writing Principles

### 1. Proactive Invocation

Use phrases in description:

- "Use PROACTIVELY after..."
- "MUST BE USED when..."
- "Automatically invoke for..."

### 2. Tool Restrictions

Only specify tools if you need restrictions:

```yaml
tools: Read, Grep, Glob # Read-only agent
```

Omit for full tool access.

### 3. Model Selection

- `sonnet`: Fast, efficient (default)
- `opus`: Complex reasoning
- `inherit`: Match main conversation
- `haiku`: Very fast, simple tasks

### 4. Skills Integration

```yaml
skills: rust-patterns, security-check
```

Agent loads these skills at startup.

## Common Patterns

### Research Agent

```yaml
description: Deep codebase analysis. Use for complex refactoring planning.
tools: Read, Grep, Glob, Bash
model: opus
```

### Review Agent

```yaml
description: Code review specialist. Use PROACTIVELY after commits.
tools: Read, Grep, Glob
skills: code-standards, security-patterns
```

### Fix Agent

```yaml
description: Automated test fixer. Use when tests fail.
tools: Read, Edit, Bash
skills: test-patterns
```

## Troubleshooting

### Skill Not Loading

1. Check filename is exactly `SKILL.md` (case-sensitive)
2. Verify frontmatter starts on line 1 (no blank lines before `---`)
3. Use spaces, not tabs in YAML
4. Run `claude --debug` to see errors

### Skill Not Triggering

1. Add more keywords to description
2. Make description action-oriented
3. Test with explicit keywords from description

### Agent Not Invoked

1. Add "PROACTIVELY" or "MUST BE USED" to description
2. Make description more specific
3. Explicitly mention: "Use the X agent to..."

## Testing Checklist

- [ ] YAML frontmatter is valid
- [ ] Description includes trigger keywords
- [ ] Instructions are clear and actionable
- [ ] Examples are included
- [ ] Validation steps are defined
- [ ] File is under 500 lines (for skills)
- [ ] Runs with `claude --debug` without errors
