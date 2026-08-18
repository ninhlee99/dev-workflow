---
name: build
description: >-
  TDD then implement. Uses plan/spec/clarify decisions when they exist; self-analyzes
  the ticket directly when they don't. Use /dev-workflow:build standalone or after plan.
argument-hint: "<Ticket ID> Uses confirmed plan if present, else self-analyzes and calls :plan first — implement with TDD and log claim↔test mapping in the worklog"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:build

Apply `references/skill-quality.md`; this stage owns scoped RED→GREEN evidence at the smallest responsible seam.

## Precondition (check before writing a single line of production code)

A Senior dev handed a ticket checks the spec is confirmed before opening an editor — do the same
here, but "checks" doesn't mean "refuses to start without one already on file":

0. If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per
   `references/locale.md` before anything else.
1. Run `/dev-workflow:check <Ticket> [slug] G5` for awareness.
2. If it PASSes, build from the existing `04-plan.md` as normal.
3. If it FAILs because `04-plan.md` doesn't exist yet (standalone `:build` call, no `:plan` run),
   **invoke `:plan` yourself** first — per the composition model, `:build` pulls in the stage it
   needs rather than improvising an implementation with no recorded task breakdown. `:plan` itself
   self-analyzes the ticket when spec/clarify are also missing, so this still works with zero
   upstream artifacts; it just means every task/decision downstream gets marked
   `Source: self-analyzed (no upstream artifact)`.
4. If it FAILs because a plan exists but a clarify claim is still OPEN/unconfirmed, surface that
   gap and prefer routing to `:clarify`/`:confirm` over silently guessing the decision — this is
   the one case where "self-analyze and continue" is the wrong call, since a real open question
   was already raised and left unanswered, not simply skipped.

## Steps

Implement from a plan — either the confirmed one on disk, or the one `:plan` just produced
(confirmed or self-analyzed) per the precondition above.
Read `references/task-isolation.md` — log **only** into `worklogs/<Ticket_ID>/` for this ticket.
Print `project=… ticket=… worklog=… locale=…` at start; refuse empty ticket.

**Use TDD (required, regardless of what's installed).** Per task in `04-plan.md`: write the
failing test from that task's test command first, run it and confirm it fails for the stated
reason (not a setup/syntax error), then implement the minimum to make it pass. This cycle applies
whether or not any other skill is present in the session — do not skip or water it down on a repo
that lacks extra tooling. Log AC/claim-to-test mapping in `templates/05-impl-log.md` under **this**
worklog.

Also invoke the `tdd` skill for a more thorough red-green-refactor treatment (refactor-phase
discipline, project-specific test patterns) on top of the required cycle above — it does not
replace the required cycle. dev-workflow installs `tdd` automatically if it isn't already present.
Fill **Commit SHA** at the top of `05-impl-log.md` with the real commit the PASS claim is made
against — required for P0/P1/`--strict`, same bar as G8's test evidence. A PASS recorded with no
SHA, or against a stale one, is not verifiable evidence.
Do not edit another ticket’s impl log or reuse its PASS marks.
Run `/dev-workflow:check <Ticket> [slug] G6` before any G6 PASS claim.
Coverage gaps, failing tests, or missing/stale Commit SHA keep build FAIL.
Never invent PASS; never invent a confirmed decision — a self-analyzed plan may proceed to code,
but a clarify claim someone already flagged OPEN may not be silently resolved by `:build`.
Chat in user language (`references/locale.md`).

## 9/10 controls

For every task record the RED command/failure, why it proves missing behavior, GREEN command/result,
and files changed. Existing-green tests do not prove TDD. New scope or a contradicted confirmed claim
routes upstream; never edit AC to fit code.
