---
name: ship
description: >-
  Fill G9 ship safety (migration/flag/canary/soak/on-call/SLO/rollback).
  Run check --min G9 --strict before merge. Never push unless asked.
argument-hint: "<Ticket ID> Run after test — fill 07-ship and check --min G9 --strict"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:ship

Apply `references/skill-quality.md`; this stage owns deployment-specific safety, not generic N/A ceremony.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

1. Require G8 PASS.
2. **Self-analyzed chain check.** Re-check `02-spec.md`, `03-clarify-report.md`, `04-plan.md` for
   any `Source: self-analyzed` header (`:review` should already have surfaced this at G7, but this
   is the last gate before ship — confirm it wasn't missed or silently accepted). For Risk=P0/P1,
   a self-analyzed upstream stage means this ticket never went through real `:spec`/`:clarify`/
   `:confirm` scrutiny; do not fill `07-ship.md` as if it had. Stop and tell the user: name which
   stage was self-analyzed, and require they explicitly accept the risk (a plain "yes, ship
   anyway" reply, recorded in `07-ship.md`) or route back to run the real stage first. For
   Risk=P2, note it in `07-ship.md` and continue.
3. Fill `07-ship.md` including canary %, soak, on-call, SLO, rollback.
4. P0: ensure `02b-security.md` PASS.
5. Run `/dev-workflow:check <Ticket> [slug] G9` with `--strict`.
6. If in pilot, append row per `references/pilot.md`.
7. Never push/merge unless user explicitly asks.
8. G9 structural PASS is not final for P0/P1 — run `/dev-workflow:audit <Ticket>` next. Structural
   PASS means every field is present and non-placeholder; it does not mean Rollback actually undoes
   Migration or Decision actually answers Proposal. `:audit` catches that gap and requires a real
   human sign-off (`AUDIT CONFIRM:`), not just an AI verdict. P2 may skip audit (note why).
9. After G9 PASS (P0/P1: after `:audit` PASS too), remind: `/dev-workflow:clean <Ticket>` to
   archive worklog (locale: user language). `:clean` itself only requires G9, not audit — a P2
   ticket that skipped audit can still be cleaned.

## 9/10 controls

First select deployment profile: `web/service`, `worker`, `library/package`, `mobile/desktop`,
`docs/config`, or explicit custom. Apply relevant controls; every N/A needs a profile-based reason
and owner. Migration rollback addresses deployed data/schema, not only code. Record rollout/rollback
authority and observable abort signal. Never deploy, push, or merge without explicit authority.
