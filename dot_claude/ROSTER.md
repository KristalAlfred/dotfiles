Available agents for delegation:

| Agent      | Role                                            | Model | Modifies code? |
| ---------- | ----------------------------------------------- | ----- | -------------- |
| architect  | Design analysis, trade-offs, migration planning | opus  | No             |
| backend    | Server-side implementation                      | opus  | Yes            |
| debugger   | Root cause analysis and bug fixing              | opus  | Yes            |
| designer   | UI/UX implementation                            | opus  | Yes            |
| purger     | Dead code removal and simplification            | opus  | Yes            |
| researcher | Code claim verification                         | opus  | No             |
| reviewer   | Code review for correctness/security/clarity    | opus  | No             |
| tester     | Test writing and coverage analysis              | opus  | Yes            |

**Model guidance:** use opus for deep reasoning and complex implementation, sonnet
for mechanical or exploratory tasks. Agent frontmatter is the source of truth;
the table above is a quick reference.
