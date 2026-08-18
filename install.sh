#!/usr/bin/env bash
# Install dev-workflow for one coding agent, or all supported agents.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGES=(start learning coaching spec clarify confirm plan build review fix test check ship audit status clean feedback)
VENDORED_SKILLS=(grilling tdd)
TARGET_HOST="claude"
TARGET_EXPLICIT=0
PROJECT_CLAUDE_CMDS="${DEV_WORKFLOW_PROJECT_CLAUDE_COMMANDS:-}"

usage() {
  cat <<'EOF'
Usage: bash install.sh [--claude|--cursor|--codex|--agy|--all]
       bash install.sh [--host|--agent] claude|cursor|codex|antigravity|all

Default: claude

Options:
  --claude               Install only for Claude Code
  --cursor               Install only for Cursor
  --codex                Install only for Codex
  --agy, --antigravity   Install only for Antigravity
  --all                  Install for every supported coding agent
  --host, --agent <name>  Install only that coding agent, or all
  --list-hosts            Print supported coding agents
  -h, --help              Show this help

Examples:
  bash install.sh                         # Claude only
  bash install.sh --cursor                # Cursor only
  bash install.sh --codex                 # Codex only
  bash install.sh --agy                   # Antigravity only
  bash install.sh --all                   # Every supported agent
EOF
}

select_target() {
  local requested="$1"
  if [[ "$TARGET_EXPLICIT" -eq 1 && "$TARGET_HOST" != "$requested" ]]; then
    echo "ERROR: conflicting install targets '$TARGET_HOST' and '$requested'; choose exactly one target" >&2
    usage >&2
    exit 2
  fi
  TARGET_HOST="$requested"
  TARGET_EXPLICIT=1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host|--agent)
      [[ $# -ge 2 ]] || { echo "ERROR: $1 requires a host" >&2; usage >&2; exit 2; }
      select_target "$2"
      shift 2
      ;;
    --claude) select_target claude; shift ;;
    --cursor) select_target cursor; shift ;;
    --codex) select_target codex; shift ;;
    --agy|--antigravity) select_target antigravity; shift ;;
    --all) select_target all; shift ;;
    --list-hosts)
      echo "claude cursor codex antigravity all"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    claude|cursor|codex|antigravity|all)
      select_target "$1"
      shift
      ;;
    *)
      echo "ERROR: unsupported host '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$TARGET_HOST" in
  claude|cursor|codex|antigravity|all) ;;
  *) echo "ERROR: unsupported host '$TARGET_HOST'" >&2; usage >&2; exit 2 ;;
esac

echo "==> Plugin: $PLUGIN_DIR (v0.4.0)"
echo "==> Target: $TARGET_HOST"

if [[ "$TARGET_HOST" == "antigravity" || "$TARGET_HOST" == "all" ]]; then
  command -v agy >/dev/null 2>&1 || {
    echo "ERROR: agy CLI not found; no host was installed" >&2
    exit 1
  }
fi

prepare_source() {
  local s local_dest
  for _bin in check-gates.sh check-workspace.sh clean-worklog.sh pilot-score.sh; do
    if [[ -f "$PLUGIN_DIR/bin/$_bin" ]]; then
      chmod +x "$PLUGIN_DIR/bin/$_bin"
    fi
  done

  for s in "${STAGES[@]}"; do
    local_dest="$PLUGIN_DIR/skills/$s"
    [[ -d "$local_dest" ]] || { echo "ERROR: missing skill directory $local_dest" >&2; exit 1; }
    [[ -f "$local_dest/SKILL.md" ]] || { echo "ERROR: missing $local_dest/SKILL.md" >&2; exit 1; }
    rm -rf "$local_dest/references" "$local_dest/templates"
    ln -sfn ../../references "$local_dest/references"
    ln -sfn ../../templates "$local_dest/templates"
  done
}

install_stage_links() {
  local dest_root="$1" label="$2" s src dest
  mkdir -p "$dest_root"
  for s in "${STAGES[@]}"; do
    src="$PLUGIN_DIR/skills/$s"
    dest="$dest_root/dev-workflow-$s"
    rm -rf "$dest"
    ln -sfn "$src" "$dest"
    echo "  [$label] dev-workflow-$s -> $src"
  done
  rm -rf "$dest_root/dev-workflow-qa"
}

