# Pilot ops (measurable proof ≥ 8)

Template: `templates/pilot-metrics.md`  
Scorer: `./bin/pilot-score.sh workspaces/<slug>/pilot/PILOT-v0.4.md`  
Sample: `fixtures/workspaces/demo/pilot/PILOT-v0.4.md`

## Run

1. Copy template → `workspaces/<slug>/pilot/PILOT-v0.4.md`
2. Fill baseline counts in **Scores (machine)** block.
3. For each pilot ticket: set INDEX `Pilot: ☑ yes`; after ship add log row + update scores.
4. After 10 tickets: `pilot-score.sh` must exit 0.

## Success bar (enforced by scorer)

- `tickets_completed ≥ 10`
- miss-spec / reopen / escape each ≤ ceil(baseline/2)
- `gate_blocks ≥ 1`

## CI

Optional job: run `pilot-score.sh` on the pilot file in a scheduled workflow after week 2.
