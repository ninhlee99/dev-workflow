# Risk tiers & lanes

Set **Risk** on worklog `INDEX.md` and `02-spec.md` before `:plan`.

| Tier | When | Lane | Rules |
|---|---|---|---|
| **P0** | money, authz/permission, PII, legacy data, irreversible migrate | Hard | All G0–G9. No WAIVE G3/G8. Dual `CONFIRM G3` + `CONFIRM G3-PM`. Machine evidence + **CI-native verify** under `--strict`. **`02b-security.md` required**. |
| **P1** | normal product behavior change | Hard | All G0–G9. Machine evidence required. `--strict` recommended before merge. |
| **P2** | copy, config, docs, tiny non-behavioral chore | Fast | Required hard: G0, G1, G3, G6, G8, G9. **G2/G4/G5/G7 soft** unless `--strict` (warn, not fail). Still prefer INDEX WAIVE rows when skipping intentionally. |

## How to choose

1. Touches money / permission / PII / legacy → **P0**
2. Else changes user-visible behavior or API contract → **P1**
3. Else → **P2**

If unsure → **P1**.

## Fast lane (P2)

Checker softens G2/G4/G5/G7 when Risk=P2 and not `--strict`.  
Still need AC, `CONFIRM G3:` (+ `03b-human-confirm.md`), tests/machine evidence, and G9.

## Stage timeboxes (adoption)

| Stage | Soft max |
|---|---|
| learning (first project) | 1–2 sessions |
| spec + conflict + confirm | ≤ 1 day for P1 |
| plan | ≤ 2 h |
| build | per estimate |
| review + fix? + test + ship + clean? | ≤ 0.5 day after build green |
| P2 full path | ≤ 2 h wall-clock target |

If over timebox → escalate Risk or split ticket — do not skip G3/G8/G9.
