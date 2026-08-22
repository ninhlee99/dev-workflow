# Structure — dev-workflow v0.4

Annotated repository layout. Edit the owning source (`skills/`, `references/`, `templates/`,
`commands/`, or `bin/`), then rerun `bash install.sh` with the original target flag whenever
host-installed copies or links need refreshing.

---

## Tree

```
dev-workflow/
├── bin/
│   ├── check-gates.sh              # G0–G9 + AUDIT structural enforcer
│   ├── check-workspace.sh          # Workspace layout health (W0–W6)
│   ├── clean-worklog.sh            # Archive/purge one ticket worklog
│   ├── pilot-score.sh              # 10-ticket measurable success bar
│   └── lib/resolve-paths.sh        # Project/workspace/slug resolution
│
├── commands/                       # Slash commands (Cursor / Claude)
│   ├── dev-workflow.md             # alias → :start
│   └── dev-workflow:<stage>.md     # one file per stage
│
├── skills/<stage>/SKILL.md         # Stage instructions (AI)
│   ├── references/ → ../../references
│   └── templates/  → ../../templates
│
├── references/                     # Shared rules (load on demand)
│   ├── workflow.md                 # Gate table + stage order
│   ├── stage-contract.md           # Authoritative stage inputs/outputs/routing
│   ├── skill-quality.md            # Evidence, truth labels, 9/10 quality contract
│   ├── risk.md                     # P0/P1/P2 + timeboxes
│   ├── security.md                 # P0 02b-security
│   ├── pilot.md                    # Pilot ops
│   ├── maturity.md                 # Expert rubric (≥8)
│   ├── enforce.md                  # Checker flags
│   ├── project-root.md             # Path resolution
│   ├── learning.md / coaching.md
│   ├── clarify-check.md
│   ├── code-review.md              # Neutral diff review + :fix triage
│   ├── locale.md                   # Chat/setup in user language
│   ├── workspace-health.md         # check-workspace.sh rules
│   └── task-isolation.md           # One worklog per ticket
│
├── templates/                      # Filled per ticket / project
│   ├── INDEX.md
│   ├── 01-intent.md … 07-ship.md
│   ├── 02b-security.md             # P0
│   ├── 03b-human-confirm.md        # G3 anti-forge
│   ├── 06b-test-evidence.md        # G8
│   ├── 06c-fix-log.md              # Review finding triage / fixes
│   ├── pilot-metrics.md
│   ├── gate-checklist.md / pr-checklist.md
│   ├── ci/github-actions-dev-workflow.yml
│   ├── domain-knowledge/
│   └── workspaces/_project|/_repo/
│
├── docs/
│   ├── INSTALL.md                  # Install/update/verify by host
│   └── USER-GUIDE.md               # Day-to-day usage (start here for humans)
│
├── fixtures/workspaces/demo/       # Checker smoke data + sample pilot
├── hosts/antigravity/              # Antigravity bundle
├── .claude-plugin/ .cursor-plugin/ .codex-plugin/
├── plugin.json
├── install.sh
├── update.sh
├── uninstall.sh
├── README.md MARKETPLACE.md CONTRIBUTING.md CHANGELOG.md
└── LICENSE
```

**Stages in `install.sh`:**
`decompose start learning coaching spec clarify confirm plan build review fix test check ship audit status clean feedback`

**Host selection:** default is `claude`; shorthand flags are `--claude`, `--cursor`, `--codex`,
`--agy`, `--all` (the long-form `--host`/`--agent` is also supported). Cursor and Codex receive live
per-stage links; Antigravity is rebuilt, validated, and installed through `agy`. `update.sh` requires
a clean worktree, fast-forwards the source, then refreshes the selected target. `uninstall.sh`
mirrors these targets and removes only dev-workflow-owned host entries — it preserves the repository
clone, worklogs, unrelated files, and any modified Codex marketplace configuration.

---

## Worklog artifacts ↔ gates

| Template | Gate |
|----------|------|
| domain-knowledge / PROJECT.md | G0 |
| `02-spec.md` (+ `02b-security.md` if P0) | G1 |
| `03-clarify-report.md` | G2 |
| `03b-human-confirm.md` + INDEX CONFIRM | G3 |
| `04-plan.md` | G4 |
| `03-qa-log.md` (no OPEN) | G5 |
| `05-impl-log.md` | G6 |
| `06-review-qa.md` | G7 |
| `06b-test-evidence.md` | G8 |
| `07-ship.md` | G9 |
| `08-semantic-audit.md` | AUDIT |

---

## Design principles

1. **Single source of truth** — `stage-contract.md`, root `references/`, and `templates/`; drift is regression-tested.
2. **Load on demand** — each skill lists only the references it needs (token discipline).
3. **Neutral paths** — no hardcoded customer repos; paths resolve via env var, marker file, or git.
4. **Programmatic truth** — `check-gates.sh` / `pilot-score.sh` decide PASS/FAIL, not AI self-claim.
