---
name: confirm
description: >-
  Confirm AC and conflict decisions with evidence checklist before ship.
  Use /dev-workflow:confirm after build — How/By/Date, not bare ok.
argument-hint: "<Ticket ID> Run only after build — confirm with PM/BA that the result matches original requirements"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:confirm

Confirm outcome against original requirements using evidence.
Fill `templates/06-review-qa.md` with AC/NEG/PERM/EDGE How/By proof (+ UI checklist if UI).
Run `/dev-workflow:check <Ticket> [slug] G6` before any G6 PASS claim.
Missing evidence or checker failure keeps confirm FAIL.
Do not ship from this stage and never invent PASS.
