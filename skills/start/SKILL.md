---
name: start
description: >-
  Default entry point. One deep analysis pass, one collapsed confirm, then
  continuous dispatch through the pipeline to the first genuine stop (a
  P0/P1 finding, an unresolved clarify claim, or ship/audit — always manual).
  Use /dev-workflow.
argument-hint: "[Ticket ID] [ticket URL] [spec path or paste] — analyze once, ask once, then run to the first real stop; Ticket ID optional, derived if omitted"
arguments: [ticket_id, url_or_path, extra]
disable-model-invocation: false
---

# /dev-workflow

Apply `references/skill-quality.md` and dispatch exclusively from `references/stage-contract.md`.

## What this is, in one line

Same pipeline, same gates, same evidence bar as calling every
`/dev-workflow:<stage>` command by hand in order — the only thing this stage
optimizes is **how many times the user is interrupted**, not what gets
verified or skipped. Nothing here weakens G0–G9/AUDIT; each stage it dispatches
still owns its own real PASS/FAIL. Prefer this over calling stages one at a
time by hand; call a named stage directly only when you want manual control
of one specific step.

## Step 0 — preflight and routing

Read `references/workflow.md`, `references/project-root.md`,
`references/locale.md`, `references/task-isolation.md`,
`references/epic-signal.md`.
If this is the first `/dev-workflow:*` command in this workspace, ask
`[LOCALE]` per `references/locale.md` before anything else — do not guess
from message language. Otherwise read the already-set `Chat locale` from
`domain-knowledge/INDEX.md` and use it silently.
If no Ticket ID was given, follow `references/task-isolation.md` "No Ticket ID
given" — proceed regardless; only derive an `adhoc-<slug>` name once a stage
actually needs to persist a decision/worklog, not before.
Resolve and print `project=<slug> home=<path> ticket=<id-or-adhoc-slug-or-empty> worklog=<path-or-none> locale=<code>`.
Run `bin/check-workspace.sh` once; FAIL → fix layout before gates.
Ensure worklog is **only** `worklogs/<Ticket_ID>/` — never mix another ticket.

**Epic check.** Read `references/epic-signal.md` and apply it now, while
running step 1's investigation below, before the question list visibly
balloons — this file is the only source for the signal and the numeric
backstop; do not restate either here.

Otherwise this is one ticket (any size) — continue below.

**`:start` never dispatches `:learning` or `:coaching`.** They're independent
of this pipeline (see `references/workflow.md` "Stage order"). If G0 FAILs
because domain-knowledge is missing or contradicted, **stop and tell the
user** to run `:learning`/`:coaching` themselves first, then call `:start`
again — never auto-invoke either on their behalf.

## Step 1 — one deep analysis pass, before asking anything

This is the step that makes stopping-once possible later — do not shortcut
it to get to code faster; a shallow pass here is exactly what forces a
second, third, fourth round of questions mid-build, which is what this step
exists to prevent.

1. Classify `Type:` (Bug / New feature / Spec change / Requirement change —
   `references/ba-integrity.md`) and run **that type's actual investigation
   strategy** — reproduce-and-trace for Bug, closest-analog survey for New
   feature, before/after-and-every-consumer for Spec change, every-encoding
   for Requirement change. Do not skip straight to writing tasks.
2. Run the duplicate-scan (`ba-integrity.md` "Duplicate-scan") regardless of
   Type/Risk — same text/logic elsewhere is a real question, not an
   afterthought.
3. Set Risk per `references/risk.md`. If it touches money/authz/PII/legacy →
   P0, and **P0 always gets the full stop-by-stop flow below, never the
   collapsed one** — this step's speed is for P1/P2, not a way to rush a P0
   change.
4. Run the multi-angle BA pass (`ba-integrity.md` "Multi-angle BA pass" —
   user-facing / data-state / consumer angles) on every claim that isn't a
   clean MATCH against an independent source. The test from that section
   applies at full strength: *"if the user answers this literally as asked,
   would I immediately need to ask a second question?"* — if yes, fold it
   into the same question now.
5. Identify what genuinely cannot be resolved without the user or a named
   business authority — a NO/UNCLEAR claim, an ambiguous requirement, a
   decision only a PM/domain owner can make. Everything else — an
   INFERRED-with-high-confidence claim backed by a real analog, a MATCH
   against independent evidence, a mechanical task breakdown — proceed on
   without asking; record the inference and its evidence so the user can
   correct it later instead of being asked to pre-approve it now.

