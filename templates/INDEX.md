# Worklog INDEX: [Ticket_ID]

- **Project slug:** `[project-slug]`
- **Project home:** `workspaces/<project-slug>/`
- **Ticket:** [url]
- **Feature alias:** [name]
- **Owner (Dev):** [name]
- **Updated:** [YYYY-MM-DD]
- **Worklog:** `workspaces/<project-slug>/worklogs/<Ticket_ID>/`
- **Touches UI?** ☐ Yes ☐ No
- **Risk:** ☐ P0 ☐ P1 ☐ P2   (see `references/risk.md`)
- **Lane:** ☐ hard ☐ fast
- **Pilot:** ☐ yes ☐ no   (if yes, G9 requires row in `pilot/PILOT-*.md`)

## Handoff

- **Last stop:** …
- **Waiting on:** ☐ learning  ☐ coaching  ☐ Dev confirm CLAIM #…  ☐ none
- **G3 user sign-off:** ☐ PASS ☐ FAIL
- **Signed off by:** [name]
- **Signed off at:** [YYYY-MM-DD]
- **Human confirm phrase (required):** `CONFIRM G3: <Ticket_ID> <name> <YYYY-MM-DD>`
- **P0 PM phrase (required if P0):** `CONFIRM G3-PM: <Ticket_ID> <pm-name> <YYYY-MM-DD>`

Paste the exact user/PM message below (do not invent):

```
CONFIRM G3: …
```

## Gate status

| Gate | Status | Artifact | Note |
|---|---|---|---|
| G0 Domain knowledge | ☐ PASS ☐ FAIL | `../domain-knowledge/` (+ repos) | empty → `:learning`; wrong/changed → `:coaching` |
| G1 Spec clear | ☐ PASS ☐ FAIL ☐ WAIVE | `02-spec.md` (+ `02b-security.md` if P0) | Scenario AC + Risk; P0 security |
| G2 Conflict documented | ☐ PASS ☐ FAIL ☐ WAIVE | `03-conflict-report.md` | P2 soft unless `--strict` |
| G3 User sign-off | ☐ PASS ☐ FAIL | `INDEX.md` Handoff | requires literal CONFIRM G3: |
| G4 Plan | ☐ PASS ☐ FAIL ☐ WAIVE | `04-plan.md` | task ↔ AC/claim + regression |
| G5 No open Qs | ☐ PASS ☐ FAIL ☐ WAIVE | `03-qa-log.md` | OPEN = FAIL |
| G6 Build+tests | ☐ PASS ☐ FAIL ☐ WAIVE | `05-impl-log.md` | 100% map + tests PASS |
| G7 Review evidence | ☐ PASS ☐ FAIL ☐ WAIVE | `06-review-qa.md` | How/By/Date per AC; UI checklist if touches UI |
| G8 Test evidence | ☐ PASS ☐ FAIL ☐ WAIVE | `06b-test-evidence.md` | machine evidence + zero failing tests |
| G9 Ship safety | ☐ PASS ☐ FAIL ☐ WAIVE | `07-ship.md` | migration / flag / monitor / rollback |

**Build only when G0–G3 PASS (P2: waived gates documented).** Ship when G8+G9 PASS.

## Touched repos (from PROJECT.md — do not hardcode)

- [ ] `<repo-slug>` …
- [ ] …

## Waivers

Format: `Gate/claim | reason | owner | expiry YYYY-MM-DD | PM note?`

- (none)

**Forbidden:** waive G2 money/permission/legacy unless PM notes explicitly.  
**P0:** no WAIVE on G3/G8. **Strict CI:** G8 WAIVE rejected.

## Next action

- [ ] `/dev-workflow:…`
