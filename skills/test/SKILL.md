---
name: test
description: >-
  Run real tests and record evidence (output, screenshots, logs) as proof before ship.
  Fill 06b-test-evidence.md. Gate G6.5: no failing tests + evidence recorded.
argument-hint: "<Ticket ID> Run after review — record test evidence in 06b-test-evidence.md"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:test

Run actual tests and capture evidence before check/ship.

## Purpose

Bridge between review (G6) and check (G7-path): capture real test run output, screenshots,
recordings, and logs as durable proof. G6.5 PASS requires all tests green and evidence filled.

## Steps

1. Read `templates/06b-test-evidence.md` and open or create the ticket's `06b-test-evidence.md`.
2. Run the full test suite (unit + integration + e2e if applicable).
3. Paste **raw test output** (or a trimmed but representative excerpt) into *Test run output*.
4. Attach screenshot/recording paths or inline base64 for any UI-touching AC.
5. Fill the *Failing / passing summary* table — one row per suite.
6. Confirm there are zero failing tests; if any fail, STOP and report — do not advance to check.
7. Fill *Sign-off* block (Dev name + date).
8. Update worklog `INDEX.md` gate row G6.5 → PASS (or FAIL with reason).

## Gate G6.5

| Condition | Result |
|---|---|
| All test suites pass AND evidence table filled | PASS |
| Any failing test | FAIL — fix before check |
| Evidence table empty or missing | FAIL — fill before check |

WAIVE allowed only in worklog INDEX with full five-field entry. No waive if failing tests exist.

## References

- `references/workflow.md` — gate table and dispatch rules
- `templates/06b-test-evidence.md` — artifact template
