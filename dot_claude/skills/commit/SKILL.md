---
name: commit
description: Generate concise commit messages from staged changes. Use when committing, writing commit messages, or running /commit.
---

# Commit Message Generator

Generate a clear, categorized commit message from staged changes only.

## Usage

```
/commit
```

## Workflow

1. **Check staged changes**:
   ```bash
   git diff --cached --stat      # Overview of staged files
   git diff --cached             # Full staged diff
   ```

2. **If nothing staged**: Inform user and stop

3. **Analyze the diff**:
   - What's the primary purpose of these changes?
   - Pick the most fitting category

4. **Write commit message** following the format below

## Categories

Use exactly one of these prefixes:

| Prefix | Use for |
|--------|---------|
| `feat:` | New functionality |
| `fix:` | Bug fixes |
| `refactor:` | Code restructuring (no behavior change) |
| `test:` | Adding or updating tests |
| `docs:` | Documentation only |
| `chore:` | Build, deps, config, tooling |
| `style:` | Formatting, whitespace (no logic change) |
| `perf:` | Performance improvements |

## Output Format

Output ONLY the commit message. No explanation, no codeblock fences, nothing else. This allows direct use with `git commit -m`.

**Header only** (for simple changes):
```
category: concise description
```

**Header + body** (for changes needing context):
```
category: concise description

Why this change was needed or notable implementation detail.
Keep to 1-2 sentences max.
```

## Rules

- Header MUST be under 72 characters (ideally under 50)
- Start with lowercase after the colon
- No period at end of header
- Use imperative mood: "add" not "added" or "adds"
- Body separated by blank line if present
- Body lines wrapped at 72 characters

## Examples

### Simple (header only)

```
fix: handle null user in auth middleware
```

```
chore: bump eslint to v9
```

```
test: add coverage for edge cases in parser
```

### With body

```
refactor: extract validation into separate module

Validation logic was duplicated across three handlers.
Now shared via ValidationService.
```

## What NOT to do

- Don't describe every file changed
- Don't use vague messages: "fix bug", "update code", "changes"
- Don't include ticket numbers unless user mentions them
- Don't use past tense: "fixed", "added"
- Don't exceed 72 chars in header
