#!/usr/bin/env bash
# Shared path resolution for dev-workflow — no hardcoded user projects.
# Source from other scripts:  source "$(dirname "$0")/lib/resolve-paths.sh"
#
# Exports (when resolve_* succeeds):
#   DEV_WORKFLOW_PLUGIN_DIR
#   DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED
#   DEV_WORKFLOW_PROJECT_SLUG_RESOLVED
#   DEV_WORKFLOW_PROJECT_HOME
#
# Env overrides (optional):
#   DEV_WORKFLOW_PLUGIN
#   DEV_WORKFLOW_WORKSPACES_ROOT
#   DEV_WORKFLOW_EXTRA_WORKSPACE_ROOTS   (colon-separated)
#   DEV_WORKFLOW_PROJECT_SLUG

_dw_slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}

_dw_default_workspaces_root() {
  echo "${HOME}/.workspaces"
}

_dw_project_home_from_root() {
  local root="$1"
  local slug="$2"
  if [[ -d "$root/workspaces/$slug" || -f "$root/workspaces/$slug/PROJECT.md" ]]; then
    echo "$root/workspaces/$slug"
  else
    echo "$root/$slug"
  fi
}

# Multiple projects under one workspaces root is the normal case (one
# domain repo → one dev-workflow project). PROJECT.md's own "Repos" table
# already declares which real repo path(s) belong to that project — use it
# to answer "which project owns the repo I'm standing in right now" instead
# of making the caller type --project every time more than one project
# exists. Returns the owning slug on stdout when exactly one PROJECT.md's
# Repos table contains a path that is the cwd or an ancestor of it (so it
# still matches from a subdirectory of the repo, not just the repo root).
_dw_match_project_by_cwd_repo() {
  local root="$1" cwd="$2"
  local -a matches=()
  local pf slug repo_path real_repo_path real_cwd
  real_cwd="$(cd "$cwd" 2>/dev/null && pwd || echo "$cwd")"
  for pf in "$root"/*/PROJECT.md "$root/workspaces"/*/PROJECT.md; do
    [[ -f "$pf" ]] || continue
    slug="$(basename "$(dirname "$pf")")"
    while IFS= read -r repo_path; do
      [[ -z "$repo_path" ]] && continue
      real_repo_path="$(cd "$repo_path" 2>/dev/null && pwd || echo "")"
      [[ -z "$real_repo_path" ]] && continue
      if [[ "$real_cwd" == "$real_repo_path" || "$real_cwd" == "$real_repo_path"/* ]]; then
        matches+=("$slug")
        break
      fi
    done < <(awk -F'|' '
      /^\|/ && $0 !~ /^\|[[:space:]]*-+[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*Repo slug/ {
        p = $3
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", p)
        gsub(/`/, "", p)
        if (p != "") print p
      }
    ' "$pf" 2>/dev/null)
  done
  # dedupe (a project could list the same repo path twice)
  local -a uniq=()
  local m seen
  for m in "${matches[@]:-}"; do
    [[ -z "$m" ]] && continue
    seen=0
    for s in "${uniq[@]:-}"; do [[ "$s" == "$m" ]] && { seen=1; break; }; done
    [[ $seen -eq 0 ]] && uniq+=("$m")
  done
  if [[ ${#uniq[@]} -eq 1 ]]; then
    echo "${uniq[0]}"
    return 0
  fi
  return 1
}

# Plugin install dir (this package), never a customer app path.
resolve_plugin_dir() {
  if [[ -n "${DEV_WORKFLOW_PLUGIN:-}" && -x "${DEV_WORKFLOW_PLUGIN}/bin/check-gates.sh" ]]; then
    DEV_WORKFLOW_PLUGIN_DIR="$(cd "$DEV_WORKFLOW_PLUGIN" && pwd)"
    return 0
  fi
  local cand
  for cand in \
    "${HOME}/.claude/skills/dev-workflow-plugin" \
    "${HOME}/.claude/plugins/dev-workflow" \
    "${HOME}/.codex/plugins/dev-workflow" \
    "${HOME}/.cursor/skills/dev-workflow"
  do
    if [[ -x "${cand}/bin/check-gates.sh" ]]; then
      DEV_WORKFLOW_PLUGIN_DIR="$(cd "$cand" && pwd)"
      return 0
    fi
    # cursor thin pointer — follow sibling or env only
  done
  # caller script under plugin/bin or plugin/bin/lib
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
  if [[ -x "${here}/check-gates.sh" ]]; then
    DEV_WORKFLOW_PLUGIN_DIR="$(cd "${here}/.." && pwd)"
    return 0
  fi
  if [[ -x "${here}/../check-gates.sh" ]]; then
    DEV_WORKFLOW_PLUGIN_DIR="$(cd "${here}/../.." && pwd)"
    return 0
  fi
  return 1
}

# Collect candidate workspace roots from cwd / git / env (user project auto).
_dw_collect_workspace_roots() {
  local -a roots=()
  local d git_root

  [[ -n "${DEV_WORKFLOW_WORKSPACES_ROOT:-}" ]] && roots+=("$DEV_WORKFLOW_WORKSPACES_ROOT")
  roots+=("$(_dw_default_workspaces_root)")

  d="${PWD}"
  local i
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    [[ -d "$d/workspaces" ]] && roots+=("$d")
    [[ -d "$d/.workspaces" ]] && roots+=("$d/.workspaces")
    [[ -f "$d/.dev-workflow.json" ]] && roots+=("$d")
    [[ -d "$d/tasks/domain-knowledge" ]] && roots+=("$d")
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done

  if command -v git >/dev/null 2>&1; then
    git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$git_root" ]]; then
      roots+=("$git_root")
      roots+=("$(dirname "$git_root")")
    fi
  fi

  roots+=("$PWD")

  if [[ -n "${DEV_WORKFLOW_EXTRA_WORKSPACE_ROOTS:-}" ]]; then
    local IFS=':'
    local e
    for e in $DEV_WORKFLOW_EXTRA_WORKSPACE_ROOTS; do
      [[ -n "$e" ]] && roots+=("$e")
    done
  fi

  # dedupe preserve order
  local -a out=()
  local r seen
  for r in "${roots[@]}"; do
    [[ -d "$r" ]] || continue
    seen=0
    for x in "${out[@]:-}"; do
      [[ "$x" == "$r" ]] && { seen=1; break; }
    done
    [[ $seen -eq 0 ]] && out+=("$r")
  done
  printf '%s\n' "${out[@]}"
}

# Read slug from .dev-workflow.json if present: {"projectSlug":"…"} or {"slug":"…"}
_dw_slug_from_marker() {
  local dir="$1"
  local f="$dir/.dev-workflow.json"
  [[ -f "$f" ]] || return 1
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$f" <<'PY' 2>/dev/null
import json,sys
d=json.load(open(sys.argv[1]))
print(d.get("projectSlug") or d.get("slug") or "")
PY
  fi
}

# Infer project slug from user tree (no product hardcode).
resolve_project_slug() {
  local hint="${1:-${DEV_WORKFLOW_PROJECT_SLUG:-}}"
  if [[ -n "$hint" ]]; then
    DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$(_dw_slugify "$hint")"
    return 0
  fi

  local root line slug f
  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    # Strongest signal first: does any PROJECT.md's own Repos table declare
    # the repo we're standing in right now? Multiple projects under one
    # workspaces root is the normal case (one domain repo per project), so
    # this must be tried before falling back to "there happens to be only
    # one project total" — that fallback is wrong the moment a second
    # project exists, even though the caller is unambiguously standing in
    # a specific repo the whole time.
    slug="$(_dw_match_project_by_cwd_repo "$root" "$PWD" || true)"
    if [[ -n "${slug:-}" ]]; then
      DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$(_dw_slugify "$slug")"
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$root"
      return 0
    fi
    slug="$(_dw_slug_from_marker "$root" || true)"
    if [[ -n "${slug:-}" ]]; then
      DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$(_dw_slugify "$slug")"
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$root"
      return 0
    fi
    # nearest workspaces/*/PROJECT.md or ~/.workspaces/<slug>/PROJECT.md
    local -a homes=()
    if [[ -d "$root/workspaces" ]]; then
      for f in "$root/workspaces"/*/PROJECT.md; do
        [[ -f "$f" ]] || continue
        homes+=("$(basename "$(dirname "$f")")")
      done
    fi
    for f in "$root"/*/PROJECT.md; do
      [[ -f "$f" ]] || continue
      homes+=("$(basename "$(dirname "$f")")")
    done
    if [[ ${#homes[@]} -eq 1 ]]; then
      DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="${homes[0]}"
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$root"
      return 0
    fi
    # More than one project under this root and no explicit --project hint:
    # silently falling through to a lower-priority root here would let the
    # script pick an unrelated project's slug with zero warning (verified:
    # a workspaces root with proj-a/ and proj-b/ both present caused this to
    # fall through to an entirely different root and return that root's
    # unrelated single project). Ambiguity at the *highest-priority* root is
    # not something a lower-priority root should silently resolve for the
    # caller — stop here and force an explicit --project instead of guessing
    # which of several real projects the caller meant.
    if [[ ${#homes[@]} -gt 1 ]]; then
      echo "ERROR: ambiguous project — multiple PROJECT.md found under $root: ${homes[*]}. Pass --project <slug>." >&2
      return 1
    fi
  done < <(_dw_collect_workspace_roots)

  # cwd / git folder name as last resort slug hint (do not create yet)
  local base
  if command -v git >/dev/null 2>&1; then
    base="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "")")"
  fi
  [[ -z "$base" || "$base" == "." ]] && base="$(basename "$PWD")"
  if [[ -n "$base" && "$base" != "/" ]]; then
    DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$(_dw_slugify "$base")"
    return 0
  fi
  return 1
}

resolve_workspaces_root() {
  local prefer_slug="${1:-${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}}"
  local root f

  if [[ -n "${DEV_WORKFLOW_WORKSPACES_ROOT:-}" && -d "${DEV_WORKFLOW_WORKSPACES_ROOT}" ]]; then
    DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$DEV_WORKFLOW_WORKSPACES_ROOT" && pwd)"
    return 0
  fi

  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    if [[ -n "$prefer_slug" && -f "$(_dw_project_home_from_root "$root" "$prefer_slug")/PROJECT.md" ]]; then
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
      return 0
    fi
  done < <(_dw_collect_workspace_roots)

  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    if [[ "$root" == "$(_dw_default_workspaces_root)" ]]; then
      mkdir -p "$root"
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
      return 0
    fi
    if [[ -d "$root/workspaces" ]]; then
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
      return 0
    fi
    if [[ -f "$root/.dev-workflow.json" ]]; then
      DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
      return 0
    fi
  done < <(_dw_collect_workspace_roots)

  # Default: always outside repo under ~/.workspaces
  mkdir -p "$(_dw_default_workspaces_root)"
  DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$(_dw_default_workspaces_root)" && pwd)"
  return 0
}

resolve_project_home() {
  local slug="${1:-}"
  resolve_project_slug "$slug" || true
  slug="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}"
  [[ -n "$slug" ]] || return 1
  resolve_workspaces_root "$slug" || return 1
  DEV_WORKFLOW_PROJECT_HOME="$(_dw_project_home_from_root "$DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED" "$slug")"
  return 0
}

# Find worklog dir for ticket under auto-detected roots.
resolve_worklog_dir() {
  local ticket="$1"
  local slug="${2:-}"
  local root candidate

  resolve_project_slug "$slug" || true
  slug="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}"

  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    if [[ -n "$slug" ]]; then
      candidate="$(_dw_project_home_from_root "$root" "$slug")/worklogs/$ticket"
      if [[ -d "$candidate" ]]; then
        echo "$(cd "$candidate" && pwd)"
        DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
        DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$slug"
        DEV_WORKFLOW_PROJECT_HOME="$(cd "$(_dw_project_home_from_root "$root" "$slug")" && pwd)"
        return 0
      fi
    else
      for candidate in "$root/workspaces"/*/worklogs/"$ticket" "$root"/*/worklogs/"$ticket"; do
        if [[ -d "$candidate" ]]; then
          echo "$(cd "$candidate" && pwd)"
          DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED="$(cd "$root" && pwd)"
          DEV_WORKFLOW_PROJECT_SLUG_RESOLVED="$(basename "$(dirname "$(dirname "$candidate")")")"
          DEV_WORKFLOW_PROJECT_HOME="$(cd "$(dirname "$(dirname "$candidate")")" && pwd)"
          return 0
        fi
      done
    fi
  done < <(_dw_collect_workspace_roots)
  return 1
}
