# 07 Ship: PASS-G9

- **PR:** https://example.com/pr/1
- **Date:** 2026-08-11
- **Ticket:** PASS-G9
- **Risk:** ☑ P1
- **Commit SHA:** abcdef1234567890

## Pre-merge

- [x] G0–G8 PASS

## Ship safety (G9 — required)

### Migration / data

- **Has migration?** ☐ Yes ☑ No
- **Backward compatible?** ☐ Yes ☐ No ☑ N/A
- **Notes:** no schema change

### Feature flag / dark launch

- **Flag name / N/A:** N/A
- **Default off in prod?** ☐ Yes ☑ N/A
- **Rollout plan:** normal merge

### Monitor / alert

- **Dashboard or log query:** grep PASS-G9 in app logs
- **Alert / owner on-call:** fixture-oncall
- **First 24h watch:** yes

### Rollback

- **Rollback steps:** revert merge commit abcdef12
- **Data repair needed?** ☐ Yes ☑ No
- **Time-to-rollback estimate:** 5m

## Deploy notes

- fixture
