# Development Preferences

## Code Style

- Write clean, self-documenting code
- Comments explain _why_, not _what_
- Keep verbose explanations for the chat, not in code
- Clarity is the highest priority
- Write concise comments on functions part of public functions/methods/interfaces.
- Almost never comment on code in functions, keep functions small instead

## Testing Philosophy

- Testability is critical - always consider test design
- Prefer dependency injection for testability
- Make side effects explicit and mockable
- Write tests when applicable (namely when doing smaller fixes)
  - When doing larger things, make sure to have at least one explicit example
    on how to test it.

## Critical Thinking

- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.

## Communication

- Be concise and direct
- Don't waste tokens on boilerplate explanations, I'll ask for clarifications on
  concepts that should reasonably be familiar to me if needed
- Surface important decisions and trade-offs
- Only do explanatory comments if asked explicitly, or it's something
  particularly tricky/easy to trip up on that's hard to refactor out

## Workflow

- When making changes, run tests
- Consider edge cases
- Think about error handling upfront
- No repo-wide S/R scripts; keep edits small/reviewable
- Use your tools

## Shell

I use nushell for my day-to-day, so output any commands in nushell unless specified
otherwise.

## Frontend Aesthetics

Avoid “AI slop” UI. Be opinionated + distinctive.

Do:

- Typography: pick a real font; avoid Inter/Roboto/Arial/system defaults.
- Theme: commit to a palette; use CSS vars; bold accents > timid gradients.
- Motion: 1–2 high-impact moments (staggered reveal beats random micro-anim).
- Background: add depth (gradients/patterns), not flat default.

Avoid: purple-on-white clichés, generic component grids, predictable layouts.
