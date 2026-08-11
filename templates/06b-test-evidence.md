# 06b Test Evidence: [Feature_Name]

- **Date:** [YYYY-MM-DD]
- **Tested by:** [name/AI]
- **Ticket:** [ID]
- **Touches UI?** ☐ Yes ☐ No (copy from `02-spec`)
- **Risk:** ☐ P0 ☐ P1 ☐ P2

## Machine evidence (required for P0/P1 and `--strict`)

| Field | Value |
|---|---|
| Commit SHA | [40-char or short SHA] |
| CI run URL | [https://… or N/A-local] |
| JUnit / XML / log path | [path or URL] |
| Branch | [name] |

**Forbid G8 PASS** when any required machine field is empty/`[…]` placeholder (P0/P1/`--strict`).

## Test run output

Paste raw output (or representative excerpt) from test runner here.

```
# paste test runner output here
```

## Screenshots / recordings

List paths or embed inline for any UI-touching AC. Leave N/A if no UI.

| AC / scenario | File / URL | Notes |
|---|---|---|
| AC-01 | | |

## Failing / passing summary

One row per test suite. G8 FAIL if any suite has failures.

| Suite | Total | Passed | Failed | Skipped | Result |
|---|---|---|---|---|---|
| Unit | | | | | ☐ PASS ☐ FAIL |
| Integration | | | | | ☐ PASS ☐ FAIL |
| E2E | | | | | ☐ PASS ☐ FAIL |

**Overall:** ☐ PASS (zero failures) ☐ FAIL (see failing rows above)

## Sign-off

- **Dev:** [name]
- **Date:** [YYYY-MM-DD]
- **G8 verdict:** ☐ PASS ☐ FAIL

**Forbid G8 PASS** when any suite has failures or the evidence table is empty.
