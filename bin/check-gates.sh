#!/usr/bin/env bash
# check-gates.sh — gate checker for dev-workflow (v0.4.0).
# Exit 0 = PASS. Exit 1 = FAIL. Exit 2 = usage/path error.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/resolve-paths.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/resolve-paths.sh"
resolve_plugin_dir || DEV_WORKFLOW_PLUGIN_DIR="$PLUGIN_DIR"
PLUGIN_DIR="${DEV_WORKFLOW_PLUGIN_DIR:-$PLUGIN_DIR}"

TICKET=""
PROJECT_SLUG=""
MIN_GATE="G8"
STRICT=0
VERIFY_NET=0
JSON=0
FAILS=()
WARNS=()
WAIVES=()
RISK="P1"

usage() {
  cat <<EOF
Usage: $(basename "$0") <Ticket_ID> [--project <slug>] [--min G0|…|G9|AUDIT] [--strict] [--verify-net] [--json]

Default --min G8. Merge: --min G9 --strict (implies --verify-net).
Ship final: --min AUDIT (requires G9 PASS + 08-semantic-audit.md human sign-off).
--strict: CI-native verify; no P2 soft; no G8 WAIVE; enable --verify-net.
G3 requires INDEX phrase + 03b-human-confirm.md (no AI names).
P0: 02b-security.md. Pilot:yes on INDEX requires pilot log row at G9.

Exit: 0 PASS · 1 FAIL · 2 usage/path error
EOF
}

gate_rank() {
  case "$1" in
    G0) echo 0 ;; G1) echo 1 ;; G2) echo 2 ;; G3) echo 3 ;;
    G4) echo 4 ;; G5) echo 5 ;; G6) echo 6 ;; G7) echo 7 ;;
    G8) echo 8 ;; G9) echo 9 ;; AUDIT) echo 10 ;;
    *) echo 99 ;;
  esac
}

need_gate() {
  local g="$1"
  [[ "$(gate_rank "$g")" -le "$(gate_rank "$MIN_GATE")" ]]
}

p2_soft_gate() {
  local g="$1"
  [[ "$RISK" == "P2" && "$STRICT" -eq 0 && ( "$g" == "G2" || "$g" == "G4" || "$g" == "G5" || "$g" == "G7" ) ]]
}

fail() { FAILS+=("$1"); }
warn() { WARNS+=("$1"); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_SLUG="${2:-}"; shift 2 ;;
    --min) MIN_GATE="${2:-G8}"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    --verify-net) VERIFY_NET=1; shift ;;
    --json) JSON=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Unknown flag: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "$TICKET" ]]; then TICKET="$1"; shift
      else echo "Unexpected arg: $1" >&2; usage; exit 2
      fi
      ;;
  esac
done

[[ -n "$TICKET" ]] || { usage; exit 2; }

# --strict implies network verify when CI URLs are checked
if [[ "$STRICT" -eq 1 ]]; then
  VERIFY_NET=1
fi

if [[ -n "$PROJECT_SLUG" ]]; then
  export DEV_WORKFLOW_PROJECT_SLUG="$PROJECT_SLUG"
fi
WORKLOG="$(resolve_worklog_dir "$TICKET" "${PROJECT_SLUG:-}" || true)"
if [[ -z "${WORKLOG:-}" ]]; then
  resolve_project_slug "${PROJECT_SLUG:-}" || true
  WORKLOG="$(resolve_worklog_dir "$TICKET" "${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}" || true)"
fi
if [[ -z "${WORKLOG:-}" ]]; then
  echo "ERROR: worklog not found for ticket=$TICKET" >&2
  exit 2
fi

PROJECT_HOME="${DEV_WORKFLOW_PROJECT_HOME:-$(cd "$WORKLOG/../.." && pwd)}"
PROJECT_SLUG="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-$(basename "$PROJECT_HOME")}"
echo "resolved: project=$PROJECT_SLUG home=$PROJECT_HOME worklog=$WORKLOG" >&2

INDEX="$WORKLOG/INDEX.md"
SPEC="$WORKLOG/02-spec.md"
SECURITY="$WORKLOG/02b-security.md"
HCONFIRM="$WORKLOG/03b-human-confirm.md"
CREPORT="$WORKLOG/03-clarify-report.md"
QALOG="$WORKLOG/03-qa-log.md"
PLAN="$WORKLOG/04-plan.md"
IMPL="$WORKLOG/05-impl-log.md"
REVIEW="$WORKLOG/06-review-qa.md"
FIXLOG="$WORKLOG/06c-fix-log.md"
TESTEV="$WORKLOG/06b-test-evidence.md"
SHIP="$WORKLOG/07-ship.md"
AUDIT="$WORKLOG/08-semantic-audit.md"
DK_INDEX="$PROJECT_HOME/domain-knowledge/INDEX.md"
PROJECT_MD="$PROJECT_HOME/PROJECT.md"
PILOT_DIR="$PROJECT_HOME/pilot"

file_ok() { [[ -f "$1" ]]; }

detect_risk() {
  RISK="P1"
  local f
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P0|\[x\] P0|\[X\] P0' "$f" 2>/dev/null; then RISK="P0"; return; fi
  done
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P2|\[x\] P2|\[X\] P2' "$f" 2>/dev/null; then RISK="P2"; return; fi
  done
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P1|\[x\] P1|\[X\] P1' "$f" 2>/dev/null; then RISK="P1"; return; fi
  done
}

table_val() {
  local file="$1" key="$2"
  awk -F'|' -v k="$key" '
    tolower($0) ~ tolower(k) {
      v=$3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      print v
      exit
    }
  ' "$file" 2>/dev/null || true
}

detect_risk
REQUIRE_MACHINE=0
if [[ "$STRICT" -eq 1 || "$RISK" == "P0" || "$RISK" == "P1" ]]; then
  REQUIRE_MACHINE=1
fi
# --strict implies native verify of local artifacts
VERIFY_NATIVE=0
if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
  VERIFY_NATIVE=1
fi

if file_ok "$INDEX"; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(G[0-9][^|]*)\| ]]; then
      WAIVES+=("$line")
    fi
  done < <(grep -E '^\s*-\s*G[0-9]' "$INDEX" 2>/dev/null || true)
fi

waived() {
  local gate="$1"
  local w
  if [[ "$gate" == "G8" && ( "$STRICT" -eq 1 || "$RISK" == "P0" ) ]]; then
    return 1
  fi
  if [[ "$gate" == "G3" && "$RISK" == "P0" ]]; then
    return 1
  fi
  for w in "${WAIVES[@]:-}"; do
    if [[ "$w" == *"$gate"* ]]; then
      local pipes
      pipes="$(awk -F'|' '{print NF}' <<<"$w")"
      if [[ "$pipes" -ge 4 ]]; then
        if [[ "$w" =~ [Mm]oney|[Pp]ermission|[Ll]egacy|[Pp][Ii][Ii] ]]; then
          if [[ ! "$w" =~ [Pp][Mm] ]]; then
            continue
          fi
        fi
        return 0
      fi
    fi
  done
  return 1
}

maybe_fail() {
  local gate="$1"
  local msg="$2"
  if waived "$gate"; then
    warn "$gate WAIVED: $msg"
    return
  fi
  if p2_soft_gate "$gate"; then
    warn "$gate SOFT(P2): $msg"
    return
  fi
  fail "$gate FAIL: $msg"
}

ui_ticket() {
  if file_ok "$SPEC" && grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes|Touches UI\?\*\*.*Yes' "$SPEC"; then
    return 0
  fi
  return 1
}

placeholderish() {
  local v="$1"
  [[ -z "$v" || "$v" =~ ^\[.*\]$ || "$v" == "…" || "$v" == "..." ]]
}

