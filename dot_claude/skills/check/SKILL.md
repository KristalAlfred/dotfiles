---
name: check
description: This skill should be used when the user asks to "review my changes", "review this PR", "check my code", "review the diff", or mentions "code review".
---

# Code Review

Review code changes for best practices, project consistency, and potential issues.

## Usage

```
/check                      # Review branch vs main (default)
/check worktree             # Review uncommitted changes only
/check src/api              # Review only changes in src/api
/check --strict             # Stricter review for critical code
/check worktree src/ --strict  # Combine options
```

## Modes

| Mode | Diff Command | Use Case |
|------|--------------|----------|
| `branch` (default) | `git diff main..HEAD` | Full PR: all commits on branch vs main |
| `worktree` | `git diff HEAD` | Uncommitted changes (staged + unstaged) |

When both uncommitted changes and branch commits exist, default to `branch` mode.

## Strictness Levels

| Level | Flag | Focus |
|-------|------|-------|
| Normal | (default) | Bugs, security, clear anti-patterns |
| Strict | `--strict` | Above + style consistency, test coverage, documentation gaps |

## Review Workflow

### 1. Parse Arguments

Determine mode, scope, and strictness from arguments:
- First positional arg `worktree` → worktree mode, otherwise branch mode
- Path arguments → limit diff to those paths
- `--strict` flag → enable strict mode

### 2. Gather the Diff

For **branch** mode:
```nushell
git log main..HEAD --oneline  # Context: what commits are included
git diff main..HEAD --stat    # Overview of changed files
git diff main..HEAD [paths]   # Actual diff (scoped if paths provided)
```

For **worktree** mode:
```nushell
git status                    # What's staged vs unstaged
git diff HEAD [paths]         # All uncommitted changes
```

### 3. Understand Project Context

Before reviewing, gather project priorities:
- Read `CLAUDE.md`, `README.md`, or similar for stated conventions
- Check recent commits for style patterns
- Identify the architectural layer of changed code:
  - **Entry points** (API handlers, CLI): availability > strict correctness
  - **Core logic**: correctness and clarity paramount
  - **Data layer**: consistency and safety critical
  - **Hot paths**: performance matters

### 4. Review Dimensions

**Always check:**
- Correctness: edge cases, error handling appropriate to layer
- Security: no injection, XSS, hardcoded secrets
- Resource management: cleanup of connections, handles, etc.
- Logic errors and obvious bugs

**In strict mode, also check:**
- Style consistency with surrounding code
- Test coverage for new/changed behavior
- Documentation for public APIs
- Naming conventions

### 5. Output Format

```markdown
## Summary
[1-2 sentence overview of what the changes do]

## Findings

### Critical
[Must fix: bugs, security issues, data corruption risks]
[Empty section = no critical issues]

### Suggestions
[Worth considering: improvements, potential edge cases]

### Nits
[Minor: style, naming, small optimizations]
[In normal mode, keep this section brief or omit]

## Context
[Project priorities inferred, architectural layer notes]
```

If no issues found, state that clearly. Do not invent concerns.

### 6. Follow-up

After presenting findings:
- Offer to explain any finding in detail
- Offer to draft fixes for critical/suggestion items
- Ask about intent if something is unclear
