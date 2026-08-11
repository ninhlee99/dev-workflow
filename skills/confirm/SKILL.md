---
name: confirm
description: >-
  User signs off with anti-spoof phrase CONFIRM G3 before plan.
  P0 also requires CONFIRM G3-PM. Never invent the phrase.
argument-hint: "<Ticket ID> Run after conflict — wait for user CONFIRM G3 phrase"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:confirm

Present conflict decisions and spec deltas; wait for **human** sign-off (G3).

Steps:
1. Read risk from INDEX/spec (`references/risk.md`).
2. List non-MATCH decisions + OPEN questions + spec deltas.
3. Ask user to reply exactly:
   `CONFIRM G3: <Ticket_ID> <name> <YYYY-MM-DD>`
4. If Risk P0, also require PM:
   `CONFIRM G3-PM: <Ticket_ID> <pm-name> <YYYY-MM-DD>`
5. Paste the exact phrases into INDEX (do not fabricate).
6. Set G3 PASS only after phrases recorded; then route to `:plan`.

Never auto-confirm. G2 = documented; G3 = human CONFIRM phrase.
