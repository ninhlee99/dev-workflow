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

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Compare spec to running behavior and force decisions.
Read `references/conflict-check.md` (full 5-step MAP→DIFF→CONFIRM→LOG process).
Write required artifacts: `03-conflict-README.md`, `03-conflict-report.md`, `03-qa-log.md`.
Classify claims as MATCH/NO/UNCLEAR; request explicit confirm for non-MATCH.

## What a claim looks like (don't skip straight to the report table)

```
Spec says: "When a company deletes a job, related applications are hidden too."

Claim: "Application status flips to :hidden when its Job is deleted."
Code found: app/operations/companies/job_delete.rb:18 — deletes Job only
            (sets deleted_at), does not touch Application at all.
Classify: NO — spec asks for new behavior, current code doesn't do it.
```

A claim that can't be turned into a one-sentence, file:line-checkable statement like this is
itself the ambiguity to surface — don't force-fit it into MATCH just to move on.

Any OPEN/UNCLEAR keeps G2/G5 FAIL and blocks `:confirm`/`:plan`/`:build`.
Never guess claim decisions.