field_nonempty() {
  local file="$1" label="$2"
  local line
  line="$(grep -i "$label" "$file" 2>/dev/null | head -1 || true)"
  [[ -n "$line" ]] || return 1
  [[ ! "$line" =~ \.\.\.|… ]] || return 1
  return 0
}

verify_junit_file() {
  local path="$1"
  # resolve relative to cwd or worklog
  local f="$path"
  if [[ ! -f "$f" && -f "$WORKLOG/$path" ]]; then f="$WORKLOG/$path"; fi
  if [[ ! -f "$f" && -f "$PROJECT_HOME/$path" ]]; then f="$PROJECT_HOME/$path"; fi
  if [[ ! -f "$f" ]]; then
    maybe_fail G8 "CI-native: junit/log path not found: $path"
    return
  fi
  if grep -qE 'failures="[1-9][0-9]*"|errors="[1-9][0-9]*"|<failure|<error' "$f" 2>/dev/null; then
    maybe_fail G8 "CI-native: junit/log reports failures/errors: $f"
  fi
}

verify_sha_git() {
  local sha="$1"
  local head="" root=""
  if git -C "$PROJECT_HOME" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$PROJECT_HOME"
    head="$(git -C "$PROJECT_HOME" rev-parse HEAD 2>/dev/null || true)"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    head="$(git rev-parse HEAD 2>/dev/null || true)"
  else
    warn "G8: no git repo to verify SHA against"
    return
  fi
  [[ -n "$head" ]] || return
  if [[ "$head" == "$sha"* || "$sha" == "$head"* || "$head" == "${sha:0:7}"* ]]; then
    return
  fi
  if [[ "$WORKLOG" == *"/fixtures/"* ]]; then
    warn "G8: fixture SHA $sha != HEAD ${head:0:12} (skipped hard fail)"
    return
  fi
  maybe_fail G8 "CI-native: Commit SHA $sha does not match git HEAD ${head:0:12}…"
}

# A length-only check ("must be >= N chars") passes any string that long,
# meaningless included ("abc abc abc abc" clears a 10-char minimum with
# room to spare). This cannot become true semantic validation with regex —
# that needs a human or an LLM reader — but it can catch the laziest,
# most common form of gaming a length gate: a single short token repeated,
# or a well-known placeholder word, standing in for real content. Anything
# that passes this is not proven meaningful; anything that fails it is
# provably not — a useful one-directional signal, not a quality score.
low_signal_text() {
  local text="$1"
  local lower
  lower="$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" =~ ^(tbd|todo|fixme|xxx|n/?a|lorem|placeholder|abc|test|asdf|foo|bar)([[:space:][:punct:]].*)?$ ]]; then
    return 0
  fi
  local word_count uniq_count
  word_count="$(printf '%s' "$lower" | tr -cs '[:alnum:]' '\n' | grep -cE '.' || true)"
  uniq_count="$(printf '%s' "$lower" | tr -cs '[:alnum:]' '\n' | grep -E '.' | sort -u | wc -l | tr -d ' ' || true)"
  word_count="${word_count:-0}"
  uniq_count="${uniq_count:-0}"
  if [[ "$word_count" -ge 3 && "$uniq_count" -le 1 ]]; then
    return 0
  fi
  return 1
}

