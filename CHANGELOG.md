# Changelog

All notable changes to **dev-workflow** are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).  
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed
- **Gate renumber (integer-only G0–G8):** removed decimal gates `G2.5` / `G6.5`.
  - G3 = user confirm sign-off
  - G4 = plan
  - G5 = no open Qs
  - G6 = build + coverage
  - G7 = review evidence
  - G8 = test evidence
- **`bin/check-gates.sh`:** enforces G3 + G8; default `--min G8`; adds `--strict` (reject G8 WAIVE, require UI screenshot paths, reject thin/placeholder test output).
- Skills/docs/templates/README synced to G0–G8 mapping.

### Added
- Fixtures: `PASS-G8`, `FAIL-G8-missing`, `FAIL-G8-failing` under `fixtures/workspaces/demo/worklogs/`.

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

[Unreleased]: https://github.com/ninhlee99/dev-workflow/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ninhlee99/dev-workflow/releases/tag/v0.1.0
