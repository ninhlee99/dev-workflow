# Enforce

Never claim G6/G7/G8 PASS without real checker run. Exit code drives verdict.

```bash
./bin/check-gates.sh <Ticket> [--project <slug>] [--min G8] [--strict] [--json]
```

- Default `--min G8` (enough to ship).
- `--strict`: reject G8 WAIVE; require UI screenshot paths; reject placeholder test output.
- Exit: `0` PASS · `1` FAIL · `2` usage/path error.
