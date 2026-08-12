# 06 Review + QA: [Feature_Name]

- **Date:** [YYYY-MM-DD]
- **Reviewer:** [name/AI]
- **Touches UI?** ☐ Yes ☐ No (copy from `02-spec`)
- **Diff basis:** [base…HEAD / PR url / commit range]

## Code review stance

- [ ] Diff opened (not memory / not “framework usually…”)
- [ ] Findings cite `path:line` or hunk
- [ ] Read `references/code-review.md`

## Defect class sweep (required — write `none` if clean)

| Class | Hits? | Notes |
|---|---|---|
| 500 / crash / unhandled | ☐ none ☐ hit | |
| missing (validation / branch / authz / UI state) | ☐ none ☐ hit | |
| injection / unsafe input | ☐ none ☐ hit | |
| case / normalize (`downcase`/`upcase`/fold) | ☐ none ☐ hit | |
| other high-signal | ☐ none ☐ hit | |

## Code review findings

| ID | Sev | Class | Location | Evidence (from diff) | Risk if shipped | Fix proposal | Status |
|---|---|---|---|---|---|---|---|
| R-01 | P0/P1/P2 | 500/missing/injection/case/other | path:line | | | | OPEN |

Status values: `OPEN` → `:fix` triages to `FIXED` / `SKIPPED` / `DEFERRED`.

**G7 Result FAIL** while any P0/P1 is `OPEN`. Next: `/dev-workflow:fix <Ticket>`.

## AC evidence (required — forbid "ok" only)

One row per AC. G7 FAIL if `How verified` or `By` missing.

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

## UI checklist (required if Touches UI = Yes; empty → G7 FAIL)

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

☐ PASS — ready for `:test`  ☐ FAIL — needs `:fix` or more evidence

**Forbid G7 PASS** when: any P0/P1 finding `OPEN`; any AC evidence row lacks How/By; UI checklist empty while Touches UI = Yes.
