# 02 Spec: [Feature_Name]

- **Spec file:** [path or embedded below]
- **Date:** [YYYY-MM-DD]
- **Confirmed by:** [name]
- **Touches UI?** ☐ Yes ☐ No
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
