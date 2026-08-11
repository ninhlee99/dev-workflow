---
name: confirm
description: >-
  User reviews and signs off on conflict decisions and spec changes before plan.
  Lists all open questions, non-MATCH decisions, and spec deltas for user to confirm.
argument-hint: "<Ticket ID> Run after conflict — present decisions for user sign-off before plan"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:confirm

Present conflict decisions and spec changes to user for explicit sign-off (G3).

Steps:
1. Read `03-conflict-report.md` — list every non-MATCH decision with status.
2. Read `03-qa-log.md` — list any OPEN questions.
3. Read `02-spec.md` — summarize spec changes vs original ticket.
4. Ask user to confirm each decision; update decisions where user corrects.
5. Mark OPEN questions as ANSWERED or escalate.
6. When user signs off: set `G3 user sign-off: ☑ PASS`, `Signed off by`, `Signed off at` on `INDEX.md` Handoff.
7. Only then PASS G3 and route to `:plan`.

Block forward if any decision is still OPEN or user disagrees.
Never auto-confirm — always wait for explicit user response.
G2 = conflict documented; G3 = user signed off. Do not conflate.
