---
name: decompose
description: >-
  Split one large/epic request into isolated child tickets before any of them
  enters the pipeline. Surfaces every risk, dependency, and open question up
  front in one pass so the user confirms once, not once per child ticket.
  Use /dev-workflow:decompose. Never runs :spec/:clarify itself.
argument-hint: "<epic description or path> — analyze scope, propose child tickets + dependencies + risks, wait for one confirm before any child worklog opens"
arguments: [epic_description]
disable-model-invocation: false
---

# /dev-workflow:decompose

Apply `references/skill-quality.md`. This stage owns **splitting decisions and
the up-front risk/question map**; it does not own any child ticket's spec,
clarify, or code.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per
`references/locale.md` before anything else.

## When to run this

- User calls `/dev-workflow:decompose <description>` directly on a request too
  big for one worklog (touches multiple modules/services, mixes ticket Types,
  or would need its own epic-tracking to stay isolated per `task-isolation.md`).
- `:start`/`:spec` detect the same shape and offer this stage instead of
  silently opening one oversized worklog — offer, never auto-run.

**Signal it's an epic, not one ticket:** two or more of — spans >1
service/repo, mixes ticket Type (Bug + New feature, etc. — see
`references/ba-integrity.md` "Classify the ticket first"), described
deliverable has independently shippable parts, or the requester already used
the word "epic"/"dự án"/"nhiều phần". One file, one Type, one deliverable is
**not** an epic — say so and route to `:spec`/`:start` directly instead of
manufacturing a split.

## Steps

1. **Read the whole request before splitting anything.** Do not start
   proposing child tickets from the first paragraph — read the full
   description/brief, and skim `domain-knowledge/` for constraints that bound
   how it can be split (existing module boundaries, service ownership).

2. **One analysis pass, not incremental discovery.** Per
   `references/skill-quality.md` "Plan-first discipline" — enumerate the full
   scope in one pass. For every natural sub-part, work out now, not later:
   - Proposed child ticket name + one-line scope. If the epic itself came in
     without a real tracker ID, derive each child's name as an `adhoc-<slug>`
     per `references/task-isolation.md` "No Ticket ID given" (2–5 words,
     kebab-case, drawn from that child's own subject) — same convention a
     bare `:start`/`:spec` call would use, so each child's worklog folder is
     unambiguous the moment `:spec`/`:start` opens it. If the user later
     supplies real tracker IDs for one or more children, rename those
     folders per that same section instead of keeping the adhoc name.
   - `Type:` per `references/ba-integrity.md` (Bug / New feature / Spec
     change / Requirement change) — a mixed epic almost always produces
     children of different Types; do not force one Type onto all of them.
   - `Risk:` first guess per `references/risk.md` (money/authz/PII/legacy →
     P0; user-visible behavior/API → P1; else P2). This is a starting
     estimate — `:spec` on each child still sets the real Risk from its own
     investigation; do not treat this as final.
   - **Dependency**: does this child require another child's schema/API/data
     shape to exist first? Record it as `blocks` / `blocked by`, not prose.
   - **Concrete risk or difficulty** you can already see from this read alone
     — a migration with no obvious rollback, a consumer you're not sure
     exists, a shared table two children both touch. Write it down now even
     if unconfirmed; this is exactly what the whole pass exists to surface
     before anyone opens an editor.

3. **Run the multi-angle BA pass once, across the whole epic** (per
   `references/ba-integrity.md` "Multi-angle BA pass") — user-facing,
   data/state, consumer angles — but at the epic level: what does the
   business need confirmed before *any* child can safely start, not
   per-child trivia. This is the one place this stage is allowed to ask
   business questions directly, instead of deferring them to each child's own
   `:clarify` — the entire point is that the user answers epic-shaping
   questions **once**, before ten children each ask a smaller version of the
   same thing.

4. **Present one summary, not a form:**
   - A short table: child ticket, Type, Risk (estimate), depends-on.
   - A short numbered list of open questions that decide *how the epic is
     split* or *whether a child is even needed* — not implementation
     questions (those stay with each child's own `:clarify`). Example of the
     right altitude: "Trả phí theo tenant hay theo user trong tenant?" (shapes
     which children exist). Wrong altitude: "nút Save màu gì?" (belongs to a
     child's own `:spec`).
   - State plainly which children are P0/P1 (hard lane, full G0–G9+AUDIT,
     no shortcuts) versus P2 candidates — so the user isn't surprised later
     by how heavy a given child turns out to be.

5. **Wait for one confirm covering the whole split** — free-text reply is
   fine, matched the same way `:clarify`'s "Ask once" step matches answers:
   echo the match back before writing anything. This confirm authorizes the
   *split and question answers*; it is not a `CONFIRM G3:` phrase and does
   not substitute for any child's own G3 — each child still gets its own
   human confirm at its own Risk tier (`references/risk.md`; P0 children still
   need dual CONFIRM, no batching across children for P0).

6. **Write `epic-map.md` at the project level**, not inside any one ticket's
   worklog (`~/.workspaces/<project-slug>/epic-map/<epic-slug>.md` — sibling
   to `worklogs/`, per `references/project-root.md`'s layout, so it isn't
   mistaken for one ticket's artifact and isn't deleted by `:clean <ticket>`).
   Contents: child ticket table (name, Type, Risk estimate, depends-on,
   status — updates as children progress), the epic-level questions and their
   answers with `Source: user-message`, and the split rationale.

7. **Cross-check the dependency graph with a duplicate-scan before handing
   off**, once `blocks`/`blocked by` edges from step 2 are on paper — apply
   `references/ba-integrity.md`'s duplicate-scan across the *whole child
   list*, not one ticket at a time: for every child A that writes a
   field/contract another child B is recorded as depending on, actually
   search whether B (or any other child not yet listed as depending on A)
   also reads/encodes that same field/contract elsewhere. This catches an
   edge the epic-level read missed, not just confirms the edges already
   written down. Record any edge this finds as a **draft** addition to the
   table (`Source: duplicate-scan, unconfirmed`) — do not silently add it as
   fact. A human still reviews the full graph before the first child starts;
   this step narrows that review to confirming/rejecting scan-found edges
   instead of finding them from a blank page.

8. **Hand back exactly one next command**: the first child with no unresolved
   `blocked by`. Do not dispatch multiple children's `:spec` yourself — the
   user (via `:start` on that child) drives each child through the normal
   pipeline one at a time, reading `epic-map.md` for status.

## What this stage does not do

- Does not open any child's worklog, run `:spec`/`:clarify` on a child, or
  write code. Splitting is a distinct decision from delivering.
- Does not lower any child's Risk lane or gate requirements. A P0 child found
  during decomposition is exactly as hard-gated as a P0 ticket found any other
  way (`references/risk.md`).
- Does not replace `:audit`. A epic whose children individually pass AUDIT is
  not proof the children compose correctly (behavior-parity across children is
  outside this stage's — and current AUDIT's — verified scope); say so if the
  epic's own risk profile calls for that kind of cross-child proof and no gate
  currently covers it, rather than implying `epic-map.md` closes that gap.

## Result rules

- Any epic-level question left unanswered → do not write `epic-map.md` as
  final; keep it `Status: DRAFT` and re-ask only the remainder.
- Never invent a child's Risk/Type as final — mark it `estimate, confirmed at
  :spec` so nobody downstream treats this stage's guess as G1's real answer.
- Never silently merge two children back into one to save a round of
  questions — if splitting turns out to add pure ceremony for children with
  no real dependency or shared risk, say so and offer to merge them back
  *before* writing the map, not after.
