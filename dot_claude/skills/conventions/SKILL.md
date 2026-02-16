---
name: conventions
description: Core development conventions and code style preferences. Preloaded by all agents to ensure consistent output.
---

# Development Conventions

These are the user's non-negotiable preferences. Follow them in all code you produce.

## Code Style

- Write clean, self-documenting code
- Comments explain _why_, not _what_
- Keep verbose explanations for the chat, not in code
- Clarity is the highest priority
- Write concise comments on public functions/methods/interfaces
- Almost never comment on code inside functions — keep functions small instead
- Comments are always general — never reference old code or migration context

## Testing

- Testability is critical — always consider test design
- Prefer dependency injection for testability
- Make side effects explicit and mockable where suitable
- Write tests for smaller fixes; for larger work, include at least one concrete test example

## Critical Thinking

- Fix root cause, not band-aid
- Unsure: read more code; if still stuck, ask with short options
- Conflicts: call out; pick safer path
- Unrecognized changes: assume other agent; keep going; focus your changes

## Communication

- Be concise and direct
- Don't waste tokens on boilerplate explanations
- Surface important decisions and trade-offs
- When claiming things about code, always cite evidence (file:line, struct name, etc.)

## Workflow

- Run tests after making changes
- Consider edge cases
- Think about error handling upfront
- Keep edits small and reviewable

## Frontend Aesthetics

When producing any UI code, avoid "AI slop":

- Typography: pick a real font; never Inter/Roboto/Arial/system defaults
- Theme: commit to a palette; CSS vars; bold accents over timid gradients
- Motion: 1–2 high-impact moments; staggered reveal beats scattered micro-animations
- Depth: backgrounds have texture, not flat white/gray
- Avoid: purple-on-white, generic card grids, predictable layouts
