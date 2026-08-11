# Enforce

Never claim G6/G7/G8/G9 PASS without real checker run. Exit code drives verdict.

```bash
./bin/check-gates.sh <Ticket> [--project <slug>] [--min G8|G9] [--strict] [--json]
```

- Default `--min G8` (pre-ship). Use `--min G9` before merge.
- `--strict` or Risk P0/P1: require G8 machine evidence (CI URL, commit SHA, junit/xml or log path).
- `--strict` / P0: reject G8 WAIVE; P0 also rejects G3 WAIVE.
- G3 requires literal `CONFIRM G3:` line on INDEX (human phrase; AI must not invent).
- Exit: `0` PASS · `1` FAIL · `2` usage/path error.
