# Maturity rubric (all criteria ≥ 8)

How v0.4.0 maps each expert criterion to concrete controls.

| Criterion | Target | Controls that keep score ≥ 8 |
|---|---|---|
| Spec / conflict / confirm | ≥8 | G1 AC+Risk; G2 claims; G3 `CONFIRM` in INDEX **and** `03b-human-confirm.md`; ban AI names |
| Risk lanes | ≥8 | P0/P1/P2 in checker; P2 soft; P0 dual confirm + security |
| Evidence authenticity | ≥8 | SHA↔git; junit parse; `--strict` ⇒ `--verify-net` for http CI URL |
| Security (P0) | ≥8 | `02b-security.md` required + PASS row |
| Ship / prod safety | ≥8 | G9 canary/soak/on-call/SLO; dashboard URL or concrete query; rollback |
| Programmatic enforce | ≥8 | `check-gates.sh` + fixtures + **required** GH Actions template |
| Measurable proof | ≥8 | `pilot-score.sh` success bar; pilot mode on INDEX; sample + CI hook |
| Adoption / timebox | ≥8 | Stage timeboxes in `risk.md`; P2 fast lane real soft skips |
| Semantic coherence (post-structural) | ≥8 | `:audit` cross-checks Decision↔Proposal, Rollback↔Migration, etc — catches content that is structurally valid but logically wrong, which `check-gates.sh` regex cannot see |

## Org binding (required for score to hold)

1. Copy `templates/ci/github-actions-dev-workflow.yml` → product repo `.github/workflows/`.
2. Branch protection: require `dev-workflow-gates` status check.
3. Run 10-ticket pilot; `bin/pilot-score.sh` must exit 0.
