# 02 Spec: [Feature_Name]

- **Spec file:** [path or embedded below]
- **Touches UI?** ☐ Yes ☐ No
- **Type:** ☐ Bug ☐ New feature ☐ Spec change ☐ Requirement change ☐ Refactor
- **Risk:** ☐ P0 ☐ P1 ☐ P2   (required — see `references/risk.md`)
- **Touched repos:** ☐ (list from PROJECT.md)

If the full spec lives elsewhere (e.g. `tasks/specs/Feature.md`), link it — do not duplicate unless needed.

## Out of scope

- …

## Requirement provenance

| ID / claim | Truth label | Source + exact quote/location | Verified date | Confidence | Owner if unresolved |
|---|---|---|---|---|---|
| AC-01 | DOCUMENTED / OBSERVED / INFERRED / UNVERIFIED / CONFLICTING | | | high / medium / low | |

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

One row per AC/NEG/PERM/EDGE id above — real field/button labels + a machine-checkable oracle, so
independent QA can build test cases from this file alone. Not blank; not "shows success message".

| ID | Field/action labels (exact, as shown on screen) | Oracle type | Oracle value |
|---|---|---|---|
| AC-01 | e.g. `email` field, `Submit` button | ☐ expected_text ☐ expected_url_includes ☐ expected_result_count ☐ expected_network ☐ other | e.g. "Registration successful" |

`expected_text` = exact text after action. `expected_url_includes` = URL fragment after
nav/redirect. `expected_result_count` = row-count relation (e.g. "≥1"). `expected_network` = API
call (method+path). `other` = describe the machine-checkable signal precisely.

Screen/field not decided yet → `☐ TBD — confirm before :build closes`, never silently blank.

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

| AC / NEG / PERM / EDGE | Has clarify claim? | Has plan task? | Has test (after build)? |
|---|---|---|---|
| AC-01 | ☐ | ☐ | ☐ |

## Links

- Full spec: …
- Intent: `01-intent.md`
