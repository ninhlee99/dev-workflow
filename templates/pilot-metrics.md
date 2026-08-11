# Pilot metrics (10-ticket) — machine-scored

Store at: `workspaces/<slug>/pilot/PILOT-v0.4.md`  
Score with: `./bin/pilot-score.sh workspaces/<slug>/pilot/PILOT-v0.4.md`  
Success bar: miss-spec / reopen / escape each ≤ 50% of baseline; gate_blocks ≥ 1.

## Setup

1. Baseline = last 10 tickets before workflow.
2. Pilot = next 10 tickets with dev-workflow.
3. After each ship: add one log row; keep Scores block updated.

## Metrics

| Metric | Definition |
|---|---|
| miss-spec | Bug/rework from wrong/missing requirement |
| reopen | Reopened after done for same scope |
| escape | Defect in staging/prod after ship |
| gate-block | Checker correctly blocked a bad advance |

## Log

| # | Ticket | Risk | Lane | miss-spec? | reopen? | escape? | gate-block? | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | | P? | hard/fast | ☐ yes ☐ no | ☐ yes ☐ no | ☐ yes ☐ no | ☐ yes ☐ no | |
| 2 | | | | ☐ | ☐ | ☐ | ☐ | |
| 3 | | | | ☐ | ☐ | ☐ | ☐ | |
| 4 | | | | ☐ | ☐ | ☐ | ☐ | |
| 5 | | | | ☐ | ☐ | ☐ | ☐ | |
| 6 | | | | ☐ | ☐ | ☐ | ☐ | |
| 7 | | | | ☐ | ☐ | ☐ | ☐ | |
| 8 | | | | ☐ | ☐ | ☐ | ☐ | |
| 9 | | | | ☐ | ☐ | ☐ | ☐ | |
| 10 | | | | ☐ | ☐ | ☐ | ☐ | |

## Scores (machine) — required

```
baseline_miss_spec=0
pilot_miss_spec=0
baseline_reopen=0
pilot_reopen=0
baseline_escape=0
pilot_escape=0
gate_blocks=0
tickets_completed=0
```

## Summary

- Verdict: ☐ improve ☐ flat ☐ worse
- Next tweak: …
