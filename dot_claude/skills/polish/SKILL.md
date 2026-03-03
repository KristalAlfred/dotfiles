---
name: polish
description: Autonomous iterative review-fix loop. Reviews codebase, fixes top issues, repeats until clean. Use when user says "polish", "clean up the repo", "review and fix", or wants iterative improvement.
---

# Polish — Iterative Review & Fix

Autonomous loop: review the codebase, fix the most important issue, repeat.

## Usage

```
/polish                    # Polish entire repo
/polish src/               # Scope to a directory
/polish --max-passes 5     # Limit iterations (default: 10)
```

## Architecture

Two layers — keep them separate:

1. **You (coordinator)** — run the loop, triage findings, delegate fixes
2. **Reviewer (subagent)** — reviews the codebase fresh each pass, unaware of the loop

## Workflow

Parse args for scope and max passes (default 10). Then loop:

### 1. REVIEW

Spawn a `mode-research` (or `role-reviewer`) subagent with:

> Review the codebase [within SCOPE] for real issues: correctness bugs, security
> problems, dead code, missing error handling, unnecessary complexity,
> anti-patterns. Return a numbered list ranked by severity (critical > important >
> minor). Each item needs a file:line reference and a one-line description. Skip
> style nits and formatting.

Each review pass is a fresh subagent — no memory of previous passes.

### 2. TRIAGE

Read the findings. If no critical or important issues remain, **stop**.

### 3. FIX

Spawn a `mode-act` subagent with a precise fix spec:
- Exact file and line
- What the issue is
- What the fix should be
- One issue per pass

### 4. VERIFY

Spawn another `mode-research` subagent:

> Verify the fix at FILE:LINE is correct and did not introduce regressions in
> surrounding code.

If verification fails, re-delegate to `mode-act` with the feedback. If it fails
twice, skip the issue and move on.

### 5. LOG

Track: pass number, issue description, outcome (fixed / skipped).

### 6. REPEAT

Go to step 1. Stop when:
- No critical/important issues in the latest review
- Max passes reached
- Same top issue reappears after a fix (stuck)

## Output

On completion, print:

```
## Polish Summary

| Pass | Issue | Outcome |
|------|-------|---------|
| 1    | Unchecked error in api/handler.go:42 | Fixed |
| 2    | SQL injection in db/query.go:18 | Fixed |
| 3    | Dead code in utils/legacy.go:100-120 | Fixed |

Remaining minor items:
- Consider renaming `x` in math/calc.go:7 for clarity
```
