---
name: test
description: >-
  Run real tests; record output plus machine evidence (CI URL, SHA, junit).
  Gate G8. Required for P0/P1 and --strict.
argument-hint: "<Ticket ID> Run after review — fill 06b-test-evidence.md with machine evidence"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:test

Capture durable + machine-verifiable test proof (G8).

1. Fill `06b-test-evidence.md` from template.
2. Run suites; paste raw output (no placeholder).
3. Fill machine evidence table: Commit SHA, CI run URL (or N/A-local), junit/xml/log path.
4. UI tickets: screenshot paths required (P0/`--strict`).
5. Overall PASS only if zero failures.
6. Run `/dev-workflow:check <Ticket> [slug] G8` before claiming PASS.
