---
name: conflict
description: >-
  Diff new spec vs running business; surface conflicts/omissions; require written
  Q&A confirms. Resume by passing confirm text after Ticket_ID.
argument-hint: "<Ticket ID> [claim decision text when answering] — find conflicts with existing business; record decisions in the worklog"
arguments: [ticket_id, confirm_text]
disable-model-invocation: false
---

# /dev-workflow:conflict

Apply `references/skill-quality.md` and the type dispatch in `references/stage-contract.md`.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Compare spec to running behavior and force decisions.

**Read `Type:` from INDEX.md (or `01-intent.md` if INDEX.md predates this field) before
investigating anything.** `:spec` already classified this ticket as Bug / New feature / Spec
change / Requirement change — `references/ba-integrity.md` has a *different* investigation
strategy for each (route→controller→service tracing is the **Bug** procedure only; it does not
apply to the other three, see that file's per-type sections). Applying the bug procedure to a
New feature ticket wastes effort hunting for wrong behavior that doesn't exist; applying the
feature procedure to a Bug wastes effort surveying architecture instead of tracing the one broken
path. If `Type:` is missing or was never set, stop and classify it now per `ba-integrity.md`
before proceeding — do not guess a default.

Read `references/conflict-check.md` (full 5-step MAP→DIFF→CONFIRM→LOG process).
Write required artifacts: `03-conflict-README.md`, `03-conflict-report.md`, `03-qa-log.md`.
Classify claims as MATCH/NO/UNCLEAR; request explicit confirm for non-MATCH.

Walk non-MATCH claims with the user using the `grilling` skill's technique — one claim at a
time, recommend an answer, wait for it before the next — instead of dumping the full claim table
for a blanket confirm. This does not replace the required per-claim MATCH/NO/UNCLEAR confirm
above. dev-workflow installs `grilling` automatically if it isn't already present.

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
Never guess claim decisions. Before PASS, print the claim inventory by Type, evidence/truth label,
uncovered consumer/encoding search, and unresolved items. Code alone may be `OBSERVED` but cannot
become MATCH without an intent source or explicit project-baseline decision.
