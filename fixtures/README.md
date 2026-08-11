# Fixtures (check-gates smoke)

```bash
chmod +x bin/check-gates.sh
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"
```

## FAIL G1 (empty AC)

```bash
./bin/check-gates.sh FIX-FAIL --project demo --min G1
# expect exit 1 — no filled AC-xx row
```

## FAIL G8 missing evidence

```bash
./bin/check-gates.sh FAIL-G8-missing --project demo --min G8
# expect exit 1 — missing 06b-test-evidence.md
```

## FAIL G8 failing tests

```bash
./bin/check-gates.sh FAIL-G8-failing --project demo --min G8
# expect exit 1 — Overall FAIL
```

## PASS G8

```bash
./bin/check-gates.sh PASS-G8 --project demo --min G8
# expect exit 0
```
