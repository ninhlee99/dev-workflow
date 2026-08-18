---
name: start
description: >-
  Full delivery pipeline from first failing gate. Use /dev-workflow:start.
  Stops for human confirm on clarify decisions before plan.
argument-hint: "[Ticket ID] [ticket URL] [spec path or paste] — start full pipeline from first failing gate; Ticket ID optional, derived if omitted and a worklog is needed"
arguments: [ticket_id, url_or_path, extra]
disable-model-invocation: false
---

# /dev-workflow:start

Apply `references/skill-quality.md` and dispatch exclusively from `references/stage-contract.md`.

Dispatch from first failing gate.
Read `references/workflow.md`, `references/project-root.md`, `references/locale.md`, `references/task-isolation.md`.
If this is the first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per
`references/locale.md` before anything else — do not guess from message language. Otherwise read
the already-set `Chat locale` from `domain-knowledge/INDEX.md` and use it silently.
If no Ticket ID was given, follow `references/task-isolation.md` "No Ticket ID given" — proceed
with the pipeline regardless; only derive an `adhoc-<slug>` name once a stage actually needs to
persist a decision/worklog, not before.
Resolve and print `project=<slug> home=<path> ticket=<id-or-adhoc-slug-or-empty> worklog=<path-or-none> locale=<code>`.
Run `bin/check-workspace.sh` once; FAIL → fix layout before gates (this is a workspace-structure
check, not a knowledge-content one — see the G0 note below for the difference).
Ensure worklog is **only** `worklogs/<Ticket_ID>/` — never mix another ticket.

**`:start` never dispatches `:learning` or `:coaching`.** They're independent of this pipeline
(see `references/workflow.md` "Stage order"), not stages `:start` walks through. If G0 FAILs
because domain-knowledge is missing or contradicted, **stop and tell the user** to run `:learning`
or `:coaching` themselves first, then call `:start` again — do not auto-invoke either one on their
behalf. Otherwise, run the first applicable failing owner in the delivery pipeline only:
spec → clarify → confirm → plan → build → review → fix (only justified OPEN findings) → test →
check → ship → audit.

This ordering is enforced by **you reading and following it**, not by a script — `check-gates.sh`
verifies each stage's *output artifact* is real, and every individual stage is independently
runnable (each self-analyzes when its preferred upstream artifact is missing, see
`references/stage-contract.md`). `:start`'s job is to walk the full pipeline in order rather than
leave every stage to self-analyze around every other — dispatching `:build` here always means
routing through `:plan` first (which routes through `:spec`/`:clarify` first), not calling `:build`
standalone and letting it self-analyze a plan on the fly. Follow the order this file says rather
than skipping ahead just because a later stage's own self-sufficiency would technically allow it.

Ask user on ambiguity or clarify decisions; never hardcode paths.
After dispatch, surface the owning stage's evidence and stop condition; do not absorb its
responsibility or continue past a human/failed gate.
