# 05 Impl log: [Feature_Name]

- **Start date:** [YYYY-MM-DD]

## G5 PASS rules (required)

G5 PASS only when **all** are true:

1. Every AC / NEG / PERM / EDGE in `02-spec` (and confirmed claims) has a map row below
2. Each row has **test path** + **command** + **Result = PASS** (paste summary)
3. No claim/AC left `☐` uncovered

Missing map or red tests → **G5 FAIL** — no `:confirm` / `:ship`.

## Slice log

### Slice [n] — [name]
- **Date:** …
- **Repo:** …
- **Files:** …
- **Tests added/changed:** …
- **Command:** `bundle exec rspec …` / `npm test …`
- **Result:** ☐ PASS ☐ FAIL — (paste summary)
- **Notes:** …

## Coverage map (claim / AC ↔ test)

| ID (AC/NEG/PERM/EDGE/C-xx) | Test path | Command | Result |
|---|---|---|---|
| AC-01 | | | ☐ PASS ☐ FAIL ☐ MISSING |

## Coverage vs conflict decisions

| Claim / decision | Covered by test/code? | Evidence |
|---|---|---|
| C-01 | ☐ | |

## G5

☐ PASS  ☐ FAIL — missing: …
