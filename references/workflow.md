# Dev Workflow rules

Goal: clear requirements before code. Use `workspaces/<project-slug>/` from `project-root.md`.
Risk tiers: see `references/risk.md` (P0 hard / P1 hard / P2 fast).

## Output contract
- Reply only the asked scope.
- Format: verdict → gaps → next command.
- Keep status short; ask max 3 numbered questions.
- Use `[LEARNING]` / `[COACHING]`; keep artifact fields in English.

## Gates and dispatch
| Gate | PASS means | FAIL command |
|---|---|---|
| G0 | domain knowledge matches ticket scope | empty → `:learning`; wrong/changed → `:coaching` |
| G1 | AC + Risk set; **P0 also `02b-security.md`** | `:spec` |
| G2 | each non-MATCH has decision, owner, date (P2 soft unless `--strict`) | `:conflict` |
| G3 | human `CONFIRM G3:` on INDEX **and** `03b-human-confirm.md` (no AI names; P0 + PM) | `:confirm` |
| G4 | tasks map to AC/claims (P2 soft unless `--strict`) | `:plan` |
| G5 | no OPEN Qs (P2 soft unless `--strict`) | `:conflict` |
| G6 | coverage map + tests pass | `:build` |
| G7 | AC evidence How/By + no OPEN P0/P1 review findings (P2 soft unless `--strict`) | `:review` (then `:fix` if findings) |
| G8 | test evidence + machine fields; `--strict`/P0 = CI-native verify | `:test` |
| G9 | ship safety + canary/soak/on-call/SLO + rollback | `:ship` |

WAIVE only on INDEX: `Gate/claim | reason | owner | expiry | PM note`.  
P0: no WAIVE G3/G8. `--strict` or P0/P1: machine evidence required. `--strict`: no G8 WAIVE.

## Stage order
`:learning` → `:coaching` → `:start` → `:spec` → `:conflict` → `:confirm` → `:plan` → `:build` → `:review` → (`:fix` if P0/P1 OPEN) → `:test` → `/dev-workflow:check` → `:ship` → `:status`

If current stage already PASS, jump to next. End `:spec`, end `:plan`, and before close `:build`: print uncovered AC/claim map; any gap = FAIL.
P2 fast lane may WAIVE G2/G4/G5/G7 with INDEX rows — never silent skip.
