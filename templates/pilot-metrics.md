# Pilot metrics (10-ticket)

Run after installing v0.2.0. Goal: prove workflow reduces miss-spec / reopen / escape defects.

## Setup

1. Pick 10 real tickets (mix P0/P1/P2 if possible).
2. Record baseline from last 10 tickets *before* workflow (or from memory/tracker).
3. Run full/fast lane per risk tier.
4. Fill table below; store under `workspaces/<slug>/pilot/PILOT-v0.2.md`.

## Metrics

| Metric | Definition |
|---|---|
| miss-spec | Bug/rework caused by wrong/missing requirement |
| reopen | Ticket reopened after "done" for same scope |
| escape | Defect found in staging/prod after ship |
| gate-block | Times checker correctly blocked advance |

## Log

| # | Ticket | Risk | Lane | miss-spec? | reopen? | escape? | Notes |
|---|---|---|---|---|---|---|---|
| 1 | | P? | hard/fast | ☐ | ☐ | ☐ | |
| 2 | | | | ☐ | ☐ | ☐ | |
| 3 | | | | ☐ | ☐ | ☐ | |
| 4 | | | | ☐ | ☐ | ☐ | |
| 5 | | | | ☐ | ☐ | ☐ | |
| 6 | | | | ☐ | ☐ | ☐ | |
| 7 | | | | ☐ | ☐ | ☐ | |
| 8 | | | | ☐ | ☐ | ☐ | |
| 9 | | | | ☐ | ☐ | ☐ | |
| 10 | | | | ☐ | ☐ | ☐ | |

## Summary

- Baseline miss-spec rate: __ / 10
- Pilot miss-spec rate: __ / 10
- Baseline reopen: __ / 10
- Pilot reopen: __ / 10
- Baseline escape: __ / 10
- Pilot escape: __ / 10
- Verdict: ☐ improve ☐ flat ☐ worse
- Next workflow tweak: …
