Role agents (domain specialists):

| Agent | Model | Can modify | Domain | Use when |
| ----- | ----- | ---------- | ------ | -------- |
| role-architect | opus | No | System design, trade-offs | Evaluating architecture, planning migrations, choosing patterns |
| role-backend | sonnet | Yes | APIs, server logic | Building or modifying server-side functionality |
| role-frontend | sonnet | Yes | UI/UX, components | Building or refining frontend interfaces |
| role-qa | sonnet | Yes | Testing, verification | Writing tests, analyzing coverage, verifying correctness |
| role-reviewer | opus | No | Code review, security | Reviewing changes for correctness, security, clarity |
| role-pm | sonnet | No | Requirements, planning | Task breakdown, prioritization, acceptance criteria |

---

Mode agents (workflow phases):

| Agent | Model | Mode | Can modify | Use when |
| ----- | ----- | ---- | ---------- | -------- |
| mode-research | sonnet | Research | No | Evidence gathering, tracing, verification |
| mode-decide | sonnet | Decide | No | Planning, trade-offs, sequencing, risk framing |
| mode-act | sonnet | Act | Yes | Implementation, testing, validation |
| mode-research-high | opus | Research | No | Complex/ambiguous investigations |
| mode-decide-high | opus | Decide | No | High-stakes architectural decisions |
| mode-act-high | opus | Act | Yes | High-risk or high-complexity implementations |

Model/tool behavior is defined in each agent frontmatter.

---

Routing:

1. **Role agents** when the task has a clear domain (API, UI, tests, review, architecture).
2. **Mode agents** when the task is cross-cutting or you need workflow discipline (research → decide → act).
3. In team contexts, role agents are natural teammates — each owns a domain.
