# Worklog INDEX: [Ticket_ID]

Project slug/home/worklog path are resolved by `bin/lib/resolve-paths.sh` and printed at the start
of every `/dev-workflow:*` run (`project=… home=… worklog=…`) — do not re-copy them here. Chat
locale lives once at `domain-knowledge/INDEX.md` (per workspace, not per ticket); do not duplicate
it here either.

- **Ticket:** [url]
- **Feature alias:** [name]
- **Touches UI?** ☐ Yes ☐ No
- **Type:** ☐ Bug ☐ New feature ☐ Spec change ☐ Requirement change ☐ Refactor   (see `references/ba-integrity.md` §Classify — set at `:spec`, mirrors `01-intent.md`; drives investigation strategy in `:clarify`; Refactor skips `:clarify`/`:confirm` entirely)
- **Risk:** ☐ P0 ☐ P1 ☐ P2   (see `references/risk.md`)
- **Pilot:** ☐ yes ☐ no   (if yes, G9 requires row in `pilot/PILOT-*.md`)

## Handoff

- **Last stop:** …
- **Waiting on:** ☐ learning  ☐ coaching  ☐ Dev confirm CLAIM #…  ☐ none
- **G3 user sign-off:** ☐ PASS ☐ FAIL
- **Human confirm phrase (required):** `CONFIRM G3: <Ticket_ID> <name> <YYYY-MM-DD>`
- **P0 PM phrase (required if P0):** `CONFIRM G3-PM: <Ticket_ID> <pm-name> <YYYY-MM-DD>`

Paste the exact user/PM message below (do not invent):

```
CONFIRM G3: …
```

## Gate status

Do not hand-transcribe a gate table here — `bin/check-gates.sh <Ticket> [--project <slug>] --min
<gate> [--json]` is the one source of truth for PASS/FAIL/WAIVE per gate (see
`references/workflow.md`'s gate table for what each gate requires and its FAIL command). A
hand-written copy here can silently drift from what the checker actually says; run it instead of
reading/writing a stale table.

**Build only when G0–G3 PASS (P2: waived gates documented).** G9 structural PASS is required before
`:ship` is treated as final, but not sufficient by itself — Semantic audit must also PASS (P0/P1
required; P2 may mark N/A with a one-line reason).

## Touched repos (from PROJECT.md — do not hardcode)

- [ ] `<repo-slug>` …
- [ ] …

## Waivers

Format: `Gate/claim | reason | owner | expiry YYYY-MM-DD | PM note?`

- (none)

**Forbidden:** waive G2 money/permission/legacy unless PM notes explicitly.  
**P0:** no WAIVE on G3/G8. **Strict CI:** G8 WAIVE rejected.

## Next action

- [ ] `/dev-workflow:…`
