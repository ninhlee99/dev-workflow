# 06b Test Evidence: [Feature_Name]

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

## Executed-command ledger

One row per distinct command in `04-plan.md` and PASS command in `05-impl-log.md`.

| Command | Repo / cwd | Started / ended | Exit | Artifact | Covered IDs | Supersedes |
|---|---|---|---|---|---|---|
| | | | | | | N/A |

## Assertion evidence

| ID | Test path:line / assertion | Failure proved before fix | Passing result after fix |
|---|---|---|---|
| AC-01 | | | |

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
- **G8 verdict:** ☐ PASS ☐ FAIL

**Forbid G8 PASS** when any suite has failures or the evidence table is empty.