**Fast-path.** If step 1 finds the ticket genuinely tiny and non-behavioral
(single-file, no logic/API/data-shape change — copy text, a config value, a
comment, a label, a constant), say so once and offer the shortcut instead of
silently deciding for the user: `"Việc này nhỏ, không đổi hành vi (Risk=P2
candidate) — chạy :build <Ticket> luôn (tự phân tích, bỏ qua spec/clarify)?
Nói 'full pipeline' nếu bạn muốn qua đủ từng gate."` Wait for their answer.
Never offer this if the ticket touches money/authz/PII/legacy or changes
user-visible behavior/API contract — dispatch the full flow below instead.

## Step 2 — the one stop (skipped only by the fast-path above)

Present, in a single message:
- Verdict: Type, Risk, one-paragraph scope.
- Every finding from `ba-integrity.md`'s "actively look for" list that
  applies (old-spec-vs-new conflict, documented-vs-actual mismatch,
  fix-only-patches-symptom) — say these plainly, not buried in a table.
- The numbered list of genuine open questions from step 1.5, sharpest form,
  with a recommended answer next to each — this list should be short
  precisely because step 1 already resolved everything resolvable without a
  human.
- What proceeds automatically once answered: spec → clarify →
  confirm-line-only → plan → build → review → (fix if needed) → test →
  check, then stop again before ship/audit.

User replies once, free text, any order — same matching/echo discipline as
`skills/clarify/SKILL.md` "Ask once, in plain language": echo the matches
before writing anything, re-ask only genuinely unmatched items.

**This is the only planning-phase stop for P1/P2.** Once every question here
is resolved, do not re-open discussion mid-build unless build/review surfaces
something step 1's analysis could not have found (a contradicted confirmed
claim, new scope discovered only once code is touched) —
`skills/build/SKILL.md` already requires routing upstream rather than
guessing in that case; this does not override that safety, it just means the
*normal* path doesn't hit it.

## Step 3 — confirm

Once step 2's questions are resolved, dispatch `skills/confirm/SKILL.md`
directly — its simplified reply path (a name, "ok <name>", "đồng ý, <name>"
is enough; it composes and shows back the exact line, no verbatim retype
required) applies the same way here as it does when the user calls
`/dev-workflow:confirm` by hand. Nothing to duplicate here.

Risk=P2: still offer the existing skip (`skills/confirm/SKILL.md`'s P2 fast
path) in the same message as the line, so the user picks once: send the name,
or say "skip".

## Step 4 — run to the next real stop, without re-asking settled things

Dispatch in order: plan → build → review → fix (only if P0/P1 OPEN) → test →
check. Each stage still does its own required work in full (TDD, real diff
review, real test execution, real checker run) — nothing here shortens what
an individual stage owes; it only removes the *user* having to type the next
command each time. Print each stage's normal verdict/evidence as it
completes — this optimizes stop count, not visibility into what happened.

This ordering is enforced by **you reading and following it**, not by a
script — `check-gates.sh` verifies each stage's *output artifact* is real,
and every individual stage is independently runnable (each self-analyzes
when its preferred upstream artifact is missing, see
`references/stage-contract.md`). Dispatching `:build` here always means
routing through `:plan` first (which routes through `:spec`/`:clarify`
first), not calling `:build` standalone and letting it self-analyze a plan
on the fly.

Stop immediately, mid-sequence, on any of:
- A P0/P1 review finding still OPEN after `:fix` triage.
- `:build` or `:plan` hitting a clarify claim someone flagged OPEN that step
  1 didn't (and per `skills/build/SKILL.md`, must not guess).
- Any gate FAIL that isn't P2-soft.

## Step 5 — ship and audit stay manual stops

`:ship` (G9) and `:audit` (AUDIT) are never auto-dispatched, even after
check PASS. Both require a human decision this stage cannot supply on the
user's behalf — G9 rollout/rollback judgment, AUDIT sign-off. Report check
PASS and hand back exactly `/dev-workflow:ship <Ticket>` as the next
command.

## Forbid

- Skipping step 1's real investigation to reach step 2's single stop faster —
  a shallow question list that needs a second round defeats the whole point.
- Treating "fewer stops" as license to lower evidence bars any gate already
  requires — `check-gates.sh` is unchanged and still the source of truth.
- Auto-composing a `CONFIRM G3:` line the user never actually agreed to; step
  3's simplification is about typing less, not proving less.
- Running this on a P0 ticket as if it were P1/P2 speed — P0 keeps every
  existing hard requirement (dual CONFIRM, no G3/G8 WAIVE, CI-native
  evidence).
- Absorbing an owning stage's responsibility or continuing past a
  human/failed gate.
