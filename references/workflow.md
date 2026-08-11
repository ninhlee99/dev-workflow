# Dev Workflow rules

Goal: clear requirements before code. Use `workspaces/<project-slug>/` from `project-root.md`.
Risk tiers: see `references/risk.md` (P0 hard / P1 hard / P2 fast).

## Output contract
- Reply only the asked scope.
- Format: verdict → gaps → next command.
- Keep status short; ask max 3 numbered questions.
- Use `[LEARNING]` / `[COACHING]`; keep artifact fields in English.

## Gates and dispatch
| Gate | PASS means | FAIL command |
|---|---|---|
| G0 | domain knowledge matches ticket scope | empty → `:learning`; wrong/changed → `:coaching` |
| G1 | AC has Scenario + NEG/PERM/EDGE (+ UI states if UI); Risk set | `:spec` |
| G2 | each non-MATCH has decision, owner, date | `:conflict` |
| G3 | human `CONFIRM G3: <Ticket> <name> <date>` on INDEX (P0 also `CONFIRM G3-PM:`) | `:confirm` |
| G4 | tasks map to AC/claims + regression | `:plan` |
| G5 | `03-qa-log` has no OPEN | `:conflict` |
| G6 | AC/claim coverage map complete + tests pass | `:build` |
| G7 | AC evidence has How/By (+ UI evidence if UI) | `:review` |
| G8 | test evidence + machine fields (CI URL / SHA / junit); zero failing tests | `:test` |
| G9 | ship safety: migration, flag, monitor, rollback filled | `:ship` |

WAIVE only on INDEX: `Gate/claim | reason | owner | expiry | PM note`.  
P0: no WAIVE G3/G8. `--strict` or P0/P1: machine evidence required. `--strict`: no G8 WAIVE.

## Stage order
`:learning` → `:coaching` → `:start` → `:spec` → `:conflict` → `:confirm` → `:plan` → `:build` → `:review` → `:test` → `/dev-workflow:check` → `:ship` → `:status`

If current stage already PASS, jump to next. End `:spec`, end `:plan`, and before close `:build`: print uncovered AC/claim map; any gap = FAIL.
P2 fast lane may WAIVE G2/G4/G5/G7 with INDEX rows — never silent skip.
