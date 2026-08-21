---
name: clarify
description: >-
  Diff new spec vs running business; ask a short numbered list of open questions;
  user answers free-text in one message, AI matches answers to claims itself.
argument-hint: "[Ticket ID] [free-text answers when resuming] — find open questions against existing business; record decisions in the worklog. Ticket ID optional, derived if omitted"
arguments: [ticket_id, confirm_text]
disable-model-invocation: false
---

# /dev-workflow:clarify

Apply `references/skill-quality.md` and the type dispatch in `references/stage-contract.md`.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

No Ticket ID given → follow `references/task-isolation.md` "No Ticket ID given": proceed with
this stage normally; only derive an `adhoc-<slug>` worklog name once a decision actually needs
persisting, not before.

Compare spec to running behavior and force decisions.

**Read `Type:` from INDEX.md (or `01-intent.md` if INDEX.md predates this field) before
investigating anything.** `:spec` already classified this ticket as Bug / New feature / Spec
change / Requirement change — `references/ba-integrity.md` has a *different* investigation
strategy for each (route→controller→service tracing is the **Bug** procedure only; it does not
apply to the other three, see that file's per-type sections). Applying the bug procedure to a
New feature ticket wastes effort hunting for wrong behavior that doesn't exist; applying the
feature procedure to a Bug wastes effort surveying architecture instead of tracing the one broken
path. If `Type:` is missing or was never set (e.g. `:clarify` called standalone without `:spec`
having run), classify it now yourself per `ba-integrity.md`'s "Classify the ticket first" section
and record `Type:` (and a minimal Risk) into INDEX.md before proceeding — do not guess a default,
and note `Source: self-analyzed (no upstream :spec)` next to it so later stages know a full `:spec`
pass never happened.

Read `references/clarify-check.md` (full 5-step MAP→DIFF→CONFIRM→LOG process).
Write this ticket's own artifacts: `03-clarify-report.md`, `03-qa-log.md`. `03-clarify-README.md`
is static process documentation (G2 PASS rules, forbidden shortcuts) — read it, do not fill it in
per ticket.
Classify claims as MATCH/NO/UNCLEAR.

**Fast path — every claim already MATCH from `:spec`'s own intent Q&A.** The test is not "did
intent already ask and answer this" (any claim can technically satisfy that) — it is **"is this
claim a near-identical restatement of behavior that already exists and runs in the codebase"**
(a pure analog: same shape as an existing sibling function/endpoint, no new state, no new error
class, no new consumer). A claim that introduces anything genuinely new to the codebase — a new
error class, a new state, a new consumer, a domain rule with no existing precedent — gets the full
report even if intent's Q&A already settled the answer, because the reasoning trail (why this
answer, not just what it is) has real value for whoever reads this ticket later; a one-line MATCH
citation loses that trail. If unsure which case a claim is, default to the full report.

If the ticket has exactly the claim(s) `:spec` already resolved this way, running the full
MAP→DIFF→CONFIRM→LOG conversation would just restate what `01-intent.md` already says — real
ceremony, not real verification, on a ticket this small. Still write all three artifacts (G2 checks
`03-clarify-report.md` exists), but the report may be a one-line-per-claim table citing
`01-intent.md`'s answer as the MATCH evidence directly,
skip the ask/echo conversation in the section below, and `03-qa-log.md`/`03-clarify-README.md` may
stay minimal (no open Q&A to log). The moment any claim is NO/UNCLEAR, or a MATCH needs evidence
`:spec` didn't already establish, drop the fast path and run the full process for that claim.

## Ask once, in plain language — not a form to fill out

Before asking anything, run the **multi-angle BA pass** from `references/ba-integrity.md` on every
non-MATCH claim — user-facing / data-state / consumer angles — so the question you ask is already
the sharp one, not the first draft. A round of follow-ups you could have avoided by thinking harder
up front is exactly the "lan man, tốn tài nguyên" the user is trying to prevent.

Then:

1. Present all non-MATCH claims as a short numbered list — one line each, sharpest form of the
   question, a recommended answer alongside it (same recommend-an-answer instinct the `grilling`
   skill uses; dev-workflow installs `grilling` automatically if not already present). Do not dump
   the full evidence table here — that's already in `03-clarify-report.md` for reference.
2. User replies in **one free-text message** — any order, several claims answered in one sentence,
   some skipped. Do not require the user to echo claim numbers/IDs or answer in a fixed format.
3. Match each answer fragment to the claim(s) it resolves. **Before writing anything**, echo the
   matches back as one short list — `#3 → "delete cascades to applications" (NO→will-fix)`,
   `#5 → skip, unanswered` — so the user can catch a wrong match in one glance. This is one line
   per claim, not a re-ask; do not wait for a reply if the echo is uncontested in the same message
   flow (e.g. the user's next message moves on) — but if the user corrects a match, treat that
   correction as authoritative over your first read and re-echo just that item. Free text is
   genuinely ambiguous sometimes (one answer covering two claims, a qualified "sort of, but only
   if..."); this step exists because a silently wrong match is worse than one extra line of output.
4. Once matches are confirmed (echoed and uncorrected, or explicitly re-confirmed), re-derive each
   claim's decision and write it into `03-clarify-report.md`/`03-qa-log.md` exactly as before
   (`Decision`, `Owner`, `Date`, `Source: user-message`).
5. Claims left unmatched or still genuinely ambiguous after matching → re-ask, but only the
   **remainder**, renumbered, same short format — not the original full list again. Repeat until
   every non-MATCH claim has a decision or an explicit WAIVE.

This reaches the same G2 PASS bar as before (`clarify-check.md` "G2 PASS when") through a
conversation instead of a form — the required per-claim MATCH/NO/UNCLEAR confirm is unchanged,
only how you solicit and record the answer changes. The echo-back in step 3 is what keeps this
free-text flow honest: `Source: user-message` on a `Decision` should mean the user's actual
decision, not the AI's best guess at what they meant. If a claim is genuinely hard to reason about
even after the BA pass, falling back to walking it alone with the `grilling` skill's one-at-a-time
technique is fine — but that's the exception for a hard claim, not the default shape of this step.

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

Any OPEN/UNCLEAR keeps G2/G5 FAIL; `:confirm` won't record a phrase over it, and `:plan`/`:build`
must route back here rather than guess a decision you already flagged as needing one.
Never guess claim decisions. Before PASS, print the claim inventory by Type, evidence/truth label,
uncovered consumer/encoding search, and unresolved items. Code alone may be `OBSERVED` but cannot
become MATCH without an intent source or explicit project-baseline decision.

**Report G2 and G5 as two separate lines, never one combined "clarify PASS."** This stage owns
both gates but they resolve at different times: G2 (each non-MATCH claim has a decision/owner/date)
is met once every claim in `03-clarify-report.md` is classified; G5 (no OPEN Qs) is met once
every entry in `03-qa-log.md` is closed. A ticket can be G2 PASS with G5 still FAIL (a decision is
recorded but its follow-up question is still open) — collapsing both into "clarify done" is exactly
the false-complete signal that sends `:confirm`/`:plan` in on a half-finished ticket. State both,
e.g. `G2: PASS (4/4 claims decided) · G5: FAIL (1 open Q — #3)`.
