#!/usr/bin/env bash
# Safely update dev-workflow source and refresh one or all coding-agent integrations.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOST="claude"
TARGET_EXPLICIT=0

usage() {
  cat <<'EOF'
Usage: bash update.sh [--claude|--cursor|--codex|--agy|--all]
       bash update.sh [--host|--agent] claude|cursor|codex|antigravity|all

Default: claude

Updates the repository with git pull --ff-only, then refreshes the selected host.
The repository worktree must be clean.

Options:
  --claude               Update and refresh Claude Code only
  --cursor               Update and refresh Cursor only
  --codex                Update and refresh Codex only
  --agy, --antigravity   Update and refresh Antigravity only
  --all                  Update and refresh every supported coding agent
  --host, --agent <name>  Select one coding agent, or all
  --list-hosts            Print supported coding agents
  -h, --help              Show this help

Examples:
  bash update.sh                         # Claude only
  bash update.sh --cursor                # Cursor only
  bash update.sh --codex                 # Codex only
  bash update.sh --agy                   # Antigravity only
  bash update.sh --all                   # Every supported agent
EOF
}

select_target() {
  local requested="$1"
  if [[ "$TARGET_EXPLICIT" -eq 1 && "$TARGET_HOST" != "$requested" ]]; then
    echo "ERROR: conflicting update targets '$TARGET_HOST' and '$requested'; choose exactly one target" >&2
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

command -v git >/dev/null 2>&1 || {
  echo "ERROR: git not found; source was not updated" >&2
  exit 1
}

if [[ "$TARGET_HOST" == "antigravity" || "$TARGET_HOST" == "all" ]]; then
  command -v agy >/dev/null 2>&1 || {
    echo "ERROR: agy CLI not found; source and hosts were not updated" >&2
    exit 1
  }
fi

if [[ -n "$(git -C "$PLUGIN_DIR" status --porcelain)" ]]; then
  echo "ERROR: repository has uncommitted changes; commit or stash them before update" >&2
  exit 1
fi

echo "==> Updating source with fast-forward only"
if ! git -C "$PLUGIN_DIR" pull --ff-only; then
  echo "ERROR: git pull --ff-only failed; host integration was not refreshed" >&2
  exit 1
fi

echo "==> Refreshing target: $TARGET_HOST"
if ! bash "$PLUGIN_DIR/install.sh" --host "$TARGET_HOST"; then
  echo "ERROR: source updated, but host refresh failed; rerun install.sh for '$TARGET_HOST'" >&2
  exit 1
fi

echo "==> Update complete: $TARGET_HOST"
