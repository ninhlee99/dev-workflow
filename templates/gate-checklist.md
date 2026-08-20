# Gate checklist: [Ticket_ID]

Project home: `workspaces/<project-slug>/`. Risk: see `references/risk.md`.

| Gate | PASS when | Command if FAIL |
|---|---|---|
| G0 Knowledge | domain-knowledge covers ticket scope | `:learning` / `:coaching` |
| G1 Spec | Scenario AC + Risk; P0 → `02b-security.md` | `:spec` |
| G2 Conflict | decisions (P2 soft unless `--strict`) | `:clarify` |
| G3 Confirm | `CONFIRM G3:` (+ PM if P0) | `:confirm` |
| G4 Plan | task map (P2 soft unless `--strict`) | `:plan` |
| G5 Open Qs | no OPEN (P2 soft unless `--strict`) | `:clarify` |
| G6 Build | coverage + tests | `:build` |
| G7 Review | no OPEN P0/P1 + evidence (P2 soft unless `--strict`) | `:review` / `:fix` |
| G8 Test | machine evidence; `--strict` = CI-native | `:test` |
| G9 Ship | canary/soak/on-call/SLO/rollback | `:ship` |

P2 fast lane may WAIVE G2/G3/G4/G5/G7 with INDEX rows. P0: no WAIVE G3/G8.
