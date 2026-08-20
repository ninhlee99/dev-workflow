# Dev Workflow rules

Goal: clear requirements before code. Use `workspaces/<project-slug>/` from `project-root.md`.
Risk tiers: see `references/risk.md` (P0 hard / P1 hard / P2 fast).

## Output contract
- Read `references/locale.md`: **chat/setup in user language**; gate keywords stay English.
- Reply only the asked scope.
- Format: verdict → gaps → next command.
- Keep status short; ask max 3 numbered questions.
- Use `[LEARNING]` / `[COACHING]`; artifact **labels** English; notes may follow user language.
- Workspace: `references/workspace-health.md` + `bin/check-workspace.sh`.
- Per ticket isolation: `references/task-isolation.md` (no cross-worklog bleed).
- After ship: optional `:clean <Ticket>` → `bin/clean-worklog.sh` (archive/purge that worklog only).

## Gates and dispatch
| Gate | PASS means | FAIL command |
|---|---|---|
| G0 | domain knowledge matches ticket scope | empty → `:learning`; wrong/changed → `:coaching` (directly, or by answering a coaching ticket `:learning` opened — see `references/learning.md`/`coaching.md`). `:start` does not run either for you — see "Stage order" below. |
| G1 | AC + Risk set; **P0 also `02b-security.md`**; **Touches UI also QA handoff oracle table** | `:spec` |
| G2 | each non-MATCH has decision, owner, date (P2 soft unless `--strict`) | `:clarify` |
| G3 | human `CONFIRM G3:` on INDEX **and** `03b-human-confirm.md` (no AI names; P0 + PM); P2 soft unless `--strict` | `:confirm` |
| G4 | tasks map to AC/claims (P2 soft unless `--strict`) | `:plan` |
| G5 | no OPEN Qs (P2 soft unless `--strict`) | `:clarify` |
| G6 | coverage map + tests pass | `:build` |
| G7 | AC evidence How/By + no OPEN P0/P1 review findings (P2 soft unless `--strict`) | `:review` (then `:fix` if findings) |
| G8 | test evidence + machine fields; `--strict`/P0 = CI-native verify | `:test` |
| G9 | ship safety + canary/soak/on-call/SLO + rollback | `:ship` |
| — | semantic audit: worklog claims agree with each other (post-structural, not encoded in check-gates.sh) | `:audit` |

WAIVE only on INDEX: `Gate/claim | reason | owner | expiry | PM note`.  
P0: no WAIVE G3/G8. `--strict` or P0/P1: machine evidence required. `--strict`: no G8 WAIVE.

`check-gates.sh` verifies structure only (field present, not a repeated placeholder, SHA matches
HEAD). It cannot verify a Rollback plan actually undoes the Migration described two sections above
it — that needs a reader, not a regex. `:audit` is the required semantic layer on top; G9
structural PASS is necessary but not sufficient for ship to be final. See `references/audit.md`.

## Stage order

`:learning`/`:coaching` are independent of the delivery pipeline below and are never dispatched
by `:start` — the user runs them directly. `:learning`'s unclear findings become async coaching
tickets in `domain-knowledge/coaching-tickets/`, answered one at a time via
`:coaching <ticket-id> <answer>` whenever the user gets to them — this loop runs on its own
schedule, entirely outside `:start`.

`:start` runs one analysis pass, then dispatches continuously through the delivery pipeline **only**
— never past it. If G0 fails (domain-knowledge missing or contradicted), `:start` stops and tells
the user to run `:learning`/`:coaching` themselves, then call `:start` again — it does not invoke
either on their behalf. Delivery then follows `:spec` → `:clarify` → `:confirm` → `:plan` →
`:build` → `:review` → (`:fix` if P0/P1 OPEN) → `:test` → `/dev-workflow:check` → `:ship` →
`:audit` → `:status` → (`:clean` when ticket done), stopping only at a genuine blocker or at
`:ship`/`:audit` (always manual). See `skills/start/SKILL.md` for the full one-stop mechanics.
`references/stage-contract.md` is authoritative.

If current stage already PASS, jump to next. End `:spec`, end `:plan`, and before close `:build`: print uncovered AC/claim map; any gap = FAIL.
P2 fast lane may WAIVE G2/G3/G4/G5/G7 with INDEX rows — never silent skip.

## Independence

Each stage above is independently runnable, not just chainable through `:start`. `:spec` self-chains
into `:clarify` for any ambiguous claim; `:plan` self-analyzes the ticket when spec/clarify weren't
run; `:build` calls `:plan` (which self-analyzes if needed) when no plan exists yet. A result built
this way is marked `Source: self-analyzed (no upstream artifact)` so later stages and humans can see
it wasn't built from confirmed scope. `:confirm` and `:audit` are the exception — their human
sign-off requirement is never satisfied by self-analysis. See `references/stage-contract.md`'s
**(preferred)** markers for exactly which `Requires` entries soften this way.

## Entry points: `:start` and `:decompose`

`:start` (and the bare `/dev-workflow` alias) is the default way to run a single ticket
start-to-`:check` — same gates, same evidence bar as calling every `/dev-workflow:<stage>` command
by hand, just fewer stops: one deep analysis pass up front, one collapsed confirm, then continuous
dispatch until a genuine stop (P0/P1 finding, an upstream OPEN clarify claim, or `:ship`/`:audit`,
which stay manual on purpose). The named `/dev-workflow:<stage>` commands remain the manual,
step-by-step path for controlling one specific step — `:start` does not replace them, and either is
a valid way to work a ticket. See `skills/start/SKILL.md`.

`:decompose` runs *before* `:start` when a request is epic-shaped — spans more than one
service/repo, mixes ticket Type, or has independently shippable parts. `:start` also offers it
early, before its own single stop, when a ticket resolves to >4 claims or >2 Types without ever
spanning a second repo — same offer, just triggered by claim count instead of repo count.
`:decompose` never opens a child's worklog itself; it produces `epic-map.md` (project-level, not
inside any one ticket's worklog), cross-checks the dependency graph with a duplicate-scan before
hand-off, and hands off the first unblocked child to `:spec` or `:start`. See
`skills/decompose/SKILL.md`.
