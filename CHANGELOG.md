# Changelog

All notable changes to **dev-workflow** are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).  
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Documentation

- Added `docs/INSTALL.md` with host paths, isolated install verification, update steps, and troubleshooting.
- Synced README, USER-GUIDE, MARKETPLACE, STRUCTURE, CONTRIBUTING, and host manifests with Type,
  provenance, RED→GREEN evidence, command ledger, G0–G9, and C1–C8 AUDIT behavior.

### Installer

- Added `--claude`, `--cursor`, `--codex`, `--agy`, and `--all` shorthand flags; long-form
  `--host`/`--agent` remains supported and the default is Claude only.
- Cursor and Codex now install all 16 stage skills as live links instead of stale copies/thin pointers.
- Antigravity install now rebuilds, validates, and registers the complete bundle through `agy`.
- Added isolated installer acceptance tests for every host selection and invalid input.
- Enabled model invocation for all 16 Codex-visible skills and completed the validated Codex interface manifest.
- Synchronized install, update, verification, and troubleshooting guidance across all user docs.
- Added a target-aware `uninstall.sh` with exact-path cleanup, Antigravity delegation, modified
  marketplace preservation, and isolated uninstall acceptance tests.
- Added a target-aware `update.sh` with clean-worktree protection, fast-forward-only pulls, host
  refresh, dependency preflight, and isolated update acceptance tests.

### Added
- **Locale:** `references/locale.md` — chat/setup follow user language; gate keywords stay English.
- **Workspace health:** `bin/check-workspace.sh` + `references/workspace-health.md` (W0–W6).
- **Task isolation:** `references/task-isolation.md` — one worklog per ticket; build must not bleed.
- **`/dev-workflow:clean`:** `bin/clean-worklog.sh` archives (or `--purge`) finished ticket worklog only; refuses without G9 unless `--force`.
- **External workspace default:** project homes now prefer `~/.workspaces/<project-slug>/` (outside product repos), while legacy `<root>/workspaces/<slug>/` remains readable.

### Changed
- Docs clarity: `docs/USER-GUIDE.md` as primary guide; README/STRUCTURE/MARKETPLACE/enforce synced to v0.4.
- Template gate labels fixed (`03-qa-log`→G5, `05-impl-log`→G6, `06-review-qa`→G7).
- Naming table: confirm (G3) vs review (G7) vs fix (remediation) vs test (G8) vs clean (post-ship).
- Stage order: `… → review → fix? → test → … → clean?` (`install.sh` STAGES includes `fix` + `clean`).
- **Neutral code review:** `references/code-review.md` — diff-first review for 500 / missing / injection / case defects.
- **`/dev-workflow:fix`:** triage OPEN findings; template `06c-fix-log.md`.
- Review template `06-review-qa.md`: defect class sweep + structured findings table.

---

## [0.4.0] — 2026-08-11

### Added
- **Anti-forge G3:** require `03b-human-confirm.md` + ban AI/tool names; Source: user-message.
- **`--strict` ⇒ `--verify-net`** for CI URL checks.
- **`bin/pilot-score.sh`** machine success bar (all measurable metrics ≥ target).
- **GitHub Actions required-check template** `templates/ci/github-actions-dev-workflow.yml`.
- **Maturity rubric** `references/maturity.md` (every criterion ≥ 8 mapped to controls).
- Stage timeboxes for adoption; Pilot:yes enforce ticket row in pilot log at G9.
- G9 tighter: canary N/A reason ≥10 chars; dashboard URL or query ≥15 chars.

### Changed
- Version `0.4.0`. Pilot template uses machine Scores block.

---

## [0.3.0] — 2026-08-11

### Added
- **CI-native verify** (`--strict` / P0): SHA vs git HEAD, junit/xml parse for failures, optional `--verify-net` HTTP check.
- **P2 soft gates** in checker: G2/G4/G5/G7 warn-only unless `--strict`.
- **P0 security mini-gate:** `02b-security.md` + `references/security.md`.
- **G9 deepened:** canary %, soak time, on-call, SLO/error-budget.
- **Pilot ops guide:** `references/pilot.md` with success bar for 10-ticket proof.

### Changed
- Version `0.3.0` across manifests.
- `07-ship.md`, risk/enforce/workflow docs and skills synced.

---

## [0.2.0] — 2026-08-11

### Added
- **Risk tiers P0/P1/P2** + hard/fast lanes (`references/risk.md`).
- **G9 ship safety** gate: migration / feature flag / monitor / rollback in `07-ship.md`.
- **G3 anti-spoof:** requires literal human phrase `CONFIRM G3: <Ticket> <name> <date>` (P0 also `CONFIRM G3-PM:`).
- **G8 machine evidence:** Commit SHA + CI run URL or junit/xml/log path.
- **Pilot metrics template** `templates/pilot-metrics.md` for 10-ticket before/after measurement.
- Fixtures: `PASS-G9` (+ updated PASS/FAIL G8 for machine evidence + CONFIRM G3).

### Changed
- Version bump to `0.2.0` across all marketplace manifests.
- `check-gates.sh` enforces Risk, CONFIRM G3, machine evidence, G9; P0 implies no G3/G8 WAIVE.
- Fixed doc drift in `conflict-check.md` and `07-ship.md`.
- README / INDEX / skills / checklists synced to G0–G9.

### Notes
- Prior G0–G8 renumber from 0.1.x retained; G9 is new.

---

## [0.1.0] — 2026-08-11

### Added
- **11 stages:** `learning`, `coaching`, `start`, `spec`, `conflict`, `plan`, `build`, `confirm`, `check`, `ship`, `status`.
- **8 gates (G0–G7):** programmatic enforcement via `bin/check-gates.sh`.
- **WAIVE policy:** gate waivers require reason, owner, expiry, and PM sign-off; money/permission/legacy blocked without PM.
- **Multi-project workspaces:** `workspaces/<project-slug>/` auto-created; path resolution via `bin/lib/resolve-paths.sh` (env → `.dev-workflow.json` → git remote → cwd).
- **Artifact templates:** `01-intent`, `02-spec`, `03-conflict-report`, `03-qa-log`, `04-plan`, `05-impl-log`, `06-review-qa`, `07-ship`, `gate-checklist`, `pr-checklist`.
- **Domain knowledge templates:** `PROJECT.md`, `domain-knowledge/{INDEX,architecture,business,glossary,changelog}`, `repos/{NOTES,map-flows,map-models,open-questions}`.
- **Multi-host manifests:** Claude Code (`.claude-plugin/`), Cursor (`.cursor-plugin/` + `plugin.json`), Codex (`.codex-plugin/` + `.agents/plugins/`), Antigravity (`hosts/antigravity/`).
- **`install.sh`:** symlinks shared `references/` and `templates/` into each stage skill; deploys colon commands to `~/.cursor/commands/` and `~/.claude/commands/`; builds Antigravity bundle.
- **Fixtures:** `fixtures/workspaces/demo/` with a failing-gate example for testing the gate checker.
- **Neutral language:** no project-specific names or hardcoded paths in plugin source.
- **Token-optimised docs:** all references and skill files written for minimal AI context load.

[Unreleased]: https://github.com/ninhlee99/dev-workflow/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/ninhlee99/dev-workflow/releases/tag/v0.4.0
[0.3.0]: https://github.com/ninhlee99/dev-workflow/releases/tag/v0.3.0
[0.2.0]: https://github.com/ninhlee99/dev-workflow/releases/tag/v0.2.0
[0.1.0]: https://github.com/ninhlee99/dev-workflow/releases/tag/v0.1.0
