#!/usr/bin/env bash
# Install dev-workflow for Claude Code, Cursor, and Codex.
#
# Source of truth = this plugin ROOT (references/, templates/, commands/, skills/*/SKILL.md).
# Cursor slash policy (lean palette):
#   - Commands ONLY colon names from plugin/commands/ → ~/.cursor/commands/ and ~/.claude/commands/
#   - Skills: ONE thin pointer at ~/.cursor/skills/dev-workflow/SKILL.md
# Edit root templates/references only; re-run install for symlinks/commands.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGES=(start learning coaching spec conflict plan build confirm check ship status)
PROJECT_CLAUDE_CMDS="${DEV_WORKFLOW_PROJECT_CLAUDE_COMMANDS:-}"
# Optional: set DEV_WORKFLOW_PROJECT_CLAUDE_COMMANDS to a project .claude/commands dir to sync there.

echo "==> Plugin: $PLUGIN_DIR (v0.1.0)"

# Remove obsolete qa stage if present
if [[ -d "$PLUGIN_DIR/skills/qa" ]]; then
  rm -rf "$PLUGIN_DIR/skills/qa"
  echo "  [plugin] removed skills/qa"
fi

# Symlink shared assets into each plugin skill dir (not cp -R).
# ./references and ./templates resolve when skill cwd = skills/$s.
# Ensure gate checker is executable
if [[ -f "$PLUGIN_DIR/bin/check-gates.sh" ]]; then
  chmod +x "$PLUGIN_DIR/bin/check-gates.sh"
  echo "  [plugin] chmod +x bin/check-gates.sh"
fi

echo "==> Symlink references+templates into plugin skills/*"
for s in "${STAGES[@]}"; do
  local_dest="$PLUGIN_DIR/skills/$s"
  [[ -d "$local_dest" ]] || continue
  rm -rf "$local_dest/references" "$local_dest/templates"
  ln -sfn ../../references "$local_dest/references"
  ln -sfn ../../templates "$local_dest/templates"
  echo "  [plugin] $local_dest/{references,templates} -> symlink"
done

install_copied_skills() {
  local dest_root="$1"
  local label="$2"
  mkdir -p "$dest_root"
  for s in "${STAGES[@]}"; do
    local src="$PLUGIN_DIR/skills/$s"
    local dest="$dest_root/dev-workflow-$s"
    if [[ ! -f "$src/SKILL.md" ]]; then
      echo "WARN: missing $src/SKILL.md — skip $s" >&2
      continue
    fi
    mkdir -p "$dest"
    cp "$src/SKILL.md" "$dest/SKILL.md"
    rm -rf "$dest/references" "$dest/templates"
    ln -sfn "$PLUGIN_DIR/references" "$dest/references"
    ln -sfn "$PLUGIN_DIR/templates" "$dest/templates"
    echo "  [$label] $dest (SKILL + symlink assets)"
  done
}

install_colon_commands() {
  local dest="$1"
  local label="$2"
  mkdir -p "$dest"
  local src
  shopt -s nullglob
  for src in "$PLUGIN_DIR"/commands/dev-workflow.md "$PLUGIN_DIR"/commands/dev-workflow:*.md; do
    [[ -f "$src" ]] || continue
    cp "$src" "$dest/$(basename "$src")"
    echo "  [$label] $(basename "$src")"
  done
  # Remove hyphen command variants (inflate slash palette)
  for f in "$dest"/dev-workflow-*.md; do
    [[ -e "$f" ]] || continue
    rm -f "$f"
    echo "  [$label] removed hyphen $(basename "$f")"
  done
}

# --- Claude Code -------------------------------------------------------------
echo ""
echo "==> Claude Code"
echo "    Prefer plugin load:"
echo "      claude --plugin-dir \"$PLUGIN_DIR\""
echo "    Then /reload-plugins and call /dev-workflow:start …"
mkdir -p "${HOME}/.claude/skills" "${HOME}/.claude/plugins" "${HOME}/.claude/commands"
ln -sfn "$PLUGIN_DIR" "${HOME}/.claude/skills/dev-workflow-plugin"
ln -sfn "$PLUGIN_DIR" "${HOME}/.claude/plugins/dev-workflow"
echo "    Linked:"
echo "      ~/.claude/skills/dev-workflow-plugin -> $PLUGIN_DIR"
echo "      ~/.claude/plugins/dev-workflow -> $PLUGIN_DIR"
echo "    Optional: export DEV_WORKFLOW_PLUGIN=\"$PLUGIN_DIR\""

echo "    Claude commands (colon) from plugin/commands/"
install_colon_commands "${HOME}/.claude/commands" "claude-cmd"

# Optional project .claude/commands sync
if [[ -n "$PROJECT_CLAUDE_CMDS" ]]; then
  mkdir -p "$PROJECT_CLAUDE_CMDS"
  install_colon_commands "$PROJECT_CLAUDE_CMDS" "project-claude-cmd"
fi

