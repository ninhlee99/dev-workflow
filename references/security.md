# Security gate (P0)

When Risk = **P0**, worklog must include `02b-security.md` (from `templates/02b-security.md`).

Checker (`--min G1+` and Risk P0):
- file exists
- Threat note not placeholder
- Secrets/PII table has at least one PASS
- If multi-repo touched: contract row PASS or N/A with note

Never WAIVE security for money/auth/PII without PM note on INDEX.
