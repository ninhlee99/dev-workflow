# Marketplace & install — v0.4

For prerequisites, files changed, update steps, and troubleshooting, use
**[docs/INSTALL.md](./docs/INSTALL.md)**. This page is the short host command reference.

## Hosts

| Host | Manifests | Install |
|------|-----------|---------|
| Claude Code | `.claude-plugin/{plugin,marketplace}.json` | `/plugin marketplace add …` then install |
| Cursor | `.cursor-plugin/*` + `plugin.json` | `bash install.sh --cursor` |
| Codex | `.codex-plugin/plugin.json` | `bash install.sh --codex` |
| Antigravity | `hosts/antigravity/plugin.json` | `bash install.sh --agy` |

---

## Install commands

### Claude Code

```text
/plugin marketplace add https://github.com/ninhlee99/dev-workflow
/plugin install dev-workflow@dev-workflow-marketplace
/reload-plugins
```

### Local installer

```bash
git clone https://github.com/ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh                         # Claude only (default)
bash install.sh --cursor
bash install.sh --codex
bash install.sh --agy
bash install.sh --all
```

Installs only the selected agent. Cursor/Codex get all live per-stage skill links; Antigravity is
rebuilt, validated, and registered through `agy`. Existing
`~/.agents/plugins/marketplace.json` is preserved rather than overwritten.
`--agy` and `--all` require `agy` on `PATH`; `--all` fails before changing any host when it is absent.

### Antigravity

```bash
bash hosts/antigravity/rebuild.sh
agy plugin validate ./hosts/antigravity
agy plugin install ./hosts/antigravity
```

After install, read **[docs/USER-GUIDE.md](./docs/USER-GUIDE.md)**.

### Update

```bash
bash update.sh             # Claude only (default)
bash update.sh --cursor
bash update.sh --codex
bash update.sh --agy
bash update.sh --all
```

Requires a clean worktree and uses `git pull --ff-only` before refreshing the selected host. Full
behavior: **[docs/INSTALL.md](./docs/INSTALL.md#update)**.

### Uninstall

```bash
bash uninstall.sh             # Claude only (default)
bash uninstall.sh --cursor
bash uninstall.sh --codex
bash uninstall.sh --agy
bash uninstall.sh --all
```

The repository clone, worklogs, unrelated host files, and modified Codex marketplace configuration
are preserved. Full removal behavior: **[docs/INSTALL.md](./docs/INSTALL.md#uninstall)**.

---

## Smoke test

```bash
chmod +x bin/check-gates.sh bin/pilot-score.sh
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"

./tests/regression.sh                                                # expect 10 PASS
./tests/install.sh                                                   # expect 14 PASS
./tests/update.sh                                                    # expect 6 PASS
./tests/uninstall.sh                                                 # expect 11 PASS
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
3. Installer, updater, uninstaller, and smoke commands above
4. `git tag vX.Y.Z && git push origin main vX.Y.Z`  
5. Smoke-install on one live host  

```bash
grep -r '"version"' . --include='*.json' | grep -v node_modules
```
