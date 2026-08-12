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

1. Refuse if `06-review-qa.md` still has P0/P1 Status=`OPEN` — run `/dev-workflow:fix` first.
2. Fill `06b-test-evidence.md` (output + SHA + CI URL or junit path).
3. Prefer real junit/xml path so `--strict` can parse failures=0.
4. Run `/dev-workflow:check <Ticket> [slug] G8` (add `--strict` before merge path).
5. Zero failing tests required.
