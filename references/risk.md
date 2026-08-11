# Risk tiers & lanes

Set **Risk** on worklog `INDEX.md` and `02-spec.md` before `:plan`.

| Tier | When | Lane | Rules |
|---|---|---|---|
| **P0** | money, authz/permission, PII, legacy data, irreversible migrate | Hard | All G0–G9. No WAIVE on G3/G8. Dual confirm: `CONFIRM G3:` + `CONFIRM G3-PM:`. Machine evidence mandatory. `--strict` implied. |
| **P1** | normal product behavior change | Hard | All G0–G9. WAIVE only with full INDEX fields. Machine evidence required for G8. |
| **P2** | copy, config, docs, tiny non-behavioral chore | Fast | Required: G0, G1, G3, G6, G8, G9. G2/G4/G5/G7 may WAIVE with reason. Still forbid silent skip. |

## How to choose

1. Touches money / permission / PII / legacy → **P0**
2. Else changes user-visible behavior or API contract → **P1**
3. Else → **P2**

If unsure → **P1**.

## Fast lane (P2) discipline

- Still write AC (even one row).
- Still get `CONFIRM G3:` from human.
- Still attach test/machine evidence for touched paths.
- Document WAIVE rows for skipped gates.
