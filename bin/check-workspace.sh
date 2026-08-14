#!/usr/bin/env bash
# check-workspace.sh — verify workspaces/<slug>/ layout is healthy.
# Usage: check-workspace.sh [project-slug]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/resolve-paths.sh
source "$SCRIPT_DIR/lib/resolve-paths.sh"

SLUG_HINT="${1:-${DEV_WORKFLOW_PROJECT_SLUG:-}}"
FAILS=0
WARNS=0

pass() { echo "PASS  $1 — $2"; }
fail() { echo "FAIL  $1 — $2"; FAILS=$((FAILS + 1)); }
warn() { echo "WARN  $1 — $2"; WARNS=$((WARNS + 1)); }

if ! resolve_plugin_dir; then
  fail W0 "cannot resolve plugin dir (set DEV_WORKFLOW_PLUGIN)"
  echo "RESULT: FAIL"
  exit 1
fi
pass W0 "plugin=${DEV_WORKFLOW_PLUGIN_DIR}"

if ! resolve_project_home "$SLUG_HINT"; then
  fail W0 "cannot resolve project home (slug/root)"
  echo "RESULT: FAIL"
  exit 1
fi

ROOT="${DEV_WORKFLOW_WORKSPACES_ROOT_RESOLVED}"
HOME_P="${DEV_WORKFLOW_PROJECT_HOME}"
SLUG="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED}"
echo "project=${SLUG} home=${HOME_P} root=${ROOT}"

if [[ ! -f "${HOME_P}/PROJECT.md" ]]; then
  fail W1 "missing PROJECT.md"
else
  if grep -qE 'Slug:|\*\*Slug:\*\*' "${HOME_P}/PROJECT.md"; then
    pass W1 "PROJECT.md present"
  else
    fail W1 "PROJECT.md missing Slug field"
  fi
fi

if [[ ! -d "${HOME_P}/domain-knowledge" ]]; then
  fail W2 "missing domain-knowledge/"
elif [[ ! -f "${HOME_P}/domain-knowledge/INDEX.md" ]]; then
  fail W2 "missing domain-knowledge/INDEX.md"
else
  pass W2 "domain-knowledge/INDEX.md ok"
fi

if [[ ! -d "${HOME_P}/worklogs" ]]; then
  fail W3 "missing worklogs/"
else
  pass W3 "worklogs/ exists"
fi

# W4: only project home root + worklogs/ root (not nested ticket dirs)
stray=0
shopt -s nullglob
for f in "${HOME_P}"/0*.md "${HOME_P}"/INDEX.md \
         "${HOME_P}/worklogs"/0*.md "${HOME_P}/worklogs"/INDEX.md; do
  if [[ -f "$f" ]]; then
    echo "       stray: ${f#"${HOME_P}/"}"
    stray=1
  fi
done
shopt -u nullglob

if [[ ! -d "${HOME_P}/worklogs" ]]; then
  fail W4 "skipped (no worklogs/)"
elif [[ $stray -eq 1 ]]; then
  fail W4 "worklog-like files outside worklogs/<Ticket_ID>/"
else
  pass W4 "no stray worklog artifacts at project/worklogs root"
fi

# W5 warn: each ticket dir should have INDEX.md
if [[ -d "${HOME_P}/worklogs" ]]; then
  missing_idx=0
  shopt -s nullglob
  for d in "${HOME_P}/worklogs"/*/; do
    base="$(basename "$d")"
    [[ "$base" == .archive ]] && continue
    if [[ ! -f "${d}INDEX.md" ]]; then
      warn W5 "worklogs/${base}/ missing INDEX.md"
      missing_idx=1
    fi
  done
  shopt -u nullglob
  if [[ $missing_idx -eq 0 ]]; then
    pass W5 "ticket INDEX.md present (or no tickets yet)"
  fi
fi

# W6 marker slug
MARKER="${ROOT}/.dev-workflow.json"
if [[ -f "$MARKER" ]]; then
  mslug="$(_dw_slug_from_marker "$ROOT" || true)"
  if [[ -n "${mslug:-}" && "$mslug" != "$SLUG" ]]; then
    warn W6 "marker slug=${mslug} != folder slug=${SLUG}"
  else
    pass W6 "marker ok or unused"
  fi
else
  pass W6 "no .dev-workflow.json (optional)"
fi

if [[ $FAILS -gt 0 ]]; then
  echo "RESULT: FAIL (${FAILS} fail, ${WARNS} warn)"
  exit 1
fi
echo "RESULT: PASS (${WARNS} warn)"
exit 0
