---
name: review
description: >-
  Fill acceptance evidence table after build. Verify each AC/NEG/PERM/EDGE
  has How/By/Date proof. UI checklist required if ticket touches UI.
argument-hint: "<Ticket ID> Run after build — fill evidence table in 06-review-qa.md"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:review

Verify outcome against original requirements using evidence (G7).
Fill `templates/06-review-qa.md` with AC/NEG/PERM/EDGE How/By proof (+ UI checklist if UI).
Run `/dev-workflow:check <Ticket> [slug] G7` before any G7 PASS claim.
Missing evidence or checker failure keeps review FAIL.
Do not ship from this stage and never invent PASS.
