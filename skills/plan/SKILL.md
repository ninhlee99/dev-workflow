---
name: plan
description: >-
  Break confirmed spec+conflict decisions into small tasks with DoD/tests.
  Use /dev-workflow:plan only after conflict claims are fully confirmed.
argument-hint: "<Ticket ID> Run only after spec and conflict pass — write a TDD-ready implementation plan into the worklog"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:plan

Apply `references/skill-quality.md`; this stage owns an executable traceability plan, not plausible prose.

## Precondition

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Run `/dev-workflow:check <Ticket> [slug] G3` first. If it FAILs, stop — scope isn't confirmed yet
(no `CONFIRM G3:` phrase, or a conflict claim still open). Planning against unconfirmed scope
produces tasks that get thrown away the moment `:confirm` lands on a different decision — route
the user to `:conflict`/`:confirm` instead of drafting a plan you already know is provisional.

## Steps

Create implementation plan from confirmed scope only.
Fill `templates/04-plan.md` for the ticket.
Each task must map to AC/claim, target repo/path, DoD, and test command.

**Task granularity should match the ticket's `Type:`** (see INDEX.md, set at `:spec`):
- **Bug** — usually one focused task at the root-cause location found in `:conflict`; resist
  splitting a single-file fix into multiple tasks just to have more rows.
- **New feature** — one task per layer touched (migration/model, service/operation, controller,
  view, tests), following the insertion points identified in `:conflict`'s survey — do not
  collapse a multi-layer feature into one giant task with no per-layer DoD.
- **Spec change** — one task for the primary behavior change, plus **one task per affected
  consumer** found during `:conflict`'s "trace every consumer" step — each consumer's update needs
  its own DoD/test so a fixed one isn't silently forgotten.
- **Requirement change** — one task per place the rule was found encoded (`:conflict` should have
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
