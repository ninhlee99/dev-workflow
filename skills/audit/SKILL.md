---
name: audit
description: >-
  Eight-pair semantic coherence audit after check-gates.sh --min G9 --strict PASS.
  Cross-checks worklog artifacts against each other (Decision vs Proposal,
  Rollback vs Migration, etc) — catches content that is structurally valid
  but logically wrong, which regex/awk gates cannot see. Use before treating
  ship as final.
argument-hint: "<Ticket ID> Run after check --min G9 --strict PASS — cross-check worklog coherence before ship is final"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:audit

Apply `references/skill-quality.md`; a missing, UNCLEAR, or INCOHERENT pair can never PASS.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Verify the worklog's own claims agree with each other — not a second code review, not a second
clarify check. Both of those must already have structurally passed.

## Precondition

Refuse to run if `check-gates.sh <Ticket> --min G9 --strict` has not exited 0. Print the command
and ask the user to run it first if unclear.

## Steps

1. Read `references/audit.md` in full — 8 coherence pairs (C1–C8), verdict rules, anti-patterns.
2. Load `02-spec.md` through `07-ship.md` for the ticket.
3. For each pair, quote both sides verbatim before judging. No quote → no verdict. For C2–C4,
   inspect the named assertion/result; topical filename similarity is insufficient.
4. Fill `templates/08-semantic-audit.md` → worklog `08-semantic-audit.md`.
5. Any `INCOHERENT` → print routing table (which stage owns the fix) and stop; do not silently
   patch the audit file to make it pass.
6. Any `UNCLEAR` → ask user directly; do not guess a verdict.
7. When every pair is `COHERENT` or explicit `N/A` with reason, the audit is **AI-complete**, not
   final — ask the human sign-off: `AUDIT CONFIRM: <Ticket> <name> <YYYY-MM-DD>`, same anti-forge
   naming rule as G3 (no AI/tool names). Write it to `08-semantic-audit.md` Sign-off section.
8. Only after human sign-off is recorded, run `check-gates.sh <Ticket> --min AUDIT --strict`; exit 0
   is required before Result PASS or a ship-final claim.

## Why human sign-off is required here specifically

An AI verdict on its own audit is the same blind spot this whole stage exists to catch, one level
up: nothing stops the AI from quoting real text but reasoning dishonestly, or rubber-stamping
COHERENT under time pressure. `:confirm` (G3) already established that business decisions need a
real human phrase, not an AI's word for it — semantic audit is a judgment call of the same kind
(is this rollback actually safe?), so it gets the same anti-forge treatment, not a lighter one.

## Refuse

- Running before G9 structural PASS
- Writing a verdict without both quoted sides
- Marking Result PASS without the human `AUDIT CONFIRM:` phrase recorded
- Treating this as `:review` or `:clarify` re-run (different stages, different question)
