# Plugin structure (dev-workflow)

Minimum layout:

```
.claude-plugin/{plugin,marketplace}.json
.cursor-plugin/{plugin,marketplace}.json
.codex-plugin/plugin.json
.agents/plugins/marketplace.json
plugin.json
hosts/antigravity/plugin.json
skills/<stage>/SKILL.md
commands/dev-workflow*.md
references/*.md
templates/
bin/check-gates.sh
README*.md STRUCTURE.md MARKETPLACE.md LICENSE
```

Stages: `start learning coaching spec conflict plan build confirm check ship status`.
Keep `references/` and `templates/` shared; `install.sh` links stage-local copies.
