---
name: ship
description: >-
  Fill G9 ship safety (migration/flag/canary/soak/on-call/SLO/rollback).
  Run check --min G9 --strict before merge. Never push unless asked.
argument-hint: "<Ticket ID> Run after test — fill 07-ship and check --min G9 --strict"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:ship

1. Require G8 PASS.
2. Fill `07-ship.md` including canary %, soak, on-call, SLO, rollback.
3. P0: ensure `02b-security.md` PASS.
4. Run `/dev-workflow:check <Ticket> [slug] G9` with `--strict`.
5. If in pilot, append row per `references/pilot.md`.
6. Never push/merge unless user explicitly asks.
