# Contributing to dev-workflow

Thank you for improving this plugin. This document explains how to contribute changes, add stages, or fix bugs.

---

## Prerequisites

- Bash 3.2+
- One of: Claude Code, Cursor, Codex, or Antigravity (for live smoke-testing)
- `agy` only for live Antigravity installation; `tests/install.sh` supplies an isolated fake
- Git

---

## Repository layout

See [STRUCTURE.md](./STRUCTURE.md) for a full annotated layout. The key principle:

> **Contract first.** `references/stage-contract.md` owns stage prerequisites/outputs/routing;
> `references/skill-quality.md` owns evidence/truthfulness rules. Stage-specific behavior stays in
> `skills/*/SKILL.md`; shared artifact shape stays in `templates/`.

---

## Development workflow

```bash
git clone git@github.com:ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh --claude  # choose one host; use --all only when intended
```

Edit files, then rerun the installer for the specific host being tested.

---

## Adding a new stage

1. Create `skills/<stage>/SKILL.md` (see existing stages for structure).
2. Create `commands/dev-workflow:<stage>.md` with `description` and `argument-hint` frontmatter.
3. Add `<stage>` to the `STAGES` array in `install.sh`.
4. If the stage produces an artifact, add a template under `templates/`.
5. Document the gate (if any) in `references/workflow.md` and `bin/check-gates.sh`.
6. Update `references/stage-contract.md`, user docs, and command tooltip.
7. Add positive and negative behavior to `tests/regression.sh`.
8. Run `tests/install.sh` (isolated HOME + fake `agy`) and smoke-test.

---

## Editing gates

Gate logic lives in `bin/check-gates.sh`. Each gate section is labelled `# --- Gx ---`.  
Keep gate checks deterministic and dependency-light. Prefer explicit parsers when a Markdown table
cannot be validated safely with a small grep/awk rule.
Always test with the `fixtures/workspaces/demo` fixture:

```bash
DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FIX-FAIL --project demo --min G1
# expect exit 1

DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh PASS-G8 --project demo --min G8
# expect exit 0

DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh PASS-G9 --project demo --min G9 --strict
# expect exit 0

DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FAIL-G8-missing --project demo --min G8
# expect exit 1

./bin/pilot-score.sh fixtures/workspaces/demo/pilot/PILOT-v0.4.md
# expect exit 0
```

---

## Token discipline

- Keep the smallest sufficient interface; move genuinely shared policy to one reference.
- No filler phrases ("please", "make sure to", "note that").
- Load references on demand; do not duplicate a contract merely to save one file read.
- Measure token use before claiming an optimization; shorter text is not automatically more accurate.

---

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body — optional, only if "why" is non-obvious>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.  
Scope: stage name or component (e.g. `spec`, `check-gates`, `install`).

---

## Pull request checklist

- [ ] `bash install.sh` runs without errors
- [ ] `tests/regression.sh` exits 0
- [ ] `tests/install.sh` exits 0
- [ ] `bin/check-gates.sh FIX-FAIL --project demo --min G1` exits 1
- [ ] `bin/check-gates.sh PASS-G8 --project demo --min G8` exits 0
- [ ] `bin/check-gates.sh PASS-G9 --project demo --min G9 --strict` exits 0
- [ ] `bin/pilot-score.sh fixtures/workspaces/demo/pilot/PILOT-v0.4.md` exits 0
- [ ] `CHANGELOG.md` updated under `[Unreleased]` (or new version section)
- [ ] Docs still match gates (README + `docs/USER-GUIDE.md` + STRUCTURE)
- [ ] No hardcoded project names or absolute paths in plugin source

---

## Versioning and release

1. Move `[Unreleased]` entries in `CHANGELOG.md` to a new `[x.y.z] — YYYY-MM-DD` section.
2. Bump `"version"` in all manifests: `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.codex-plugin/plugin.json`, `hosts/antigravity/plugin.json`.
3. Tag: `git tag v<x.y.z> && git push origin v<x.y.z>`.
4. Smoke-install on at least one host before announcing.