# --- Cursor ------------------------------------------------------------------
echo ""
echo "==> Cursor (lean: ~/.cursor/commands colon set + one pointer skill)"
CURSOR_CMDS="${HOME}/.cursor/commands"
CURSOR_SKILLS="${HOME}/.cursor/skills"
mkdir -p "$CURSOR_CMDS" "$CURSOR_SKILLS"

install_colon_commands "$CURSOR_CMDS" "cursor-cmd"

# Do NOT install into project .cursor/commands (duplicates inflate palette)

# Remove leftover per-stage Cursor skills (including obsolete qa)
for s in "${STAGES[@]}" qa; do
  d="$CURSOR_SKILLS/dev-workflow-$s"
  if [[ -e "$d" ]]; then
    rm -rf "$d"
    echo "  [cursor-skill] removed $d"
  fi
done

# Thin pointer skill only (env-based source; includes learning; no QA wording)
ORCH="$CURSOR_SKILLS/dev-workflow"
mkdir -p "$ORCH"
rm -rf "$ORCH/references" "$ORCH/templates"
cat > "$ORCH/SKILL.md" <<'SKILLEOF'
---
name: dev-workflow
description: >-
  Thin pointer. Prefer Cursor commands /dev-workflow and /dev-workflow:<stage>.
  Stages: start|learning|coaching|spec|conflict|plan|build|confirm|check|ship|status.
  Confirm (not QA). Real logic lives in the plugin (see Source below).
argument-hint: "Use /dev-workflow or /dev-workflow:<stage> with <Ticket ID> (or topic for coaching; brief for learning)."
disable-model-invocation: true
---

# Dev Workflow — Cursor pointer

**Do not treat this skill as the implementation.** Slash commands under `~/.cursor/commands/` are the Cursor entrypoints.

Source: $DEV_WORKFLOW_PLUGIN or plugin dir linked as ~/.claude/skills/dev-workflow-plugin

Stages: start|learning|coaching|spec|conflict|plan|build|confirm|check|ship|status

When a stage command runs, follow `skills/<stage>/` and shared `references/` + `templates/` in that plugin.
SKILLEOF
echo "  [cursor] thin pointer -> $ORCH/SKILL.md"

# --- Codex -------------------------------------------------------------------
echo ""
echo "==> Codex (per-stage SKILL + symlink assets to plugin root)"
install_copied_skills "${HOME}/.codex/skills" "codex"

# Codex plugin copy for Plugins Directory / personal marketplace
CODEX_PLUGIN="${HOME}/.codex/plugins/dev-workflow"
mkdir -p "${HOME}/.codex/plugins" "${HOME}/.agents/plugins"
rm -rf "$CODEX_PLUGIN"
ln -sfn "$PLUGIN_DIR" "$CODEX_PLUGIN"
if [[ ! -f "${HOME}/.agents/plugins/marketplace.json" ]]; then
  cat > "${HOME}/.agents/plugins/marketplace.json" <<'EOF'
{
  "name": "personal-dev-workflow",
  "interface": { "displayName": "Personal Dev Workflow" },
  "plugins": [
    {
      "name": "dev-workflow",
      "source": { "source": "local", "path": "./.codex/plugins/dev-workflow" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Productivity",
      "interface": { "displayName": "Dev Workflow" }
    }
  ]
}
EOF
  # path relative to marketplace root (~) — Codex resolves from home when marketplace in ~/.agents
  # Prefer absolute symlink target; rewrite with home-relative if needed by user
  echo "  [codex] wrote ~/.agents/plugins/marketplace.json (edit source.path if picker misses plugin)"
else
  echo "  [codex] ~/.agents/plugins/marketplace.json exists — leave as-is (see MARKETPLACE.md)"
fi
echo "  [codex] plugin link -> $CODEX_PLUGIN"

# --- Antigravity -------------------------------------------------------------
echo ""
echo "==> Antigravity host bundle"
if [[ -f "$PLUGIN_DIR/hosts/antigravity/rebuild.sh" ]]; then
  bash "$PLUGIN_DIR/hosts/antigravity/rebuild.sh"
  echo "    Install with: agy plugin install \"$PLUGIN_DIR/hosts/antigravity\""
fi

echo ""
echo "==> Marketplace manifests present"
echo "    Claude:  .claude-plugin/marketplace.json  → /plugin marketplace add \"$PLUGIN_DIR\""
echo "    Cursor:  .cursor-plugin/plugin.json       → Customize / marketplace publish"
echo "    Codex:   .agents/plugins/marketplace.json → Plugins Directory"
echo "    Docs:    MARKETPLACE.md"
echo ""
echo "==> Done"
echo "    Edit root templates/references only; re-run install to refresh symlinks/commands."
echo "    Cursor slash: ~/.cursor/commands/dev-workflow.md + dev-workflow:*.md (+ one ~/.cursor/skills/dev-workflow pointer)."
echo "    Claude slash: ~/.claude/commands/ (same colon set from plugin/commands/)."
