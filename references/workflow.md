# Dev Workflow rules

Goal: clear requirements before code. Use `workspaces/<project-slug>/` from `project-root.md`.

## Output contract
- Reply only the asked scope.
- Format: verdict → gaps → next command.
- Keep status short; ask max 3 numbered questions.
- Use `[LEARNING]` / `[COACHING]`; keep artifact fields in English.

## Gates and dispatch
| Gate | PASS means | FAIL command |
|---|---|---|
| G0 | domain knowledge matches ticket scope | empty → `:learning`; wrong/changed → `:coaching` |
| G1 | AC has Scenario + NEG/PERM/EDGE (+ UI states if UI) | `:spec` |
| G2 | each non-MATCH has decision, owner, date | `:conflict` |
| G2.5 | user signs off on all conflict decisions and spec changes | `:confirm` |
| G3 | tasks map to AC/claims + regression | `:plan` |
| G4 | `03-qa-log` has no OPEN | `:conflict` |
| G5 | AC/claim coverage map complete + tests pass | `:build` |
| G6 | AC evidence has How/By (+ UI evidence if UI) | `:review` |
| G7 | ship artifact complete (`07-ship`) | `:ship` |

WAIVE only on worklog INDEX: `Gate/claim | reason | owner | expiry | PM note`. No money/permission/legacy waive unless PM.

## Stage order
`:learning` → `:coaching` → `:start` → `:spec` → `:conflict` → `:confirm` → `:plan` → `:build` → `:review` → `/dev-workflow:check` → `:ship` → `:status`

If current stage already PASS, jump to next. End `:spec`, end `:plan`, and before close `:build`: print uncovered AC/claim map; any gap = FAIL.
