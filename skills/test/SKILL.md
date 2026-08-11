---
name: test
description: >-
  Run real tests and record evidence (output, screenshots, logs) as proof before ship.
  Fill 06b-test-evidence.md. Gate G8: no failing tests + evidence recorded.
argument-hint: "<Ticket ID> Run after review — record test evidence in 06b-test-evidence.md"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:test

Run actual tests and capture evidence before check/ship (G8).

## Steps

1. Open or create ticket `06b-test-evidence.md` from `templates/06b-test-evidence.md`.
2. Run full test suite (unit + integration + e2e if applicable).
3. Paste raw test output into *Test run output* (no placeholder).
4. Attach screenshot/recording paths for any UI-touching AC.
5. Fill *Failing / passing summary* — one row per suite.
6. Zero failing tests required; else STOP.
7. Fill *Sign-off* (Dev + date) and set G8 verdict PASS.
8. Update worklog `INDEX.md` G8 → PASS.
9. Run `/dev-workflow:check <Ticket> [slug] G8` before claiming PASS.

## Gate G8

| Condition | Result |
|---|---|
| All suites pass AND evidence filled | PASS |
| Any failing test | FAIL |
| Evidence empty / placeholder | FAIL |

WAIVE only via INDEX five-field entry. `--strict` rejects G8 WAIVE.