install_colon_commands() {
  local dest="$1" label="$2" src f
  mkdir -p "$dest"
  shopt -s nullglob
  for src in "$PLUGIN_DIR"/commands/dev-workflow.md "$PLUGIN_DIR"/commands/dev-workflow:*.md; do
    [[ -f "$src" ]] || continue
    cp "$src" "$dest/$(basename "$src")"
    echo "  [$label] $(basename "$src")"
  done
  for f in "$dest"/dev-workflow-*.md; do
    [[ -e "$f" ]] || continue
    rm -f "$f"
  done
  shopt -u nullglob
}

install_vendored_skill_if_missing() {
  local name="$1"
  local dest_root="$2"
  local label="$3"
  local dest="$dest_root/$name"
  local vendor_src="$PLUGIN_DIR/skills/_vendor/$name"
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "  [$label] $name already present, skipping"
    return
  fi
  [[ -d "$vendor_src" ]] || { echo "  [$label] WARNING: no vendored copy of $name, skipping" >&2; return; }
  mkdir -p "$dest_root"
  ln -sfn "$vendor_src" "$dest"
  echo "  [$label] installed $name (vendored by dev-workflow)"
}

install_vendored_skills_if_missing() {
  local dest_root="$1" label="$2" name
  for name in "${VENDORED_SKILLS[@]}"; do
    install_vendored_skill_if_missing "$name" "$dest_root" "$label"
  done
}

install_claude() {
  echo "==> Claude Code"
  mkdir -p "$HOME/.claude/skills" "$HOME/.claude/plugins" "$HOME/.claude/commands"
  ln -sfn "$PLUGIN_DIR" "$HOME/.claude/skills/dev-workflow-plugin"
  ln -sfn "$PLUGIN_DIR" "$HOME/.claude/plugins/dev-workflow"
  install_colon_commands "$HOME/.claude/commands" "claude-command"
  if [[ -n "$PROJECT_CLAUDE_CMDS" ]]; then
    install_colon_commands "$PROJECT_CLAUDE_CMDS" "project-claude-command"
  fi
  install_vendored_skills_if_missing "$HOME/.claude/skills" "claude-skill"
  echo "  Reload plugins, then run /dev-workflow:status"
}

install_cursor() {
  echo "==> Cursor"
  mkdir -p "$HOME/.cursor/commands" "$HOME/.cursor/skills"
  install_colon_commands "$HOME/.cursor/commands" "cursor-command"
  rm -rf "$HOME/.cursor/skills/dev-workflow"
  install_stage_links "$HOME/.cursor/skills" "cursor-skill"
  install_vendored_skills_if_missing "$HOME/.cursor/skills" "cursor-skill"
  echo "  Restart/reload Cursor, then run /dev-workflow:status"
}

install_codex_marketplace_seed() {
  local marketplace_root="$HOME/.agents/plugins"
  local marketplace="$marketplace_root/marketplace.json"
  mkdir -p "$marketplace_root/plugins"
  ln -sfn "$PLUGIN_DIR" "$marketplace_root/plugins/dev-workflow"
  if [[ ! -f "$marketplace" ]]; then
    cat >"$marketplace" <<'EOF'
{
  "name": "personal",
  "interface": { "displayName": "Personal" },
  "plugins": [
    {
      "name": "dev-workflow",
      "source": { "source": "local", "path": "./plugins/dev-workflow" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Productivity"
    }
  ]
}
EOF
    echo "  [codex] created personal marketplace seed"
  else
    echo "  [codex] preserved existing personal marketplace"
  fi
}

install_codex() {
  echo "==> Codex"
  mkdir -p "$HOME/.codex/skills" "$HOME/.codex/plugins"
  install_stage_links "$HOME/.codex/skills" "codex-skill"
  install_vendored_skills_if_missing "$HOME/.codex/skills" "codex-skill"
  ln -sfn "$PLUGIN_DIR" "$HOME/.codex/plugins/dev-workflow"
  install_codex_marketplace_seed
  echo "  Start a new Codex task so the refreshed skills are discovered"
}

install_antigravity() {
  echo "==> Antigravity"
  bash "$PLUGIN_DIR/hosts/antigravity/rebuild.sh"
  agy plugin validate "$PLUGIN_DIR/hosts/antigravity"
  agy plugin install "$PLUGIN_DIR/hosts/antigravity"
  echo "  Restart/reload Antigravity, then run /dev-workflow:status"
}

prepare_source

case "$TARGET_HOST" in
  claude) install_claude ;;
  cursor) install_cursor ;;
  codex) install_codex ;;
  antigravity) install_antigravity ;;
  all)
    install_claude
    install_cursor
    install_codex
    install_antigravity
    ;;
esac

echo "==> Done: $TARGET_HOST"
echo "    Full guide: $PLUGIN_DIR/docs/INSTALL.md"
