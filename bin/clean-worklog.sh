#!/usr/bin/env bash
# clean-worklog.sh — archive or purge one ticket worklog to free context/disk.
# Usage:
#   clean-worklog.sh <Ticket_ID> [--project slug] [--force] [--purge]
# Default: move worklogs/<Ticket>/ → worklogs/.archive/<Ticket>-<UTC>/
# --purge: hard delete (no archive)
# --force: allow clean when G9 checker not PASS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/resolve-paths.sh
source "$SCRIPT_DIR/lib/resolve-paths.sh"

TICKET=""
SLUG_HINT="${DEV_WORKFLOW_PROJECT_SLUG:-}"
FORCE=0
PURGE=0

usage() {
  echo "Usage: clean-worklog.sh <Ticket_ID> [--project slug] [--force] [--purge]" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) SLUG_HINT="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --purge) PURGE=1; shift ;;
    -h|--help) usage ;;
    *)
      if [[ -z "$TICKET" ]]; then
        TICKET="$1"; shift
      else
        echo "Unknown arg: $1" >&2
        usage
      fi
      ;;
  esac
done

[[ -n "$TICKET" ]] || usage

WORKLOG="$(resolve_worklog_dir "$TICKET" "$SLUG_HINT" || true)"
if [[ -z "${WORKLOG:-}" || ! -d "$WORKLOG" ]]; then
  resolve_project_home "$SLUG_HINT" || {
    echo "ERROR: cannot resolve project home" >&2
    exit 1
  }
  WORKLOG="${DEV_WORKFLOW_PROJECT_HOME}/worklogs/${TICKET}"
fi

if [[ ! -d "$WORKLOG" ]]; then
  echo "ERROR: worklog not found: $WORKLOG" >&2
  exit 1
fi

HOME_P="${DEV_WORKFLOW_PROJECT_HOME:-$(cd "$WORKLOG/../.." && pwd)}"
SLUG="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-$(basename "$HOME_P")}"

case "$WORKLOG" in
  */domain-knowledge|*/domain-knowledge/*)
    echo "ERROR: refuse to clean domain-knowledge" >&2
    exit 1
    ;;
esac

# Only clean under .../worklogs/<Ticket>
case "$WORKLOG" in
  */worklogs/"$TICKET"|*/worklogs/"$TICKET"/)
    ;;
  *)
    echo "ERROR: path not a ticket worklog: $WORKLOG" >&2
    exit 1
    ;;
esac

if [[ $FORCE -eq 0 ]]; then
  if ! "$SCRIPT_DIR/check-gates.sh" "$TICKET" --project "$SLUG" --min G9 >/dev/null 2>&1; then
    echo "REFUSE: ticket ${TICKET} failed G9 check. Finish :ship or re-run with --force." >&2
    echo "hint: /dev-workflow:clean ${TICKET} --force" >&2
    exit 1
  fi
fi

echo "project=${SLUG} home=${HOME_P} ticket=${TICKET} worklog=${WORKLOG}"
KEEP_HINT="domain-knowledge/ PROJECT.md repos/ other worklogs/"

if [[ $PURGE -eq 1 ]]; then
  rm -rf "$WORKLOG"
  echo "PURGED: ${WORKLOG}"
  echo "kept: ${KEEP_HINT}"
  echo "RESULT: PASS (purge)"
  exit 0
fi

ARCHIVE_ROOT="${HOME_P}/worklogs/.archive"
mkdir -p "$ARCHIVE_ROOT"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DEST="${ARCHIVE_ROOT}/${TICKET}-${STAMP}"
[[ -e "$DEST" ]] && DEST="${DEST}-$$"
mv "$WORKLOG" "$DEST"
echo "ARCHIVED: ${DEST}"
echo "kept: ${KEEP_HINT}"
echo "RESULT: PASS (archive)"
echo "Note: archive still on disk — rm -rf ${ARCHIVE_ROOT} for more space."
exit 0