verify_ci_url() {
  local url="$1"
  [[ "$url" =~ ^https?:// ]] || return
  if [[ "$VERIFY_NET" -ne 1 ]]; then
    warn "G8: CI URL present (use --verify-net to HTTP-check)"
    return
  fi
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsI --max-time 8 "$url" >/dev/null 2>&1; then
      maybe_fail G8 "CI-native: CI URL not reachable: $url"
    fi
  else
    warn "G8: curl missing — skip --verify-net"
  fi
}

# --- G0 ---
if need_gate G0; then
  file_ok "$PROJECT_MD" || maybe_fail G0 "missing PROJECT.md at $PROJECT_HOME"
  file_ok "$DK_INDEX" || maybe_fail G0 "missing domain-knowledge/INDEX.md"
  if file_ok "$DK_INDEX"; then
    # File existing is not knowledge — an empty INDEX.md with the template
    # skeleton still passed the old check. Require the two signals the
    # template's own "G0 DoD" section defines as done: "Needs learning" must
    # be explicitly "no", and the Present table must have at least one area
    # actually ticked (not every row still "☐").
    if grep -qiE 'Needs learning:\*{0,2}[[:space:]]*(☑[[:space:]]*yes|\[x\][[:space:]]*yes|yes)\b' "$DK_INDEX"; then
      maybe_fail G0 "domain-knowledge/INDEX Needs learning = yes — run :learning first"
    elif ! grep -qiE 'Needs learning:\*{0,2}[[:space:]]*(☑[[:space:]]*no|\[x\][[:space:]]*no|no)\b' "$DK_INDEX"; then
      maybe_fail G0 "domain-knowledge/INDEX Needs learning not set to explicit no"
    fi
    present_ticked="$(grep -cE '☑|\[x\]|\[X\]' "$DK_INDEX" 2>/dev/null || true)"
    present_ticked="${present_ticked:-0}"
    dk_lines="$(wc -l < "$DK_INDEX" 2>/dev/null | tr -d ' ' || echo 0)"
    if [[ "$present_ticked" -eq 0 && "$dk_lines" -gt 8 ]]; then
      maybe_fail G0 "domain-knowledge/INDEX Present/Coverage table has no area marked done (all ☐)"
    fi
    # references/locale.md: the first /dev-workflow:* command in a workspace
    # must ask the user's preferred chat language once and store it here —
    # not re-derive it by guessing from message text on every turn. Soft
    # warn (not hard fail): this field is additive to worklogs created
    # before locale-ask existed, and a missing value degrades to English
    # fallback per locale.md rather than blocking the pipeline.
    if ! grep -qE 'Chat locale:\*{0,2}[[:space:]]*(vi|en|ja|[a-z]{2})\b' "$DK_INDEX" 2>/dev/null; then
      warn "G0: domain-knowledge/INDEX Chat locale not set — should have been asked on first /dev-workflow:* command (see references/locale.md)"
    fi
    # DoD line 5 of the template: "Last learning or Last coaching within 90
    # days if touching that domain". A ticked Present area from a session 2
    # years ago is not current knowledge — check the more recent of the two
    # dates against a 90-day window. Only enforced once a real date is
    # recorded (a still-templated "…" date means the session never
    # happened, which is already caught by present_ticked above).
    last_learning_date="$(grep -A2 -i '## Last learning session' "$DK_INDEX" 2>/dev/null | grep -iE '^-?\s*Date:' | head -1 | sed -E 's/.*Date:[[:space:]]*//' || true)"
    last_coaching_date="$(grep -A2 -i '## Last coaching session' "$DK_INDEX" 2>/dev/null | grep -iE '^-?\s*Date:' | head -1 | sed -E 's/.*Date:[[:space:]]*//' || true)"
    newest_date=""
    for d in "$last_learning_date" "$last_coaching_date"; do
      if [[ "$d" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        if [[ -z "$newest_date" || "$d" > "$newest_date" ]]; then newest_date="$d"; fi
      fi
    done
    if [[ -n "$newest_date" ]]; then
      days_old=""
      if days_old="$(python3 -c "
import datetime,sys
try:
    d = datetime.date.fromisoformat(sys.argv[1])
    print((datetime.date.today() - d).days)
except Exception:
    pass
" "$newest_date" 2>/dev/null)"; then
        if [[ -n "$days_old" && "$days_old" =~ ^[0-9]+$ && "$days_old" -gt 90 ]]; then
          warn "G0: domain-knowledge last learning/coaching was $days_old days ago (>90) — confirm still accurate for this ticket"
        fi
      fi
    fi
  fi
fi

# --- G1 ---
if need_gate G1; then
  file_ok "$SPEC" || maybe_fail G1 "missing 02-spec.md"
  if file_ok "$SPEC"; then
    extract_ticket_type() {
      local src="$1"
      awk '
        /Type:/ {
          if ($0 ~ /(☑|\[x\]|\[X\])[[:space:]]*Bug/) print "Bug"
          if ($0 ~ /(☑|\[x\]|\[X\])[[:space:]]*New feature/) print "New feature"
          if ($0 ~ /(☑|\[x\]|\[X\])[[:space:]]*Spec change/) print "Spec change"
          if ($0 ~ /(☑|\[x\]|\[X\])[[:space:]]*Requirement change/) print "Requirement change"
        }
      ' "$src" 2>/dev/null
    }
    index_types="$(extract_ticket_type "$INDEX")"
    spec_types="$(extract_ticket_type "$SPEC")"
    index_type_count="$(printf '%s\n' "$index_types" | grep -cE '.' || true)"
    spec_type_count="$(printf '%s\n' "$spec_types" | grep -cE '.' || true)"
    [[ "$index_type_count" -eq 1 ]] || maybe_fail G1 "INDEX must select exactly one ticket Type"
    [[ "$spec_type_count" -eq 1 ]] || maybe_fail G1 "02-spec must select exactly one ticket Type"
    if [[ "$index_type_count" -eq 1 && "$spec_type_count" -eq 1 && "$index_types" != "$spec_types" ]]; then
      maybe_fail G1 "ticket Type mismatch: INDEX=$index_types 02-spec=$spec_types"
    fi
    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      grep -qiE '^##[[:space:]]+Requirement provenance' "$SPEC" || \
        maybe_fail G1 "02-spec missing Requirement provenance"
      grep -qE '\|[[:space:]]*(AC|NEG|PERM|EDGE)-[0-9]+[[:space:]]*\|[[:space:]]*(OBSERVED|DOCUMENTED|INFERRED|UNVERIFIED|CONFLICTING)' "$SPEC" || \
        maybe_fail G1 "02-spec has no requirement row with a truth label and provenance"
    fi
    # Old check accepted "Given" appearing anywhere in the file (even inside
    # unrelated prose) as proof the AC section exists. Require the actual
    # heading — both the fixture's minimal schema and the full template use
    # "## Scenario AC", so this is not a schema-specific tightening.
    grep -qE '^##[[:space:]]*Scenario AC' "$SPEC" || maybe_fail G1 "02-spec missing '## Scenario AC' heading"
    if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$SPEC"; then
      maybe_fail G1 "no filled AC-xx row (Given empty / template only)"
    fi
    if ! grep -qiE '☑ P[012]|\[x\] P[012]|\[X\] P[012]' "$SPEC" && \
       ! grep -qiE '☑ P[012]|\[x\] P[012]|\[X\] P[012]' "$INDEX" 2>/dev/null; then
      maybe_fail G1 "Risk tier P0/P1/P2 not set on spec or INDEX"
    fi
    if ui_ticket; then
      grep -qE 'UI states|Happy' "$SPEC" || maybe_fail G1 "Touches UI=Yes but UI states section missing"
    fi
    # NEG/PERM/EDGE are the branches code-review.md's "missing" defect class
    # hunts for after the fact (P1: "Spec NEG/PERM/EDGE with no code or test
    # path"). Catching the omission at G1 — before a task is even planned —
    # is much cheaper than catching it at G7 after code is written. Do not
    # force every ticket to invent negative/permission/edge cases that don't
    # apply (a copy-only P2 change may have none) — but force an explicit
    # statement: either a real filled row, or an explicit "N/A" with a
    # one-line reason, not a section silently left as the empty template
    # (single placeholder row with every cell blank) or missing entirely.
    check_spec_section() {
      local heading="$1" id_prefix="$2" label="$3"
      if ! grep -qiE "^##[[:space:]]*$heading" "$SPEC"; then
        warn "G1: 02-spec has no '$label' section — confirm this scope truly has none"
        return
      fi
      local filled
      filled="$(awk -v h="$heading" -v pfx="$id_prefix" -F'|' '
        BEGIN { IGNORECASE = 1 }
        $0 ~ ("^##[[:space:]]*" h) { in_sec = 1; next }
        /^##[[:space:]]/ { in_sec = 0 }
        in_sec && $0 ~ ("\\|[[:space:]]*" pfx "-[0-9]+[[:space:]]*\\|") {
          has_content = 0
          for (i = 3; i <= NF; i++) {
            c = $i
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
            # Strip unticked checkbox option pairs like "☐ Yes ☐ No" down to
            # nothing — the leftover "Yes  No" is the template label, not an
            # answer. A *ticked* box (☑/[x]) still counts as real content
            # since it is an actual recorded decision.
            if (c ~ /^☐[[:space:]]*[A-Za-z]+([[:space:]]+☐[[:space:]]*[A-Za-z]+)*$/) { c = "" }
            gsub(/☑|\[x\]|\[X\]/, "", c)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
            if (c != "") has_content = 1
          }
          if (has_content) print "filled"
        }
        in_sec && tolower($0) ~ /n\/?a/ { print "na" }
      ' "$SPEC" 2>/dev/null || true)"
      if ! printf '%s' "$filled" | grep -qE 'filled|na'; then
        maybe_fail G1 "'$label' section present but empty (no filled row, no explicit N/A)"
      fi
    }
    check_spec_section 'Negative[[:space:]]*/[[:space:]]*Error' 'NEG' 'Negative/Error'
    check_spec_section 'Permission[[:space:]]*/[[:space:]]*Authz' 'PERM' 'Permission/Authz'
    check_spec_section 'Edge[[:space:]]*[Cc]ases' 'EDGE' 'Edge cases'
    # QA handoff table: independent QA (human or qa-intelligence-style tool)
    # must be able to build test cases from this spec alone, with no need to
    # ask the dev what a field is called or what "success" looks like on
    # screen. A row with no field/action label and no oracle value is not
    # bindable to a real page element or a machine-checkable signal — same
    # failure mode expert-tester-workflow.md calls out ("Search returns
    # correct results" is not a testcase, it's a wish). Only enforced when
    # Touches UI = Yes; a pure-backend ticket has no screen to bind to.
    if ui_ticket; then
      if grep -qiE 'QA handoff' "$SPEC"; then
        qa_handoff_gaps="$(awk -F'|' '
          /^##.*QA handoff/ { in_qa = 1; next }
          /^##[[:space:]]/ && !/QA handoff/ { in_qa = 0 }
          in_qa && $0 ~ /^\|[[:space:]]*(AC|NEG|PERM|EDGE)-[0-9]+[[:space:]]*\|/ {
            labels = $3; oracle_type = $4; oracle_val = $5
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", labels)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", oracle_type)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", oracle_val)
            deferred = (labels ~ /TBD/ || oracle_val ~ /TBD/)
            if (!deferred && (labels == "" || oracle_val == "" || oracle_val == "…" || oracle_val == "...")) {
              print "row missing field label or oracle value: " $0
            }
          }
        ' "$SPEC" 2>/dev/null || true)"
        qa_handoff_count="$(printf '%s\n' "$qa_handoff_gaps" | grep -cE '.' || true)"
        qa_handoff_count="${qa_handoff_count:-0}"
        if [[ -n "$qa_handoff_gaps" && "$qa_handoff_count" -gt 0 ]]; then
          maybe_fail G1 "$qa_handoff_count QA handoff row(s) missing field/action label or oracle value (not TBD-deferred)"
        fi
      else
        warn "G1: Touches UI=Yes but 02-spec has no 'QA handoff' oracle table — independent QA cannot build test cases without asking the dev"
      fi
    fi
  fi
  # P0 security mini-gate
  if [[ "$RISK" == "P0" ]]; then
    file_ok "$SECURITY" || maybe_fail G1 "P0 requires 02b-security.md (see references/security.md)"
    if file_ok "$SECURITY"; then
      grep -qiE 'Threat note|Abuse cases|Mitigations' "$SECURITY" || maybe_fail G1 "02b-security missing threat note"
      if grep -qiE 'Threat note|Asset at risk' "$SECURITY" && grep -qE 'other: …|other: \.\.\.|Asset at risk:.*…' "$SECURITY"; then
        maybe_fail G1 "02b-security threat note still placeholder"
      fi
      if ! grep -qE '☑ PASS|\[x\] PASS' "$SECURITY"; then
        maybe_fail G1 "02b-security needs at least one PASS in Secrets/PII or contract table"
      fi
    fi
  fi
fi

# --- G2 ---
if need_gate G2; then
  file_ok "$CREPORT" || maybe_fail G2 "missing 03-clarify-report.md"
  if file_ok "$CREPORT"; then
    if grep -qE '## G2' "$CREPORT" && grep -qE 'G2.*☑ FAIL' "$CREPORT"; then
      maybe_fail G2 "03-clarify-report marks G2 FAIL"
    fi
    # Count claim rows whose Match/Status column is NO or UNCLEAR with no
    # Decision recorded — an unconfirmed clarify claim. Table shapes vary
    # (5-col fixture "Status"/"Decision" vs 8-col template "Match?"/"Decision
    # (verbatim)"), so locate columns by header name instead of a fixed
    # index: find the "Match" or "Status" column (the verdict) and the
    # "Decision" column (or reuse Status as both if there is no separate
    # Decision column), then only inspect those exact cells per data row.
    unconfirmed_claims="$(awk -F'|' '
      $0 ~ /^\|[[:space:]]*[Cc]laim[_ ][Ii][Dd][[:space:]]*\|/ {
        for (i = 1; i <= NF; i++) {
          h = $i
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
          hl = tolower(h)
          if (hl ~ /^match/ || hl == "status") verdict_col = i
          if (hl ~ /^decision/) decision_col = i
        }
        if (!decision_col) decision_col = verdict_col
        next
      }
      /^\|[[:space:]]*C-[0-9]+/ && verdict_col {
        verdict = $verdict_col
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", verdict)
        if (verdict ~ /MATCH/ && verdict !~ /NO|UNCLEAR/) next
        if (verdict !~ /NO|UNCLEAR/) next
        decision = (decision_col == verdict_col) ? "" : $decision_col
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", decision)
        gsub(/☐|☑|\[x\]|\[X\]|\[ \]/, "", decision)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", decision)
        if (decision == "" || tolower(decision) ~ /^n\/?a$/) print $0
      }
    ' "$CREPORT" 2>/dev/null || true)"
    unconfirmed_count="$(printf '%s\n' "$unconfirmed_claims" | grep -cE '.' || true)"
    unconfirmed_count="${unconfirmed_count:-0}"
    if [[ -n "$unconfirmed_claims" && "$unconfirmed_count" -gt 0 ]]; then
      maybe_fail G2 "$unconfirmed_count claim row(s) marked NO/UNCLEAR with no recorded Decision"
    fi
  fi
fi

# --- G3 ---
if need_gate G3; then
  file_ok "$INDEX" || maybe_fail G3 "missing INDEX.md (need CONFIRM G3:)"
  file_ok "$HCONFIRM" || maybe_fail G3 "missing 03b-human-confirm.md (anti-forge human confirm file)"
  confirm_ok_phrase() {
    local src="$1"
    grep -qE "CONFIRM G3:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$src"
  }
  banned_ai_name() {
    local src="$1"
    grep -qiE "CONFIRM G3(-PM)?:[[:space:]]*$TICKET[[:space:]]+(AI|ChatGPT|Claude|Copilot|Cursor|Assistant|Bot)\\b" "$src"
  }
  if file_ok "$INDEX"; then
    confirm_ok_phrase "$INDEX" || maybe_fail G3 "INDEX missing CONFIRM G3: $TICKET <name> <YYYY-MM-DD>"
    banned_ai_name "$INDEX" && maybe_fail G3 "INDEX CONFIRM uses forbidden AI/tool name"
  fi
  if file_ok "$HCONFIRM"; then
    confirm_ok_phrase "$HCONFIRM" || maybe_fail G3 "03b-human-confirm.md missing CONFIRM G3 phrase"
    banned_ai_name "$HCONFIRM" && maybe_fail G3 "03b-human-confirm CONFIRM uses forbidden AI/tool name"
    grep -qiE 'Source:.*user-message' "$HCONFIRM" || maybe_fail G3 "03b-human-confirm must set Source: user-message"
    if [[ "$RISK" == "P0" ]]; then
      grep -qE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$HCONFIRM" \
        || maybe_fail G3 "P0 requires CONFIRM G3-PM in 03b-human-confirm.md"
      banned_ai_name "$HCONFIRM" && true
      grep -qiE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+(AI|ChatGPT|Claude|Copilot|Cursor|Assistant|Bot)\\b" "$HCONFIRM" \
        && maybe_fail G3 "CONFIRM G3-PM uses forbidden AI/tool name"
    fi
  fi
  if file_ok "$INDEX" && [[ "$RISK" == "P0" ]]; then
    grep -qE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$INDEX" \
      || maybe_fail G3 "P0 requires CONFIRM G3-PM on INDEX"
  fi
fi

# --- G4 ---
if need_gate G4; then
  file_ok "$PLAN" || maybe_fail G4 "missing 04-plan.md"
  if file_ok "$PLAN"; then
    grep -qE '\|[[:space:]]*[0-9]+[[:space:]]*\|' "$PLAN" || maybe_fail G4 "04-plan has no task rows"
    # A task row existing is not enough — each must actually reference an
    # AC/claim id and carry a real (non-placeholder) test command, or the
    # plan is traceability theater (row present, columns empty). Locate the
    # "AC" / "claim" column and the "DoD"/"test command" column by header
    # name (schema varies: fixture has no DoD column, template has one) and
    # inspect only numbered task rows (col 1 is an integer).
    plan_gaps="$(awk -F'|' '
      $0 ~ /^\|[[:space:]]*#[[:space:]]*\|/ {
        for (i = 1; i <= NF; i++) {
          h = $i
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
          hl = tolower(h)
          if (hl ~ /ac.*claim|claim.*ac/) ac_col = i
          if (hl ~ /dod|test command/) dod_col = i
        }
        next
      }
      ac_col && /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
        ac = $ac_col
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ac)
        if (ac == "" || ac == "…" || ac == "...") { print "row missing AC/claim id: " $0; next }
        if (dod_col) {
          dod = $dod_col
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", dod)
          gsub(/`/, "", dod)
          if (dod == "" || dod == "…" || dod == "...") print "row missing DoD/test command: " $0
        }
      }
    ' "$PLAN" 2>/dev/null || true)"
    plan_gap_count="$(printf '%s\n' "$plan_gaps" | grep -cE '.' || true)"
    plan_gap_count="${plan_gap_count:-0}"
    if [[ -n "$plan_gaps" && "$plan_gap_count" -gt 0 ]]; then
      maybe_fail G4 "$plan_gap_count plan task row(s) missing AC/claim id or DoD/test command"
    fi
    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      grep -qiE '\|[^|]*(Command discovery|Discovery proof)[^|]*\|' "$PLAN" || \
        maybe_fail G4 "04-plan missing Command discovery proof column"
      grep -qE '\|[[:space:]]*[0-9]+[[:space:]]*\|.*\|[[:space:]]*[^|]*(checked|dry-run|--list|existing command)[^|]*\|' "$PLAN" || \
        maybe_fail G4 "04-plan has no verified command discovery proof"
    fi
  fi
fi

# --- G5 ---
if need_gate G5; then
  file_ok "$QALOG" || maybe_fail G5 "missing 03-qa-log.md"
  if file_ok "$QALOG"; then
    # The old check scanned whole lines for "OPEN" not co-occurring with
    # "CONFIRMED"/"ANSWERED" anywhere on the line. That has a real false
    # negative: a question whose *text* happens to contain the word
    # "CONFIRMED" (e.g. "Is this CONFIRMED by legacy behavior or still
    # open?") gets excluded from the count even though its Status column is
    # still OPEN — the row survives by accident of phrasing, not by actual
    # resolution. Status is reliably the last column in both schemas
    # (3-col fixture "ID|Question|Status" and 5-col template
    # "#|claim_id|Agent question|Dev answer|Status"), so read that column
    # specifically instead of the whole line.
    pure_open="$(awk -F'|' '
      /^\|/ && $0 !~ /^\|[[:space:]]*-+[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*(ID|#)[[:space:]]*\|/ {
        status = $(NF-1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
        # Status cell can be a single plain word ("OPEN"/"ANSWERED") or a
        # multi-checkbox option list ("☐ OPEN ☑ CONFIRMED ☐ WAIVED"). For
        # the latter, only the *ticked* option matters — an untouched "☐
        # OPEN" sitting next to a ticked "☑ CONFIRMED" is not an open item,
        # it is the unselected template option. Find which option (if any)
        # is ticked; fall back to plain-word match when there is no
        # checkbox at all.
        ticked = ""
        n = split(status, opts, /☑[[:space:]]*/)
        if (n > 1) {
          split(opts[2], w, /[[:space:]☐]/)
          ticked = w[1]
        } else if (status ~ /\[x\]|\[X\]/) {
          if (status ~ /\[x\][[:space:]]*OPEN|\[X\][[:space:]]*OPEN/) ticked = "OPEN"
          else if (status ~ /\[x\][[:space:]]*CONFIRMED|\[X\][[:space:]]*CONFIRMED/) ticked = "CONFIRMED"
          else if (status ~ /\[x\][[:space:]]*ANSWERED|\[X\][[:space:]]*ANSWERED/) ticked = "ANSWERED"
          else if (status ~ /\[x\][[:space:]]*WAIVED|\[X\][[:space:]]*WAIVED/) ticked = "WAIVED"
        } else if (status ~ /☐/) {
          # Only unticked checkbox options present — no option selected at
          # all is not a resolved state, regardless of which option words
          # appear in the unticked list.
          print $0
          next
        } else {
          ticked = status
        }
        if (ticked == "OPEN") print $0
      }
    ' "$QALOG" 2>/dev/null || true)"
    pure_open_count="$(printf '%s\n' "$pure_open" | grep -cE '.' || true)"
    pure_open_count="${pure_open_count:-0}"
    if [[ -n "$pure_open" && "$pure_open_count" -gt 0 ]]; then
      maybe_fail G5 "$pure_open_count OPEN question(s) in 03-qa-log.md"
    fi
  fi
fi

# --- G6 ---
if need_gate G6; then
  file_ok "$IMPL" || maybe_fail G6 "missing 05-impl-log.md"
  if file_ok "$IMPL"; then
    grep -qE 'Coverage map' "$IMPL" || maybe_fail G6 "05-impl-log missing Coverage map section"
    if grep -qE '☐ MISSING|\| MISSING \|' "$IMPL"; then
      maybe_fail G6 "coverage map still has MISSING"
    fi
    if ! grep -qE '☑ PASS|\[x\] PASS|Result:.*PASS' "$IMPL"; then
      maybe_fail G6 "no PASS evidence in 05-impl-log"
    fi
    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      grep -qiE 'RED command' "$IMPL" || maybe_fail G6 "05-impl-log missing RED command evidence"
      grep -qiE 'Why RED proves' "$IMPL" || maybe_fail G6 "05-impl-log missing explanation of the RED failure"
      grep -qiE 'GREEN (command|result)' "$IMPL" || maybe_fail G6 "05-impl-log missing GREEN evidence"
    fi
    # A row can claim Result=PASS while leaving the Test path column blank —
    # that is an unverifiable claim (which test? never actually run?), not
    # evidence. Locate the "Test" (path) and "Result" columns by header name
    # under the Coverage map table specifically (schema varies: fixture uses
    # "AC | Test | Result", template uses "ID | Test path | Command |
    # Result") and require any row claiming PASS to have a non-empty test
    # reference.
    unverifiable_pass="$(awk -F'|' '
      /^##[[:space:]]*Coverage map/ { in_cov = 1; next }
      /^##[[:space:]]/ && !/Coverage map/ { in_cov = 0 }
      in_cov && $0 ~ /^\|/ && $0 ~ /[Tt]est/ {
        for (i = 1; i <= NF; i++) {
          h = $i
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
          hl = tolower(h)
          if (hl ~ /^test/) test_col = i
          if (hl ~ /^result/) result_col = i
        }
        next
      }
      in_cov && test_col && result_col && /^\|/ && $0 !~ /^\|[[:space:]]*-/ {
        result = $result_col
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", result)
        if (result ~ /PASS/) {
          t = $test_col
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", t)
          gsub(/`/, "", t)
          if (t == "" || t == "…" || t == "...") print "PASS claimed with empty Test path: " $0
        }
      }
    ' "$IMPL" 2>/dev/null || true)"
    unverifiable_count="$(printf '%s\n' "$unverifiable_pass" | grep -cE '.' || true)"
    unverifiable_count="${unverifiable_count:-0}"
    if [[ -n "$unverifiable_pass" && "$unverifiable_count" -gt 0 ]]; then
      maybe_fail G6 "$unverifiable_count coverage row(s) claim PASS with no test path — unverifiable"
    fi
    # Commit SHA is the strongest evidence G6 has (same class of check G8
    # already treats as mandatory: proof the PASS claim was recorded against
    # the code that actually exists, not a stale or imagined state). It was
    # previously optional — "not penalized if absent" — which meant the one
    # field able to prove a build claim wasn't fabricated could simply be
    # skipped. Now required whenever REQUIRE_MACHINE is set (P0/P1 or
    # --strict), matching G8's bar exactly.
    impl_sha="$(table_val "$IMPL" "Commit SHA")"
    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      if placeholderish "$impl_sha" || [[ ! "$impl_sha" =~ [0-9a-fA-F]{7,} ]]; then
        maybe_fail G6 "machine evidence: 05-impl-log Commit SHA missing/invalid (required for P0/P1/--strict)"
      else
        head=""
        if git -C "$PROJECT_HOME" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          head="$(git -C "$PROJECT_HOME" rev-parse HEAD 2>/dev/null || true)"
        fi
        if [[ -n "$head" && "$WORKLOG" == *"/fixtures/"* ]]; then
          warn "G6: fixture SHA $impl_sha != HEAD ${head:0:12} (skipped hard fail)"
        elif [[ -n "$head" ]]; then
          if [[ "$head" != "$impl_sha"* && "$impl_sha" != "$head"* ]]; then
            maybe_fail G6 "05-impl-log Commit SHA $impl_sha does not match git HEAD ${head:0:12}…"
          fi
        fi
      fi
    fi
  fi
