# 06 Review + QA: [Feature_Name]

- **Date:** [YYYY-MM-DD]
- **Reviewer:** [name/AI]
- **Touches UI?** ☐ Yes ☐ No (copy from `02-spec`)

## Code review (summary)

| Sev | Finding | Fix / accept |
|---|---|---|
| P0/P1/P2 | | |

## AC evidence (required — forbid "ok" only)

One row per AC. G6 FAIL if `How verified` or `By` missing.

| ID | How verified (steps / test / screen) | Actual vs expected | By (Dev / PM) | Date | OK? |
|---|---|---|---|---|---|
| AC-01 | | | | | ☐ |
| NEG-01 | | | | | ☐ |
| PERM-01 | | | | | ☐ |
| EDGE-01 | | | | | ☐ |

## Conflict decisions re-check

| claim_id | Still correct after impl? | Note |
|---|---|---|
| C-01 | ☐ | |

## UI checklist (required if Touches UI = Yes; empty → G6 FAIL)

| State | Verified? | How / screenshot path | Note |
|---|---|---|---|
| Happy | ☐ | | |
| Empty | ☐ | | |
| Loading | ☐ | | |
| Validation error | ☐ | | |
| Server / permission error | ☐ | | |
| Hidden / disabled (no permission) | ☐ | | |
| i18n / copy | ☐ | | |

## Regression matrix

| Legacy module / flow | Repo | Test / manual steps | Result |
|---|---|---|---|
| | | | ☐ PASS ☐ FAIL |

## Side effects

- [ ] Notification / email / job — verified or N/A
- [ ] Permission / authz — verified
- [ ] Validation / error message — verified

## Result

☐ PASS — ready to ship  ☐ FAIL — needs fix (list tasks)

**Forbid G6 PASS** when any AC evidence row lacks How/By, or UI checklist is empty while Touches UI = Yes.
