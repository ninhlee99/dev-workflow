# Gate checklist: [Ticket_ID]

Project home: `workspaces/<project-slug>/`. Risk: see `references/risk.md`.

| Gate | PASS when | Command if FAIL |
|---|---|---|
| G0 Knowledge | domain-knowledge covers ticket scope | `:learning` / `:coaching` |
| G1 Spec | Scenario AC + Risk P0/P1/P2 (+ UI states if UI) | `:spec` |
| G2 Conflict | every non-MATCH has decision+owner+date | `:conflict` |
| G3 Confirm | literal `CONFIRM G3: <Ticket> <name> <date>` (P0 + `CONFIRM G3-PM:`) | `:confirm` |
| G4 Plan | task ↔ AC/claim + regression | `:plan` |
| G5 Open Qs | no OPEN in `03-qa-log` | `:conflict` |
| G6 Build | 100% coverage map + tests PASS | `:build` |
| G7 Review | AC evidence How/By (+ UI checklist) | `:review` |
| G8 Test | output + machine evidence (SHA/CI/junit); zero failures | `:test` |
| G9 Ship | migration / flag / monitor / rollback filled | `:ship` |

P2 fast lane may WAIVE G2/G4/G5/G7 with INDEX rows. P0: no WAIVE G3/G8.
