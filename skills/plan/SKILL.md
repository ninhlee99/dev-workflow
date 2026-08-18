---
name: plan
description: >-
  Break spec+clarify decisions into small tasks with DoD/tests when they exist;
  self-analyzes the ticket directly when they don't. Use /dev-workflow:plan standalone
  or after spec/clarify.
argument-hint: "[Ticket ID] Uses confirmed spec+clarify scope if present, else self-analyzes the ticket — write a TDD-ready implementation plan into the worklog. Ticket ID optional, derived if omitted"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:plan

Apply `references/skill-quality.md`; this stage owns an executable traceability plan, not plausible prose.

## Precondition

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

No Ticket ID given → follow `references/task-isolation.md` "No Ticket ID given": proceed with
this stage normally; only derive an `adhoc-<slug>` worklog name once a decision actually needs
persisting, not before.

Run `/dev-workflow:check <Ticket> [slug] G3` for awareness.
- **PASS** (real `CONFIRM G3:` phrase, no open clarify claim): plan from that confirmed scope, as
  below.
- **FAIL because a clarify claim is still OPEN/unconfirmed**: don't silently resolve it yourself —
  surface it and prefer routing to `:clarify`/`:confirm` over guessing a decision someone already
  flagged as needing a human call.
- **FAIL because `02-spec.md`/`03-clarify-report.md` simply don't exist** (standalone `:plan` call,
  no `:spec`/`:clarify` run): self-analyze the ticket directly — read the ticket text and relevant
  code the way `:spec`/`:clarify` would have — and produce the same task table anyway. Mark
  `04-plan.md`'s header `Source: self-analyzed (no upstream spec/clarify)` so downstream stages
  know this plan wasn't built from a confirmed scope. Still refuse only when there is truly nothing
  to reason from (empty ticket, no description, no diff).

## Steps

Create implementation plan from confirmed scope when available, else from the self-analysis above.
Fill `templates/04-plan.md` for the ticket.
Each task must map to AC/claim, target repo/path, DoD, and test command.

**Task granularity should match the ticket's `Type:`** (see INDEX.md, set at `:spec`):
- **Bug** — usually one focused task at the root-cause location found in `:clarify`; resist
  splitting a single-file fix into multiple tasks just to have more rows.
- **New feature** — one task per layer touched (migration/model, service/operation, controller,
  view, tests), following the insertion points identified in `:clarify`'s survey — do not
  collapse a multi-layer feature into one giant task with no per-layer DoD.
- **Spec change** — one task for the primary behavior change, plus **one task per affected
  consumer** found during `:clarify`'s "trace every consumer" step — each consumer's update needs
  its own DoD/test so a fixed one isn't silently forgotten.
- **Requirement change** — one task per place the rule was found encoded (`:clarify` should have
  listed them) — do not bundle "update the rule everywhere" into a single task; each encoding
  needs its own test proving the new value took effect there specifically.

**Test command must be a real, runnable command** — `bundle exec rspec spec/operations/companies/job_delete_spec.rb`,
not "add tests for this". `check-gates.sh` G4 only verifies the column isn't blank, not that the
command is real; that gap is yours to close as the plan's author, not the checker's — a plan task
with a fake-sounding command passes the machine gate and still leaves `:build` with nothing
concrete to run.

Print uncovered AC/claim gaps; gaps block next stage.
Do not enter build here and do not invent tasks beyond confirmed decisions.

## 9/10 controls

Resolve every test path/repo and perform a non-destructive runner discovery check (`--list`, dry-run,
or an existing neighboring command). If that cannot be checked, label it `UNVERIFIED`, name the
missing dependency, and keep G4 FAIL.
