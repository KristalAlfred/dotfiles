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

---

Role agents (domain specialists):

| Agent | Model | Can modify | Domain | Use when |
| ----- | ----- | ---------- | ------ | -------- |
| role-architect | opus | No | System design, trade-offs | Evaluating architecture, planning migrations, choosing patterns |
| role-backend | sonnet | Yes | APIs, server logic | Building or modifying server-side functionality |
| role-frontend | sonnet | Yes | UI/UX, components | Building or refining frontend interfaces |
| role-qa | sonnet | Yes | Testing, verification | Writing tests, analyzing coverage, verifying correctness |
| role-reviewer | opus | No | Code review, security | Reviewing changes for correctness, security, clarity |
| role-pm | sonnet | No | Requirements, planning | Task breakdown, prioritization, acceptance criteria |

Routing rules:

1. **Mode agents** for generic tasks (research, plan, implement) — no domain expertise needed.
2. **Role agents** for domain-heavy tasks (API design, UI build, test suite, code review) — domain expertise baked in.
3. In team contexts, role agents are natural teammates — each owns a domain.
