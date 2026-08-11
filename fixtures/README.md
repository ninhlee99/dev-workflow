# Fixtures (check-gates smoke) — v0.3.0

```bash
chmod +x bin/check-gates.sh
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"
```

| Ticket | Command | Expect |
|---|---|---|
| FIX-FAIL | `--min G1` | exit 1 |
| FAIL-G8-missing | `--min G8` | exit 1 |
| FAIL-G8-failing | `--min G8` | exit 1 |
| PASS-G8 | `--min G8` | exit 0 |
| PASS-G8 | `--min G8 --strict` | exit 0 (junit file verified) |
| PASS-G9 | `--min G9` / `--min G9 --strict` | exit 0 |
