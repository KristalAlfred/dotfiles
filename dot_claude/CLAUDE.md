# Development Preferences

## Code Style

- Write clean, self-documenting code
- Comments explain _why_, not _what_
- Keep verbose explanations for the chat, not in code
- Always value clarity over cleverness
- Write concise comments on functions part of public functions/methods/interfaces.
- Write concise comments on code inside modules if needed (everything doesn't need
  a comment)

## Testing Philosophy

- Testability is critical - always consider test design
- Prefer dependency injection for testability
- Make side effects explicit and mockable
- Write tests when applicable (namely when doing smaller fixes)
  - When doing larger things, make sure to have at least one explicit example
    on how to test it.

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

## Shell

I use nushell for my day-to-day, so output any commands in nushell unless specified
otherwise.
