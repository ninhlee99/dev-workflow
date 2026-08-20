# Risk tiers & lanes

Set **Risk** on worklog `INDEX.md` and `02-spec.md` before `:plan`.

| Tier | When | Lane | Rules |
|---|---|---|---|
| **P0** | money, authz/permission, PII, legacy data, irreversible migrate | Hard | All G0–G9 + AUDIT. No WAIVE G3/G8. Dual `CONFIRM G3` + `CONFIRM G3-PM`. Machine evidence + **CI-native verify** under `--strict`. **`02b-security.md` required**. |
| **P1** | normal product behavior change | Hard | All G0–G9 + AUDIT. Machine evidence required. `--strict` required for the final AUDIT check. |
| **P2** | copy, config, docs, tiny non-behavioral chore | Fast | Required hard: G0, G1, G6, G8, G9. **G2/G3/G4/G5/G7 soft** unless `--strict` (warn, not fail) — a P2 ticket can reach G9 with no human `CONFIRM G3` round-trip, though one is still welcome. Still prefer INDEX WAIVE rows when skipping intentionally. |

## How to choose

1. Touches money / permission / PII / legacy → **P0**
2. Else changes user-visible behavior or API contract → **P1**
3. Else → **P2**

If unsure → **P1**.

## Fast lane (P2)

Checker softens G2/G3/G4/G5/G7 when Risk=P2 and not `--strict`.
Still need AC, tests/machine evidence, and G9. `CONFIRM G3` is soft for P2 — skip the human
round-trip on a genuinely tiny, non-behavioral change, or still ask for one when you'd rather
have it on record. `--strict` always makes G3 hard again, regardless of Risk.

## Stage timeboxes (adoption)

| Stage | Soft max |
|---|---|
| learning (first project) | 1–2 sessions |
| spec + clarify + confirm | ≤ 1 day for P1 |
| plan | ≤ 2 h |
| build | per estimate |
| review + fix? + test + ship + clean? | ≤ 0.5 day after build green |
| audit (semantic, post-G9) | ≤ 30 min — P0/P1 required, P2 optional |
| P2 full path | ≤ 2 h wall-clock target |

If over timebox → escalate Risk or split ticket — do not skip G3/G8/G9. Do not skip `:audit` on
P0/P1 to save the 30 min — that is exactly the timebox this table exists to protect against being
cut first under deadline pressure.
