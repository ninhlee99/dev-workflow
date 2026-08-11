# Enforce

Never claim G6–G9 PASS without real checker run.

```bash
./bin/check-gates.sh <Ticket> [--project <slug>] [--min G8|G9] [--strict] [--verify-net] [--json]
```

- Default `--min G8`. Merge gate: `--min G9 --strict`.
- `--strict`: CI-native verify (SHA vs git HEAD, junit file parse); no P2 soft skips; no G8 WAIVE.
- `--verify-net`: HTTP HEAD on CI URL.
- P0: `02b-security.md` required; dual CONFIRM; no G3/G8 WAIVE.
- P2: G2/G4/G5/G7 soft unless `--strict`.
- Exit: `0` PASS · `1` FAIL · `2` error.
