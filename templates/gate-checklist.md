# Gate checklist: [Ticket_ID]

Project home: `workspaces/<project-slug>/` (knowledge + worklogs below; see `references/project-root.md`).

| Gate | PASS when | Command if FAIL |
|---|---|---|
| G0 Knowledge | `workspaces/<project-slug>/domain-knowledge/` covers ticket scope (G0 DoD) | empty / Needs learning → `:learning`; wrong knowledge / changed spec → `:coaching` |
| G1 Spec | Scenario AC + Neg/Perm/Edge (+ UI states if touches UI) | `/dev-workflow:spec` |
| G2 Conflict | every non-MATCH claim has decision+owner+date | `/dev-workflow:conflict` |
| G3 Plan | task ↔ AC/claim + regression matrix | `/dev-workflow:plan` |
| G4 Open Qs | no OPEN rows in `03-qa-log` | `/dev-workflow:conflict` |
| G5 Build | 100% coverage map + test commands PASS | `/dev-workflow:build` |
| G6 Confirm | AC evidence (How/By) + UI checklist if touches UI | `/dev-workflow:confirm` |
| G7 Ship | `07-ship` + pre-merge | `/dev-workflow:ship` |

Partial confirm → G2/G4 FAIL — do not Build.

WAIVE needs reason + owner + expiry; forbid waive money/permission/legacy unless PM note.
