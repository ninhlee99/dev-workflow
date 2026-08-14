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
7. G9 structural PASS is not final for P0/P1 — run `/dev-workflow:audit <Ticket>` next. Structural
   PASS means every field is present and non-placeholder; it does not mean Rollback actually undoes
   Migration or Decision actually answers Proposal. `:audit` catches that gap and requires a real
   human sign-off (`AUDIT CONFIRM:`), not just an AI verdict. P2 may skip audit (note why).
8. After G9 PASS (P0/P1: after `:audit` PASS too), remind: `/dev-workflow:clean <Ticket>` to
   archive worklog (locale: user language). `:clean` itself only requires G9, not audit — a P2
   ticket that skipped audit can still be cleaned.
