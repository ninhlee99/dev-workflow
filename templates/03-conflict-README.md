# 03 Conflict artifacts

Follow `./references/conflict-check.md` (plugin `references/conflict-check.md`) — concrete steps, not an orphan skill name.

**Always** store under the parent project worklog:

- `03-conflict-report.md` ← use template `03-conflict-report.md`
- `03-qa-log.md` ← use template `03-qa-log.md`

**Do not** use `docs/conflict-reports/` / `spec/conflict-reports/` inside child app repos.

## G2 PASS when

- Every **non-MATCH** claim has explicit `Decision` + `Owner` + `Date` (Dev after asking PM/BA/comtor), **or**
- Valid greenfield (no legacy code touched) + INDEX note

## Forbidden / tighten

- Partial confirm → G2 FAIL; keep ASK — **no** Plan/Build
- **WAIVE** only on worklog INDEX with all fields: reason | owner | expiry | PM note; claims touching **money / permission / legacy rule** → **no waive** unless PM notes explicitly
- Claim missing current `file:line` → not ready for Dev confirm
