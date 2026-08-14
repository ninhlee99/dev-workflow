# 05 Impl log: [Feature_Name]

- **Start date:** [YYYY-MM-DD]
- **Commit SHA (at last PASS):** [40-char or short SHA — required for P0/P1/`--strict`]

## G6 PASS rules (required)

G6 PASS only when **all** are true:

1. Every AC / NEG / PERM / EDGE in `02-spec` (and confirmed claims) has a map row below
2. Each row has **real test path** (not blank, not `…`) + **command** + **Result = PASS** (paste summary)
3. No claim/AC left `☐` uncovered
4. Commit SHA above matches `git rev-parse HEAD` at the time of the PASS claim (P0/P1/`--strict`) — a PASS claimed against a stale/wrong SHA is not evidence

Missing map, red tests, blank test path, or SHA mismatch → **G6 FAIL** — no `:review` / `:test` / `:ship`.
A row claiming PASS with an empty Test path is worse than one honestly marked MISSING — it hides that the test never ran.

## Slice log

### Slice [n] — [name]
- **Date:** …
- **Repo:** …
- **Files:** …
- **Tests added/changed:** …
- **RED command + failure excerpt:** …
- **Why RED proves the missing behavior:** …
- **Command:** `bundle exec rspec …` / `npm test …`
- **GREEN result:** ☐ PASS ☐ FAIL — (paste summary)
- **Notes:** …

## Coverage map (claim / AC ↔ test)

| ID (AC/NEG/PERM/EDGE/C-xx) | Test path | Command | Result |
|---|---|---|---|
| AC-01 | | | ☐ PASS ☐ FAIL ☐ MISSING |

## Coverage vs conflict decisions

| Claim / decision | Covered by test/code? | Evidence |
|---|---|---|
| C-01 | ☐ | |

## G6

☐ PASS  ☐ FAIL — missing: …