fi

# --- G7 ---
if need_gate G7; then
  file_ok "$REVIEW" || maybe_fail G7 "missing 06-review-qa.md"
  if file_ok "$REVIEW"; then
    # code-review.md and :review's own SKILL.md are explicit: "Any P0/P1
    # finding still OPEN -> Result FAIL". Nothing previously checked this —
    # a review file with a P0 injection finding left at Status=OPEN and a
    # hand-written "Result: PASS" checkbox at the bottom passed G7 clean
    # (verified: 0 of 7 failures referenced G7 in that exact scenario). This
    # is the review stage's core promise and the one most under pressure to
    # be rushed; check it first, before any of the softer AC-evidence or
    # sweep-table checks below.
    # Header match accepts a couple of reasonable spellings (Sev/Severity,
    # Status/State) — not just the exact template wording. A reviewer who
    # writes a findings table by hand instead of copying the template
    # verbatim (a likely path, since :review's own SKILL.md describes the
    # fields in prose, not "copy this table exactly") should not silently
    # disable the P0/P1-OPEN check just for using a synonym header.
    p0p1_result="$(awk -F'|' '
      /^##.*Code review findings/ { in_findings = 1; next }
      /^##[[:space:]]/ && !/Code review findings/ { in_findings = 0 }
      in_findings && $0 ~ /^\|[[:space:]]*ID[[:space:]]*\|/ {
        for (i = 1; i <= NF; i++) {
          h = $i
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
          hl = tolower(h)
          if (hl ~ /^sev(erity)?$/) sev_col = i
          if (hl ~ /^(status|state)$/) status_col = i
        }
        header_seen = 1
        next
      }
      in_findings && $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*-+[[:space:]]*\|/ {
        if (!sev_col || !status_col) { data_row_seen = 1; next }
        sev = $sev_col; status = $status_col
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", sev)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
        sev = tolower(sev); status = tolower(status)
        if ((sev == "p0" || sev == "p1") && status == "open") print "OPEN\t" $0
      }
      END {
        if (header_seen && !(sev_col && status_col) && data_row_seen) print "NOCOL\t(no Sev/Status-like columns found)"
      }
    ' "$REVIEW" 2>/dev/null || true)"
    if printf '%s\n' "$p0p1_result" | grep -q '^NOCOL'; then
      warn "G7: Code review findings table has data rows but no recognizable Sev/Status columns — P0/P1-OPEN check could not run, verify manually"
    fi
    open_p0p1="$(printf '%s\n' "$p0p1_result" | grep '^OPEN' || true)"
    open_p0p1_count="$(printf '%s\n' "$open_p0p1" | grep -cE '.' || true)"
    open_p0p1_count="${open_p0p1_count:-0}"
    if [[ -n "$open_p0p1" && "$open_p0p1_count" -gt 0 ]]; then
      maybe_fail G7 "$open_p0p1_count P0/P1 finding(s) still OPEN — run /dev-workflow:fix before G7 can PASS"
    fi
    grep -qE 'AC evidence|How verified' "$REVIEW" || maybe_fail G7 "06-review-qa missing AC evidence / How verified"
    empty_how="$(grep -E '\|[[:space:]]*(AC|NEG|PERM|EDGE)-[0-9]+[[:space:]]*\|[[:space:]]*\|' "$REVIEW" 2>/dev/null | wc -l | tr -d ' ' || true)"
    empty_how="${empty_how:-0}"
    if [[ "${empty_how}" -gt 0 ]]; then
      maybe_fail G7 "$empty_how AC evidence row(s) missing How verified"
    fi
    if ui_ticket; then
      grep -qE 'UI checklist|Happy' "$REVIEW" || maybe_fail G7 "UI ticket but UI checklist section missing"
    fi
    # The defect-class sweep (500/missing/injection/case/other) is the most
    # differentiated part of code-review.md — the taxonomy that actually
    # catches the silent-bug classes (case/locale bugs in particular). A
    # reviewer can currently pass G7 with just the AC evidence table filled
    # and the sweep table deleted entirely, which throws away exactly the
    # part of the review most likely to find a real defect. Only enforce
    # when the file declares the sweep table at all (older/minimal review
    # logs without it are warned, not hard-failed, to avoid breaking a
    # different documented schema) — but once declared, every one of the 5
    # classes must be marked hit/none, not left blank.
    if grep -qiE 'Defect class sweep' "$REVIEW"; then
      sweep_gaps="$(awk -F'|' '
        /^##.*Defect class sweep/ { in_sweep = 1; next }
        /^##[[:space:]]/ && !/Defect class sweep/ { in_sweep = 0 }
        in_sweep && $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*-+[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*[Cc]lass[[:space:]]*\|/ {
          verdict = $3
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", verdict)
          checked = (verdict ~ /☑[[:space:]]*(none|hit)/ || verdict ~ /\[x\][[:space:]]*(none|hit)/ || verdict ~ /\[X\][[:space:]]*(none|hit)/)
          if (!checked) print $0
        }
      ' "$REVIEW" 2>/dev/null || true)"
      sweep_gap_count="$(printf '%s\n' "$sweep_gaps" | grep -cE '.' || true)"
      sweep_gap_count="${sweep_gap_count:-0}"
      if [[ -n "$sweep_gaps" && "$sweep_gap_count" -gt 0 ]]; then
        maybe_fail G7 "$sweep_gap_count defect-class row(s) not marked none/hit"
      fi
    else
      warn "G7: 06-review-qa has no Defect class sweep table (500/missing/injection/case/other) — using older/minimal review schema"
    fi
    # A finding whose Status was moved off OPEN (to FIXED/SKIPPED/DEFERRED)
    # is a claim that triage happened — :fix's own SKILL.md requires
    # 06c-fix-log.md to record the FIX/SKIP/DEFER decision and reasoning for
    # every former-OPEN finding. Nothing previously checked that file exists
    # at all: a P0 finding could be hand-edited straight from OPEN to FIXED
    # in this table with zero triage evidence anywhere, and G7 would still
    # pass — the exact "AI self-declares PASS with no evidence" failure
    # mode this whole gate system exists to catch, reachable at the one
    # stage (fix) most likely to be rushed under review-cycle pressure.
    triaged_ids="$(awk -F'|' '
      /^##.*Code review findings/ { in_findings = 1; next }
      /^##[[:space:]]/ && !/Code review findings/ { in_findings = 0 }
      in_findings && $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*-+[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*ID[[:space:]]*\|/ {
        id = $2; status = $(NF-1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
        if (tolower(status) ~ /fixed|skipped|deferred/) print id
      }
    ' "$REVIEW" 2>/dev/null || true)"
    triaged_count="$(printf '%s\n' "$triaged_ids" | grep -cE '.' || true)"
    triaged_count="${triaged_count:-0}"
    if [[ "$triaged_count" -gt 0 ]]; then
      if ! file_ok "$FIXLOG"; then
        maybe_fail G7 "$triaged_count finding(s) marked FIXED/SKIPPED/DEFERRED but 06c-fix-log.md missing — run /dev-workflow:fix"
      else
        missing_in_fixlog=0
        while IFS= read -r fid; do
          [[ -z "$fid" ]] && continue
          grep -qE "\|[[:space:]]*${fid}[[:space:]]*\|" "$FIXLOG" 2>/dev/null || missing_in_fixlog=$((missing_in_fixlog + 1))
        done <<< "$triaged_ids"
        if [[ "$missing_in_fixlog" -gt 0 ]]; then
          maybe_fail G7 "$missing_in_fixlog triaged finding(s) have no matching row in 06c-fix-log.md"
        fi
      fi
    fi
  fi
fi

# --- G8 ---
if need_gate G8; then
  file_ok "$TESTEV" || maybe_fail G8 "missing 06b-test-evidence.md"
  if file_ok "$TESTEV"; then
    if grep -qE 'paste test runner output here|# paste test runner output' "$TESTEV"; then
      maybe_fail G8 "test run output still placeholder"
    fi
    if ! grep -qE '```' "$TESTEV"; then
      maybe_fail G8 "test run output missing code fence"
    fi
    if grep -qiE 'Overall:.*☑ FAIL|Overall:.*\[x\] FAIL' "$TESTEV"; then
      maybe_fail G8 "Overall marked FAIL in 06b-test-evidence"
    fi
    if ! grep -qiE 'Overall:.*☑ PASS|Overall:.*\[x\] PASS|G8 verdict:.*☑ PASS|G8 verdict:.*\[x\] PASS' "$TESTEV"; then
      maybe_fail G8 "Overall/G8 PASS not checked"
    fi
    if ! grep -qiE '\*\*Dev:\*\*[[:space:]]*[A-Za-z0-9]|Dev:[[:space:]]*[A-Za-z0-9]' "$TESTEV"; then
      maybe_fail G8 "sign-off Dev name missing"
    fi

    sha="$(table_val "$TESTEV" "Commit SHA")"
    ci="$(table_val "$TESTEV" "CI run URL")"
    junit="$(table_val "$TESTEV" "JUnit")"
    if [[ -z "$junit" ]]; then junit="$(table_val "$TESTEV" "log path")"; fi

    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      if placeholderish "$sha" || [[ ! "$sha" =~ [0-9a-fA-F]{7,} ]]; then
        maybe_fail G8 "machine evidence: Commit SHA missing/invalid"
      fi
      if placeholderish "$ci" && placeholderish "$junit"; then
        maybe_fail G8 "machine evidence: need CI run URL or junit/xml/log path"
      fi
      if ! placeholderish "$ci" && [[ ! "$ci" =~ [Hh]ttps?:// ]] && [[ "$ci" != "N/A-local" ]]; then
        if placeholderish "$junit"; then
          maybe_fail G8 "machine evidence: CI URL must be http(s) or N/A-local with junit path"
        fi
      fi
      grep -qiE '^##[[:space:]]+Executed-command ledger' "$TESTEV" || \
        maybe_fail G8 "06b-test-evidence missing executed-command ledger"
      grep -qE '^\|[^|]+\|[^|]+\|[^|]+\|[[:space:]]*0[[:space:]]*\|[^|]+\|[^|]+\|' "$TESTEV" || \
        maybe_fail G8 "executed-command ledger has no successful concrete command row"
      grep -qiE '^##[[:space:]]+Assertion evidence' "$TESTEV" || \
        maybe_fail G8 "06b-test-evidence missing assertion evidence"
      grep -qE '^\|[[:space:]]*(AC|NEG|PERM|EDGE)-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$TESTEV" || \
        maybe_fail G8 "assertion evidence has no concrete requirement mapping"
    fi

    # CI-native verification
    if [[ "$VERIFY_NATIVE" -eq 1 ]]; then
      if ! placeholderish "$sha" && [[ "$sha" =~ [0-9a-fA-F]{7,} ]]; then
        verify_sha_git "$sha"
      fi
      if ! placeholderish "$junit"; then
        verify_junit_file "$junit"
      elif [[ "$ci" == "N/A-local" ]]; then
        maybe_fail G8 "CI-native: N/A-local requires existing junit/log path"
      fi
      if ! placeholderish "$ci" && [[ "$ci" =~ ^https?:// ]]; then
        verify_ci_url "$ci"
      fi
    fi

    if ui_ticket || grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes' "$TESTEV"; then
      if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$TESTEV"; then
        if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
          maybe_fail G8 "UI ticket requires screenshot/recording path"
        else
          warn "G8: UI ticket but screenshot paths look empty"
        fi
      fi
    fi
    if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
      out_lines="$(awk '/## Test run output/,/## Screenshots/{if($0 ~ /```/){c++} else if(c==1 && NF) print}' "$TESTEV" 2>/dev/null | wc -l | tr -d ' ' || true)"
      out_lines="${out_lines:-0}"
      if [[ "${out_lines}" -lt 2 ]]; then
        maybe_fail G8 "strict/P0: test output too thin"
      fi
    fi
  fi
fi

# --- G9 ---
if need_gate G9; then
  file_ok "$SHIP" || maybe_fail G9 "missing 07-ship.md"
  if file_ok "$SHIP"; then
    grep -qiE '## Ship safety|### Migration|### Feature flag|### Rollback' "$SHIP" \
      || maybe_fail G9 "07-ship missing Ship safety sections"
    rollback_line="$(grep -i 'Rollback steps' "$SHIP" | head -1 || true)"
    rollback_val="$(echo "$rollback_line" | sed -E 's/.*:[[:space:]]*//;s/\*//g;s/^[[:space:]]+//;s/[[:space:]]+$//')"
    if ! field_nonempty "$SHIP" "Rollback steps" || low_signal_text "$rollback_val"; then
      if [[ "$RISK" != "P2" ]]; then
        maybe_fail G9 "Rollback steps empty/placeholder/low-signal"
      else
        warn "G9: P2 rollback looks empty — confirm N/A"
      fi
    fi
    if [[ "$RISK" == "P0" || "$RISK" == "P1" ]]; then
      grep -qiE 'Has migration|Backward compatible|Migration' "$SHIP" || maybe_fail G9 "Migration section incomplete"
      grep -qiE 'Flag name|Feature flag|dark launch|N/A' "$SHIP" || maybe_fail G9 "Feature flag section incomplete"
      grep -qiE '### Canary|Canary %' "$SHIP" || maybe_fail G9 "Canary/soak section missing"
      canary_line="$(grep -i 'Canary %' "$SHIP" | head -1 || true)"
      if [[ -z "$canary_line" ]] || [[ "$canary_line" =~ \.\.\.|… ]]; then
        maybe_fail G9 "Canary % empty/placeholder"
      elif echo "$canary_line" | grep -qiE 'N/?A'; then
        reason="$(python3 -c "
import re,sys
s=sys.argv[1]
m=re.search(r'\bN/?A\b\s*[\(\[—:\-]*\s*(.*)', s, re.I)
print((m.group(1) if m else '').strip(' )]*'))
" "$canary_line" 2>/dev/null || true)"
        if [[ ${#reason} -lt 10 ]]; then
          maybe_fail G9 "Canary N/A needs reason ≥10 chars (e.g. N/A (internal tool only))"
        elif low_signal_text "$reason"; then
          maybe_fail G9 "Canary N/A reason looks like a placeholder, not a real reason"
        fi
      fi
      soak_line="$(grep -i 'Soak time' "$SHIP" | head -1 || true)"
      soak_val="$(echo "$soak_line" | sed -E 's/.*:[[:space:]]*//;s/\*//g;s/^[[:space:]]+//;s/[[:space:]]+$//')"
      if ! field_nonempty "$SHIP" "Soak time" || low_signal_text "$soak_val"; then
        maybe_fail G9 "Soak time empty/placeholder/low-signal"
      fi
      oncall_line="$(grep -i 'on-call' "$SHIP" | head -1 || true)"
      oncall_val="$(echo "$oncall_line" | sed -E 's/.*:[[:space:]]*//;s/\*//g;s/^[[:space:]]+//;s/[[:space:]]+$//')"
      if ! field_nonempty "$SHIP" "on-call" || low_signal_text "$oncall_val"; then
        maybe_fail G9 "Alert/owner on-call empty/placeholder/low-signal"
      fi
      grep -qiE 'SLO|error-budget|error budget' "$SHIP" || maybe_fail G9 "SLO/error-budget note missing"
      # dashboard / log query must be URL or long concrete query
      dash="$(grep -iE 'Dashboard or log query' "$SHIP" | head -1 || true)"
      dash_val="$(echo "$dash" | sed -E 's/.*:[[:space:]]*//;s/\*//g;s/^[[:space:]]+//;s/[[:space:]]+$//')"
      if placeholderish "$dash_val" || [[ "$dash_val" =~ ^\.\.\.|… ]]; then
        maybe_fail G9 "Dashboard/log query empty"
      elif [[ ! "$dash_val" =~ ^https?:// ]] && [[ ${#dash_val} -lt 15 ]]; then
        maybe_fail G9 "Dashboard/log query must be http(s) URL or concrete query ≥15 chars"
      elif [[ ! "$dash_val" =~ ^https?:// ]] && low_signal_text "$dash_val"; then
        maybe_fail G9 "Dashboard/log query looks like a placeholder, not a concrete query"
      fi
    fi
  fi

  # Pilot mode: INDEX Pilot: ☑ yes → require ticket mentioned in pilot log
  if file_ok "$INDEX" && grep -qE 'Pilot:.*☑ yes|Pilot:.*\[x\] yes|Pilot:.*\[X\] yes' "$INDEX" 2>/dev/null; then
    pilot_hit=0
    if [[ -d "$PILOT_DIR" ]]; then
      if grep -R -l --include='PILOT*.md' -E "$TICKET" "$PILOT_DIR" >/dev/null 2>&1; then
        pilot_hit=1
      fi
    fi
    if [[ "$pilot_hit" -ne 1 ]]; then
      maybe_fail G9 "Pilot:yes but ticket $TICKET not found in $PILOT_DIR/PILOT*.md"
    fi
  fi
fi

# --- AUDIT (semantic, opt-in via --min AUDIT) ---
# check-gates.sh verifies structure (files present, fields non-placeholder,
# SHA matches HEAD). It cannot verify meaning — whether a Rollback plan
# actually undoes the Migration described above it, whether a Decision
# actually answers its Proposal. That needs a reader (references/audit.md),
# not a regex. What this block *can* verify structurally is the same
# anti-forge shape G3 uses: a real 08-semantic-audit.md exists, every
# coherence pair has a verdict (not left as the template's blank checkbox
# row), no pair is left INCOHERENT unrouted, and — critically — the human
# sign-off phrase is present and not an AI/tool name. It cannot verify the
# verdicts themselves are honest; that trust boundary is inherent to any
# semantic check and is why the human sign-off step exists at all.
if need_gate AUDIT; then
  file_ok "$AUDIT" || maybe_fail AUDIT "missing 08-semantic-audit.md — run /dev-workflow:audit"
  if file_ok "$AUDIT"; then
    for pair in 1 2 3 4 5 6 7 8; do
      if ! grep -qE "^#{2,3}[[:space:]]+C${pair}([[:space:]]|[[:punct:]])" "$AUDIT"; then
        maybe_fail AUDIT "missing required coherence pair C$pair"
        continue
      fi
      pair_block="$(awk -v start="C$pair" -v next_pair="C$((pair + 1))" '
        $0 ~ ("^#{2,3}[[:space:]]+" start "([[:space:]]|[[:punct:]])") { in_pair=1 }
        $0 ~ ("^#{2,3}[[:space:]]+" next_pair "([[:space:]]|[[:punct:]])") { in_pair=0 }
        in_pair { print }
      ' "$AUDIT")"
      if ! printf '%s\n' "$pair_block" | grep -qE '☑ COHERENT|\[x\] COHERENT|\[X\] COHERENT|☑ N/A|\[x\] N/A|\[X\] N/A'; then
        maybe_fail AUDIT "C$pair has no resolved COHERENT/N/A verdict"
      fi
      quote_count="$(printf '%s\n' "$pair_block" | grep -oE '"[^"]{3,}"' | wc -l | tr -d ' ' || true)"
      if [[ "${quote_count:-0}" -lt 2 ]]; then
        maybe_fail AUDIT "C$pair requires two verbatim quoted evidence strings"
      fi
      if ! printf '%s\n' "$pair_block" | grep -qiE 'REASON:\*{0,2}[[:space:]]*.{8,}'; then
        maybe_fail AUDIT "C$pair requires a non-placeholder REASON"
      fi
    done
    unverdicted="$(grep -cE '☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A|☐ COHERENT ☐ INCOHERENT ☐ N/A' "$AUDIT" 2>/dev/null || true)"
    unverdicted="${unverdicted:-0}"
    if [[ "$unverdicted" -gt 0 ]]; then
      maybe_fail AUDIT "$unverdicted coherence pair(s) left with no verdict ticked"
    fi
    grep -qE '☑ INCOHERENT|\[[xX]\] INCOHERENT' "$AUDIT" 2>/dev/null && \
      maybe_fail AUDIT "INCOHERENT pair(s) remain; routing does not permit PASS"
    grep -qE '☑ UNCLEAR|\[[xX]\] UNCLEAR' "$AUDIT" 2>/dev/null && \
      maybe_fail AUDIT "UNCLEAR pair(s) remain; human decision must resolve them before PASS"
    audit_confirm_ok() {
      grep -qE "AUDIT CONFIRM:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$AUDIT"
    }
    audit_banned_name() {
      grep -qiE "AUDIT CONFIRM:[[:space:]]*$TICKET[[:space:]]+(AI|ChatGPT|Claude|Copilot|Cursor|Assistant|Bot)\\b" "$AUDIT"
    }
    audit_confirm_ok || maybe_fail AUDIT "missing human AUDIT CONFIRM: $TICKET <name> <YYYY-MM-DD> in 08-semantic-audit.md"
    audit_banned_name && maybe_fail AUDIT "AUDIT CONFIRM uses forbidden AI/tool name"
    if ! grep -qE '☑ PASS|\[x\] PASS' "$AUDIT" 2>/dev/null; then
      maybe_fail AUDIT "Result not marked PASS in 08-semantic-audit.md"
    fi
  fi
fi

file_ok "$INDEX" || warn "missing worklog INDEX.md"
echo "risk=$RISK machine_required=$REQUIRE_MACHINE verify_native=$VERIFY_NATIVE verify_net=$VERIFY_NET" >&2

if [[ "$JSON" -eq 1 ]]; then
  python3 - <<PY
import json
print(json.dumps({
  "ticket": "$TICKET",
  "project": "$PROJECT_SLUG",
  "worklog": "$WORKLOG",
  "min_gate": "$MIN_GATE",
  "risk": "$RISK",
  "strict": bool($STRICT),
  "verify_native": bool($VERIFY_NATIVE),
  "verify_net": bool($VERIFY_NET),
  "machine_required": bool($REQUIRE_MACHINE),
  "fails": $(printf '%s\n' "${FAILS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "warns": $(printf '%s\n' "${WARNS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "ok": $([[ ${#FAILS[@]} -eq 0 ]] && echo True || echo False),
}, indent=2))
PY
else
  echo "check-gates: ticket=$TICKET project=$PROJECT_SLUG min=$MIN_GATE risk=$RISK strict=$STRICT"
  echo "worklog: $WORKLOG"
  if [[ ${#WARNS[@]} -gt 0 ]]; then
    echo "WARNINGS:"
    printf '  - %s\n' "${WARNS[@]}"
  fi
  if [[ ${#FAILS[@]} -gt 0 ]]; then
    echo "FAILURES:"
    printf '  - %s\n' "${FAILS[@]}"
    echo "RESULT: FAIL (${#FAILS[@]} issue(s))"
    exit 1
  fi
  echo "RESULT: PASS"
fi

if [[ ${#FAILS[@]} -gt 0 ]]; then
  exit 1
fi
exit 0
