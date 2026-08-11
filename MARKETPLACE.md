# Marketplace & install (v0.1.0)

Host manifests:
- Claude: `.claude-plugin/{plugin,marketplace}.json`
- Cursor: `.cursor-plugin/{plugin,marketplace}.json` + `plugin.json`
- Codex: `.codex-plugin/plugin.json` + `.agents/plugins/marketplace.json`
- Antigravity: `hosts/antigravity/plugin.json`

Install:
- Claude: `/plugin marketplace add <path-or-github>` → `/plugin install dev-workflow@dev-workflow-marketplace` → `/reload-plugins`
- Cursor/Codex/local: `bash install.sh`
- Antigravity: `bash hosts/antigravity/rebuild.sh` → `agy plugin install ./hosts/antigravity`

Publish checklist: bump version in all manifests, run rebuild/install scripts, smoke install on each host, keep `references/` and `templates/` inside plugin tree.
