# Contributing to dev-workflow

Thank you for improving this plugin. This document explains how to contribute changes, add stages, or fix bugs.

---

## Prerequisites

- Bash 4+ (macOS: `brew install bash`)
- One of: Claude Code, Cursor, Codex, or Antigravity (for smoke-testing)
- Git

---

## Repository layout

See [STRUCTURE.md](./STRUCTURE.md) for a full annotated layout. The key principle:

> **Single source of truth in `references/` and `templates/`.** Stage skills (`skills/*/SKILL.md`) symlink to these via `install.sh`. Never duplicate content across stages.

---

## Development workflow

```bash
git clone git@github.com:ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh       # wire up symlinks + deploy commands to host AI tools
```

Edit files, then re-run `bash install.sh` to refresh symlinks and commands.

---

## Adding a new stage

1. Create `skills/<stage>/SKILL.md` (see existing stages for structure).
2. Create `commands/dev-workflow:<stage>.md` with `description` and `argument-hint` frontmatter.
3. Add `<stage>` to the `STAGES` array in `install.sh`.
4. If the stage produces an artifact, add a template under `templates/`.
5. Document the gate (if any) in `references/workflow.md` and `bin/check-gates.sh`.
6. Run `bash install.sh` and smoke-test.

---

## Editing gates

Gate logic lives in `bin/check-gates.sh`. Each gate section is labelled `# --- Gx ---`.  
Keep gate checks **file-based and grep-based** — no external dependencies.  
Always test with the `fixtures/workspaces/demo` fixture:

```bash
DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FIX-FAIL --project demo --min G1
# expect exit 1

DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh PASS-G8 --project demo --min G8
# expect exit 0

DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FAIL-G8-missing --project demo --min G8
# expect exit 1
```

---

## Token discipline

- `references/*.md` and `skills/*/SKILL.md`: keep concise. Target < 200 words per file.
- No filler phrases ("please", "make sure to", "note that").
- Imperative sentences only.
- Load references on-demand inside skills — do not preload everything.

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
- [ ] `bin/check-gates.sh FIX-FAIL --project demo --min G1` exits 1
- [ ] `bin/check-gates.sh PASS-G8 --project demo --min G8` exits 0
- [ ] All changed `references/` and `skills/` files stay within word-count budget
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] No hardcoded project names or absolute paths in plugin source

---

## Versioning and release

1. Move `[Unreleased]` entries in `CHANGELOG.md` to a new `[x.y.z] — YYYY-MM-DD` section.
2. Bump `"version"` in all manifests: `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.codex-plugin/plugin.json`, `hosts/antigravity/plugin.json`.
3. Tag: `git tag v<x.y.z> && git push origin v<x.y.z>`.
4. Smoke-install on at least one host before announcing.
