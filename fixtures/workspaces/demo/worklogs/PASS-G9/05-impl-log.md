# 05 Impl log

| Field | Value |
|---|---|
| Commit SHA | abcdef1234567890 |

- **RED command:** `rspec test_ac01` — failed: expected success, got missing behavior
- **Why RED proves the missing behavior:** it executes AC-01 and fails on the required result
- **GREEN command/result:** `rspec test_ac01` — 1 example, 0 failures

## Coverage map

| AC | Test | Result |
|---|---|---|
| AC-01 | test_ac01 | ☑ PASS |
