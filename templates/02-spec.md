# 02 Spec: [Feature_Name]

- **Spec file:** [path or embedded below]
- **Date:** [YYYY-MM-DD]
- **Confirmed by:** [name]
- **Touches UI?** ☐ Yes ☐ No
- **Risk:** ☐ P0 ☐ P1 ☐ P2   (required — see `references/risk.md`)
- **Touched repos:** ☐ (list from PROJECT.md)

If the full spec lives elsewhere (e.g. `tasks/specs/Feature.md`), link it — do not duplicate unless needed.

## Out of scope

- …

## Scenario AC (required — G1 FAIL if missing)

One AC per row. Format:

`AC-xx | Given … | When … | Then … | Repo (api/fe/legacy)`

| ID | Given | When | Then | Repo |
|---|---|---|---|---|
| AC-01 | | | | |
| AC-02 | | | | |

## Negative / Error

| ID | Trigger | Expected error / behavior | Repo |
|---|---|---|---|
| NEG-01 | | | |

## Permission / Authz

| ID | Actor / role | Action | Allowed? | Notes |
|---|---|---|---|---|
| PERM-01 | | | ☐ Yes ☐ No | |

## Edge cases

| ID | Edge | Expected | Repo |
|---|---|---|---|
| EDGE-01 | | | |

## QA handoff — testable oracle (required if Touches UI = Yes)

Independent QA (e.g. `qa-intelligence`) builds test cases from this spec **without asking the
dev anything** — it will not invent field names or success criteria from business prose alone.
"When submits form, Then sees success message" is not enough; it cannot be bound to a real page
element or checked by a machine. This section closes that gap: name the **real** field/button
labels a user would see and the **exact, machine-checkable** signal for each Given/When/Then row.

One row per AC/NEG/PERM/EDGE id above. Do not leave any row blank if Touches UI = Yes.

| ID | Field/action labels (exact, as shown on screen) | Oracle type | Oracle value |
|---|---|---|---|
| AC-01 | e.g. `email` field, `Submit` button | ☐ expected_text ☐ expected_url_includes ☐ expected_result_count ☐ expected_network ☐ other | e.g. "Registration successful" |

**Oracle type meanings** (match `qa-intelligence`'s binding model, see `expert-tester-workflow.md`
G2→G3 if that plugin is installed — this table stays useful even without it, since "what text
proves this worked" is a question any tester, human or AI, needs answered):

- `expected_text` — exact text that must appear after the action
- `expected_url_includes` — URL fragment after navigation/redirect
- `expected_result_count` — list/table row count relation (e.g. "≥1 result")
- `expected_network` — API call that must fire (method + path)
- `other` — state not covered above; describe the machine-checkable signal precisely

**Bad (rejected, not bindable):** "Search returns correct results for keyword X."
**Good (bindable):** Field `キーワード` filled with "python", click `検索`, oracle
`expected_result_count`: role=listitem, relation=gte, value=1.

If a screen/field name is not yet decided (spec written before UI design), mark the row
`☐ TBD — confirm before :build closes` — do not fabricate a name or leave the row silently
empty; an empty row and a deliberately-deferred row look identical to a downstream reader
otherwise, which defeats the point of this table.

## UI states (required if Touches UI = Yes)

| State | Screen / component | Expected copy / behavior |
|---|---|---|
| Happy | | |
| Empty | | |
| Loading | | |
| Validation error | | |
| Server / permission error | | |
| Hidden / disabled (no permission) | | |

## Coverage gap ritual (print at end of `:spec` — for Dev)

| AC / NEG / PERM / EDGE | Has conflict claim? | Has plan task? | Has test (after build)? |
|---|---|---|---|
| AC-01 | ☐ | ☐ | ☐ |

## Links

- Full spec: …
- Intent: `01-intent.md`
