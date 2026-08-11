# Pilot ops (prove expert level)

Template: `templates/pilot-metrics.md`  
Store run log: `workspaces/<slug>/pilot/PILOT-v0.3.md`

## How to run (10 tickets)

1. Baseline: last 10 tickets before workflow (miss-spec / reopen / escape).
2. Next 10 tickets: full lane by Risk (P0/P1 hard, P2 fast).
3. Every ship: add one row to pilot table.
4. After 10: fill Summary; if miss-spec or escape not down → tune gates, do not add more paperwork blindly.

## Success bar (expert-proven)

| Metric | Target vs baseline |
|---|---|
| miss-spec | ≤ 50% of baseline |
| reopen | ≤ 50% of baseline |
| escape | ≤ 50% of baseline |
| gate-block true positive | ≥ 1 useful block in 10 |

If targets miss → inspect which gate failed to catch defect; patch that gate only.
