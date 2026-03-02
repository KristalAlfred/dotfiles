Mode-first roster (active):

| Agent | Model | Mode | Can modify | Use when |
| ----- | ----- | ---- | ---------- | -------- |
| mode-research | sonnet | Research | No | Evidence gathering, tracing, verification |
| mode-decide | sonnet | Decide | No | Planning, trade-offs, sequencing, risk framing |
| mode-act | sonnet | Act | Yes | Implementation, testing, validation |
| mode-research-high | opus | Research | No | Complex/ambiguous investigations |
| mode-decide-high | opus | Decide | No | High-stakes architectural decisions |
| mode-act-high | opus | Act | Yes | High-risk or high-complexity implementations |

Routing rule:

1. Select mode agent (default to sonnet tier; use `-high` when task warrants it).
2. Load context skills.
3. Execute task spec.

Model/tool behavior is defined in each agent frontmatter.
