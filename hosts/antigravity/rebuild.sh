#!/usr/bin/env bash
# Rebuild hosts/antigravity bundle (Antigravity CLI: agy plugin install).
# Antigravity root plugin.json only allows name+description — skills live here.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEST="$ROOT/hosts/antigravity"
mkdir -p "$DEST"
rm -rf "$DEST/skills" "$DEST/bin" "$DEST/references" "$DEST/templates" "$DEST/commands"
ln -sfn "$ROOT/skills" "$DEST/skills"
ln -sfn "$ROOT/bin" "$DEST/bin"
ln -sfn "$ROOT/references" "$DEST/references"
ln -sfn "$ROOT/templates" "$DEST/templates"
ln -sfn "$ROOT/commands" "$DEST/commands"
# Also expose flat skill entrypoints for IDE global skills path (optional)
mkdir -p "$DEST/flat-skills"
for s in "$ROOT/skills"/*/SKILL.md; do
  [[ -f "$s" ]] || continue
  name="$(basename "$(dirname "$s")")"
  # Antigravity global skills often want name.md — keep SKILL.md folders preferred via plugins/
  ln -sfn "$s" "$DEST/flat-skills/${name}.md"
done
echo "Antigravity bundle ready: $DEST"
echo "Install: agy plugin install \"$DEST\""
echo "Or IDE skills: npx path copy skills → ~/.gemini/antigravity/skills (see MARKETPLACE.md)"
