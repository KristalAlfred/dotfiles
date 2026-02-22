---
name: pr-description
description: Generate concise PR descriptions from branch diffs. Use when preparing a pull request, writing PR body, or needing a summary of changes against main/master or another base branch.
---

# PR Description Generator

Generate a well-structured, human-readable PR description from the diff between current branch and a base branch.

## Usage

```
/pr-description           # Compare against main
/pr-description develop   # Compare against develop branch
```

## Workflow

1. **Identify base branch**: Use provided branch or default to `main` (fall back to `master` if needed)

2. **Gather context**:
   ```bash
   git log --oneline <base>..HEAD        # Commits in this branch
   git diff <base>...HEAD --stat         # Changed files overview
   git diff <base>...HEAD                # Full diff
   ```

3. **Analyze changes**:
   - What problem does this solve?
   - What's the approach?
   - Any notable implementation details?

4. **Write description** following the format below

## Output Format

Output ONLY a fenced markdown codeblock containing the PR description. No preamble, no explanation, nothing outside the codeblock. This allows piping the output directly.

````
```markdown
## Summary

[1-2 sentences: what this PR does and why]

## Changes

- [Bullet points of key changes, grouped logically]
- [Focus on *what* changed, not *how* (the diff shows how)]

## Testing

[How to verify this works - keep brief]
```
````

## Writing Guidelines

- **Be concise**: No filler words, no "This PR...", no "I have..."
- **Be human**: Write like you're explaining to a colleague, not a robot
- **Be specific**: "Fix null check in auth flow" not "Fix bug"
- **Group related changes**: Don't list every file, group by purpose
- **Skip obvious things**: Don't mention "updated imports" or trivial changes
- **No timestamps or metadata**: The PR itself tracks that
- **Maximum ~150 words**: If you need more, the PR might be too big

## Examples

### Good

```markdown
## Summary

Adds rate limiting to the API to prevent abuse. Limits are configurable per-endpoint.

## Changes

- Rate limiter middleware with sliding window algorithm
- Per-route limit configuration in `config/routes.yaml`
- 429 responses with retry-after headers

## Testing

Run `make test-ratelimit` or manually hit an endpoint 100+ times quickly.
```

### Bad (too verbose)

```markdown
## Summary

This pull request implements a comprehensive rate limiting solution for our API infrastructure. After careful consideration of various approaches, I decided to use a sliding window algorithm because it provides smooth rate limiting behavior...

[...continues for 500 more words...]
```

## Edge Cases

- **No commits**: Inform user there's nothing to describe
- **Merge commits only**: Look at the actual file changes, not commit messages
- **Large diffs**: Focus on the most significant changes, mention "and X other smaller changes"
