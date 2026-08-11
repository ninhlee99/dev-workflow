---
name: ship
description: >-
  Fill 07-ship ship-safety (migration/flag/monitor/rollback) and require G9.
  Does not push/merge unless user asks. Use /dev-workflow:ship.
argument-hint: "<Ticket ID> Run after test — fill ship safety and run check --min G9"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:ship

1. Require G8 PASS first (`/dev-workflow:check … G8`).
2. Fill `templates/07-ship.md` — migration, feature flag, monitor, rollback (G9).
3. Run `/dev-workflow:check <Ticket> [slug] G9` (add `--strict` for CI/P0).
4. Refuse ship if checker fails.
5. Never push/merge unless user explicitly asks.
6. If ticket is in pilot, add row to `pilot-metrics` log.
