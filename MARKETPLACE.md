# Marketplace & install — v0.4

For prerequisites, files changed, update steps, and troubleshooting, use
**[docs/INSTALL.md](./docs/INSTALL.md)**. This page is the short host command reference.

## Hosts

| Host | Manifests | Install |
|------|-----------|---------|
| Claude Code | `.claude-plugin/{plugin,marketplace}.json` | `/plugin marketplace add …` then install |
| Cursor | `.cursor-plugin/*` + `plugin.json` | `bash install.sh` |
| Codex | `.codex-plugin/plugin.json` | `bash install.sh` |
| Antigravity | `hosts/antigravity/plugin.json` | `rebuild.sh` then `agy plugin install` |

---

## Install commands

### Claude Code

```text
/plugin marketplace add https://github.com/ninhlee99/dev-workflow
/plugin install dev-workflow@dev-workflow-marketplace
/reload-plugins
```

### Cursor / Codex / local

```bash
git clone https://github.com/ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh
```

Deploys colon commands to `~/.cursor/commands/` and `~/.claude/commands/`, installs Codex stage
skills, links shared assets, and rebuilds the Antigravity bundle. Existing
`~/.agents/plugins/marketplace.json` is preserved rather than overwritten.

### Antigravity

```bash
bash hosts/antigravity/rebuild.sh
agy plugin install ./hosts/antigravity
```

After install, read **[docs/USER-GUIDE.md](./docs/USER-GUIDE.md)**.

---

## Smoke test

```bash
chmod +x bin/check-gates.sh bin/pilot-score.sh
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"

./tests/regression.sh                                                # expect 10 PASS
./bin/check-gates.sh FIX-FAIL --project demo --min G1          # expect FAIL
./bin/check-gates.sh PASS-G8 --project demo --min G8           # expect PASS
./bin/check-gates.sh PASS-G9 --project demo --min G9 --strict  # expect PASS
./bin/pilot-score.sh fixtures/workspaces/demo/pilot/PILOT-v0.4.md  # expect PASS
```

In the AI host, restart/reload it if required, then confirm `/dev-workflow:status` and
`/dev-workflow:audit` appear.

---

## Release checklist (maintainers)

1. Bump `"version"` in all `plugin.json` / `marketplace.json` files  
2. Update `CHANGELOG.md`  
3. `bash install.sh` + smoke commands above  
4. `git tag vX.Y.Z && git push origin main vX.Y.Z`  
5. Smoke-install on one live host  

```bash
grep -r '"version"' . --include='*.json' | grep -v node_modules
```
