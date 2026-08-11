# Marketplace & Distribution

This document covers installation from each supported host marketplace and the release checklist for maintainers publishing a new version.

---

## Supported hosts

| Host | Manifest | Status |
|------|----------|--------|
| Claude Code | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` | ✅ |
| Cursor | `.cursor-plugin/plugin.json` + `.cursor-plugin/marketplace.json` + `plugin.json` | ✅ |
| Codex | `.codex-plugin/plugin.json` + `.agents/plugins/marketplace.json` | ✅ |
| Antigravity | `hosts/antigravity/plugin.json` | ✅ |

---

## Installation

### Claude Code

```bash
# Add the plugin source (local path or GitHub URL)
/plugin marketplace add /path/to/dev-workflow
# or
/plugin marketplace add https://github.com/ninhlee99/dev-workflow

# Install
/plugin install dev-workflow@dev-workflow-marketplace

# Reload
/reload-plugins
```

### Cursor / Codex / local

```bash
git clone git@github.com:ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh
```

`install.sh` handles all hosts in one pass (Claude Code links, Cursor commands, Codex skills, Antigravity bundle).

### Antigravity

```bash
bash hosts/antigravity/rebuild.sh
agy plugin install ./hosts/antigravity
```

---

## Smoke test (post-install)

Run these after installing on any host to confirm the plugin is wired correctly:

```bash
# 1. Verify gate checker is executable
./bin/check-gates.sh --help

# 2. Run against the demo fixture — must exit 1 (FAIL expected)
DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FIX-FAIL --project demo --min G1
echo "Exit: $?"   # expect 1

# 3. Confirm commands are visible in the AI host
# Claude Code:  /dev-workflow:status
# Cursor:       /dev-workflow:status
# Codex:        dev-workflow:status skill
```

---

## Release checklist (maintainers)

Before tagging a new version:

### 1. Update version in all manifests

```bash
# Files to bump — must all have the same version string
plugin.json
.claude-plugin/plugin.json
.cursor-plugin/plugin.json
.codex-plugin/plugin.json
hosts/antigravity/plugin.json
```

Search for current version and replace:

```bash
grep -r '"version"' . --include='*.json' | grep -v node_modules
```

### 2. Update CHANGELOG.md

Move entries from `[Unreleased]` to a new `[x.y.z] — YYYY-MM-DD` section.

### 3. Run install and smoke tests

```bash
bash install.sh
DEV_WORKFLOW_WORKSPACES_ROOT=./fixtures \
  ./bin/check-gates.sh FIX-FAIL --project demo --min G1
```

### 4. Tag and push

```bash
git tag v<x.y.z>
git push origin main v<x.y.z>
```

### 5. Verify on at least one live host

Install the tagged version on Claude Code or Cursor and run `/dev-workflow:status` to confirm commands load.
