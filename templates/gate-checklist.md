# Gate checklist: [Ticket_ID]

Project home: `workspaces/<project-slug>/` (knowledge + worklogs below; see `references/project-root.md`).

| Gate | PASS when | Command if FAIL |
|---|---|---|
| G0 Knowledge | domain-knowledge covers ticket scope | empty → `:learning`; wrong/changed → `:coaching` |
| G1 Spec | Scenario AC + Neg/Perm/Edge (+ UI states if touches UI) | `:spec` |
| G2 Conflict | every non-MATCH claim has decision+owner+date | `:conflict` |
| G3 Confirm | user sign-off recorded on INDEX Handoff | `:confirm` |
| G4 Plan | task ↔ AC/claim + regression matrix | `:plan` |
| G5 Open Qs | no OPEN rows in `03-qa-log` | `:conflict` |
| G6 Build | 100% coverage map + tests PASS | `:build` |
| G7 Review | AC evidence (How/By) + UI checklist if touches UI | `:review` |
| G8 Test | `06b-test-evidence` filled; zero failing tests | `:test` |

Ship after G8 PASS → `:ship` fills `07-ship`.

Partial confirm → G2/G3/G5 FAIL — do not Build.

WAIVE needs reason + owner + expiry; forbid waive money/permission/legacy unless PM note.  
`--strict` rejects G8 WAIVE.
