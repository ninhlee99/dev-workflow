---
name: test
description: >-
  Run tests; record machine evidence. Under --strict/P0, checker verifies
  SHA vs git HEAD and junit file contents.
argument-hint: "<Ticket ID> Run after review — fill 06b-test-evidence.md"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:test

1. Fill `06b-test-evidence.md` (output + SHA + CI URL or junit path).
2. Prefer real junit/xml path so `--strict` can parse failures=0.
3. Run `/dev-workflow:check <Ticket> [slug] G8` (add `--strict` before merge path).
4. Zero failing tests required.
