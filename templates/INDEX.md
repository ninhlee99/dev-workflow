# Worklog INDEX: [Ticket_ID]

- **Project slug:** `[project-slug]`
- **Project home:** `workspaces/<project-slug>/`
- **Ticket:** [url]
- **Feature alias:** [name]
- **Owner (Dev):** [name]
- **Updated:** [YYYY-MM-DD]
- **Worklog:** `workspaces/<project-slug>/worklogs/<Ticket_ID>/`
- **Touches UI?** ☐ Yes ☐ No

## Handoff

- **Last stop:** …
- **Waiting on:** ☐ learning  ☐ coaching  ☐ Dev confirm CLAIM #…  ☐ none

## Gate status

| Gate | Status | Artifact | Note |
|---|---|---|---|
| G0 Domain knowledge | ☐ PASS ☐ FAIL | `../domain-knowledge/` (+ repos) | empty → `:learning`; wrong/changed → `:coaching` |
| G1 Spec clear | ☐ PASS ☐ FAIL ☐ WAIVE | `02-spec.md` | Scenario AC + Neg/Perm/Edge; UI if touches UI |
| G2 Conflict confirmed | ☐ PASS ☐ FAIL ☐ WAIVE | `03-conflict-report.md` | every non-MATCH has a decision |
| G3 Plan | ☐ PASS ☐ FAIL ☐ WAIVE | `04-plan.md` | task ↔ AC/claim + regression |
| G4 No open Qs | ☐ PASS ☐ FAIL ☐ WAIVE | `03-qa-log.md` | OPEN = FAIL |
| G5 Build+tests | ☐ PASS ☐ FAIL ☐ WAIVE | `05-impl-log.md` | 100% map + tests PASS |
| G6 Confirm | ☐ PASS ☐ FAIL ☐ WAIVE | `06-review-qa.md` | evidence + UI if touches UI |
| G7 Ship | ☐ PASS ☐ FAIL ☐ WAIVE | `07-ship.md` | `:ship` |

**Build only when G0–G4 PASS.** G5 needs evidence.

## Touched repos (from PROJECT.md — do not hardcode)

- [ ] `<repo-slug>` …
- [ ] …

## Waivers

Format: `Gate/claim | reason | owner | expiry YYYY-MM-DD | PM note?`

- (none)

**Forbidden:** waive G2 money/permission/legacy unless PM notes explicitly.

## Next action

- [ ] `/dev-workflow:…`
