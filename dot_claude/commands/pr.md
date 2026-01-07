---
description: Create a pull request using gh. Summarizes commits, asks for approval before creating.
allowed-tools: Bash(git:*), Bash(gh pr create:*)
---

## Context

- Current branch: !`git branch --show-current`
- Recent commits on this branch: !`git log --oneline -10`

## Your Task

Help the user create a pull request.

**Style note**: Keep it professional and concise. No emojis unless the user asks to "spice it up".

### Step 1: Gather Information

Ask the user:

1. **Target branch** - Which branch should this PR merge into? (e.g., main, develop, master)

If the user provided this info in their message, skip asking.

### Step 2: Analyze the Changes

Once you know the target branch, run:

- `git log <target>..<current> --oneline` to see commits
- `git diff <target>...<current> --stat` to see changed files
- `git diff <target>...<current>` to see the actual diff (summarize, don't dump)

### Step 3: Draft PR Summary

Based on the commits and diff, draft:

- **Title**: Concise, describes what the PR does
- **Summary**: 2-4 bullet points covering the changes

Present this to the user and ask if they want to adjust anything.

### Step 4: Create PR (After Approval)

Only after the user approves, run:

```bash
gh pr create --base <target> --title "<title>" --body "$(cat <<'EOF'
## Summary
- Point 1
- Point 2
EOF
)"
```

Return the PR URL when done.
