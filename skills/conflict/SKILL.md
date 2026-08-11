---
name: conflict
description: >-
  Diff new spec vs running business; surface conflicts/omissions; require written
  Q&A confirms. Resume by passing confirm text after Ticket_ID.
argument-hint: "<Ticket ID> [claim decision text when answering] — find conflicts with existing business; record decisions in the worklog"
arguments: [ticket_id, confirm_text]
disable-model-invocation: true
---

# /dev-workflow:conflict

Compare spec to running behavior and force decisions.
Read `references/conflict-check.md`.
Write required artifacts: `03-conflict-README.md`, `03-conflict-report.md`, `03-qa-log.md`.
Classify claims as MATCH/NO/UNCLEAR; request explicit confirm for non-MATCH.
Any OPEN/UNCLEAR keeps G2/G4 FAIL and blocks `:plan`/`:build`.
Never guess claim decisions.
