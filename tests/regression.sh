#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK="$ROOT/bin/check-gates.sh"
FIXTURES="$ROOT/fixtures"
PASS=0
FAIL=0

ok() { printf 'PASS: %s\n' "$1"; PASS=$((PASS + 1)); }
bad() { printf 'FAIL: %s\n' "$1"; FAIL=$((FAIL + 1)); }

assert_success() {
  local name="$1"; shift
  if "$@" >/tmp/dev-workflow-test.out 2>/tmp/dev-workflow-test.err; then ok "$name"; else bad "$name"; fi
}

assert_failure() {
  local name="$1"; shift
  if "$@" >/tmp/dev-workflow-test.out 2>/tmp/dev-workflow-test.err; then bad "$name"; else ok "$name"; fi
}

assert_failure_output() {
  local name="$1" pattern="$2"; shift 2
  if "$@" >/tmp/dev-workflow-test.out 2>/tmp/dev-workflow-test.err; then
    bad "$name"
  elif grep -qE "$pattern" /tmp/dev-workflow-test.out /tmp/dev-workflow-test.err; then
    ok "$name"
  else
    bad "$name"
  fi
}

assert_output() {
  local name="$1" pattern="$2"; shift 2
  if "$@" >/tmp/dev-workflow-test.out 2>/tmp/dev-workflow-test.err &&
     grep -qE "$pattern" /tmp/dev-workflow-test.out; then
    ok "$name"
  else
    bad "$name"
  fi
}

export DEV_WORKFLOW_WORKSPACES_ROOT="$FIXTURES"

assert_output "--json emits valid JSON on PASS" '"ok": true' \
  "$CHECK" PASS-G8 --project demo --min G8 --json

assert_failure "--json preserves nonzero exit on FAIL" \
  "$CHECK" FAIL-G8-failing --project demo --min G8 --json

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT
mkdir -p "$tmp_root/workspaces/demo/worklogs"
cp -R "$FIXTURES/workspaces/demo/PROJECT.md" "$tmp_root/workspaces/demo/"
cp -R "$FIXTURES/workspaces/demo/domain-knowledge" "$tmp_root/workspaces/demo/"
cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/TYPE-MISSING"
sed -i.bak '/Type:/d' "$tmp_root/workspaces/demo/worklogs/TYPE-MISSING/INDEX.md"
rm -f "$tmp_root/workspaces/demo/worklogs/TYPE-MISSING/INDEX.md.bak"
export DEV_WORKFLOW_WORKSPACES_ROOT="$tmp_root/workspaces"

assert_failure "G1 rejects a worklog with no ticket Type" \
  "$CHECK" TYPE-MISSING --project demo --min G1

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/PROVENANCE-MISSING"
find "$tmp_root/workspaces/demo/worklogs/PROVENANCE-MISSING" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/PROVENANCE-MISSING/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/PROVENANCE-MISSING" -name '*.bak' -delete
sed -i.bak '/^## Requirement provenance$/d' \
  "$tmp_root/workspaces/demo/worklogs/PROVENANCE-MISSING/02-spec.md"
rm -f "$tmp_root/workspaces/demo/worklogs/PROVENANCE-MISSING/02-spec.md.bak"

assert_failure_output "G1 rejects requirements without a provenance section" \
  'G1 FAIL:.*Requirement provenance' \
  "$CHECK" PROVENANCE-MISSING --project demo --min G1

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/DISCOVERY-MISSING"
find "$tmp_root/workspaces/demo/worklogs/DISCOVERY-MISSING" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/DISCOVERY-MISSING/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/DISCOVERY-MISSING" -name '*.bak' -delete
sed -i.bak 's/Command discovery proof/Unverified note/' \
  "$tmp_root/workspaces/demo/worklogs/DISCOVERY-MISSING/04-plan.md"
rm -f "$tmp_root/workspaces/demo/worklogs/DISCOVERY-MISSING/04-plan.md.bak"

assert_failure_output "G4 rejects a plan without command discovery proof" \
  'G4 FAIL:.*Command discovery' \
  "$CHECK" DISCOVERY-MISSING --project demo --min G4

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/LEDGER-MISSING"
find "$tmp_root/workspaces/demo/worklogs/LEDGER-MISSING" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/LEDGER-MISSING/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/LEDGER-MISSING" -name '*.bak' -delete
sed -i.bak 's/^## Executed-command ledger$/## Commands omitted/' \
  "$tmp_root/workspaces/demo/worklogs/LEDGER-MISSING/06b-test-evidence.md"
rm -f "$tmp_root/workspaces/demo/worklogs/LEDGER-MISSING/06b-test-evidence.md.bak"

assert_failure_output "G8 rejects test evidence without an executed-command ledger" \
  'G8 FAIL:.*executed-command ledger' \
  "$CHECK" LEDGER-MISSING --project demo --min G8

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/AUDIT-BYPASS"
find "$tmp_root/workspaces/demo/worklogs/AUDIT-BYPASS" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/AUDIT-BYPASS/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/AUDIT-BYPASS" -name '*.bak' -delete
cat >"$tmp_root/workspaces/demo/worklogs/AUDIT-BYPASS/08-semantic-audit.md" <<'EOF'
# 08 Semantic audit
### C1 — Conflict claim Proposal ↔ Decision
☑ INCOHERENT
## Routing
| C1 | :clarify | decision does not answer proposal |
AUDIT CONFIRM: AUDIT-BYPASS Human 2026-08-14
☑ PASS
EOF

assert_failure_output "AUDIT rejects INCOHERENT even when routing and PASS are present" \
  'AUDIT FAIL:.*INCOHERENT' \
  "$CHECK" AUDIT-BYPASS --project demo --min AUDIT

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/AUDIT-NO-EVIDENCE"
find "$tmp_root/workspaces/demo/worklogs/AUDIT-NO-EVIDENCE" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/AUDIT-NO-EVIDENCE/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/AUDIT-NO-EVIDENCE" -name '*.bak' -delete
{
  echo '# 08 Semantic audit'
  for pair in 1 2 3 4 5 6 7 8; do
    echo "### C$pair — pair"
    echo '☑ COHERENT'
    echo '**REASON:** superficially filled reason'
  done
  echo 'AUDIT CONFIRM: AUDIT-NO-EVIDENCE Human 2026-08-14'
  echo '☑ PASS'
} >"$tmp_root/workspaces/demo/worklogs/AUDIT-NO-EVIDENCE/08-semantic-audit.md"

assert_failure_output "AUDIT rejects verdicts without two quoted evidence strings" \
  'AUDIT FAIL:.*quoted evidence' \
  "$CHECK" AUDIT-NO-EVIDENCE --project demo --min AUDIT

cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/AUDIT-PASS"
find "$tmp_root/workspaces/demo/worklogs/AUDIT-PASS" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/AUDIT-PASS/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/AUDIT-PASS" -name '*.bak' -delete
{
  echo '# 08 Semantic audit'
  for pair in 1 2 3 4 5 6 7 8; do
    echo "### C$pair — pair"
    echo 'SIDE A: "specific source evidence A"'
    echo 'SIDE B: "specific source evidence B"'
    echo '☑ COHERENT'
    echo '**REASON:** both quoted sides agree on the stated behavior'
  done
  echo 'AUDIT CONFIRM: AUDIT-PASS Human 2026-08-14'
  echo '☑ PASS'
} >"$tmp_root/workspaces/demo/worklogs/AUDIT-PASS/08-semantic-audit.md"

assert_success "AUDIT accepts eight resolved evidence-backed pairs with human sign-off" \
  "$CHECK" AUDIT-PASS --project demo --min AUDIT

# Template-conformance check: an author who fills templates/06b-test-evidence.md's OWN shape
# exactly (not a fixture, not a previously-working example) must reach G8 PASS. This guards
# against template/checker drift that a fixture-only suite can't see — a fixture keeps working
# forever even if the shipped template stops matching what the checker requires (this exact class
# of bug shipped once: templates/06b-test-evidence.md's `**Dev:**` sign-off line was accidentally
# dropped in an editing pass and no fixture caught it, because fixtures don't derive from the
# template file).
cp -R "$FIXTURES/workspaces/demo/worklogs/PASS-G9" "$tmp_root/workspaces/demo/worklogs/TEMPLATE-CONFORMANCE"
find "$tmp_root/workspaces/demo/worklogs/TEMPLATE-CONFORMANCE" -type f -name '*.md' -exec \
  sed -i.bak 's/PASS-G9/TEMPLATE-CONFORMANCE/g' {} \;
find "$tmp_root/workspaces/demo/worklogs/TEMPLATE-CONFORMANCE" -name '*.bak' -delete
printf '<testsuite tests="3" failures="0"></testsuite>\n' \
  >"$tmp_root/workspaces/demo/worklogs/TEMPLATE-CONFORMANCE/junit.xml"
python3 - "$ROOT/templates/06b-test-evidence.md" \
  "$tmp_root/workspaces/demo/worklogs/TEMPLATE-CONFORMANCE/06b-test-evidence.md" <<'PY'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src).read()
fills = {
  r'\[Feature_Name\]': 'TEMPLATE-CONFORMANCE',
  r'\[ID\]': 'TEMPLATE-CONFORMANCE',
  r'☐ Yes ☐ No \(copy from `02-spec`\)': '☑ No',
  r'☐ P0 ☐ P1 ☐ P2': '☑ P1',
  r'\[40-char or short SHA\]': 'abcdef1234567890',
  r'\[https://… or N/A-local\]': 'N/A-local',
  r'\[path or URL\]': 'junit.xml',
  r'\[name\]': 'fixture',
  r'# paste test runner output here': 'rspec\nFinished in 0.12 seconds\n3 examples, 0 failures',
  r'\| \| \| \| \| \| \| N/A \|': '| `rspec` | api | 2026-08-11T10:00Z / 2026-08-11T10:01Z | 0 | raw output above | AC-01 | N/A |',
  r'\| AC-01 \| \| \| \|': '| AC-01 | test_ac01:1 `expect(success)` | missing success result | assertion passed |',
  r'\| AC-01 \| \| \|': '| AC-01 | N/A | no UI |',
  r'\| Unit \| \| \| \| \| ☐ PASS ☐ FAIL \|': '| Unit | 3 | 3 | 0 | 0 | ☑ PASS |',
  r'\*\*Overall:\*\* ☐ PASS \(zero failures\) ☐ FAIL': '**Overall:** ☑ PASS (zero failures) ☐ FAIL',
  r'\*\*G8 verdict:\*\* ☐ PASS ☐ FAIL': '**G8 verdict:** ☑ PASS ☐ FAIL',
}
for pattern, repl in fills.items():
    text = re.sub(pattern, repl, text)
open(dst, 'w').write(text)
PY

assert_success "template-conformance: 06b-test-evidence.md's own shape reaches G8 PASS" \
  "$CHECK" TEMPLATE-CONFORMANCE --project demo --min G8 --strict

if grep -q 'case.*Bug\|Bug)' "$ROOT/references/clarify-check.md" &&
   grep -q 'New feature' "$ROOT/references/clarify-check.md" &&
   grep -q 'Spec change' "$ROOT/references/clarify-check.md" &&
   grep -q 'Requirement change' "$ROOT/references/clarify-check.md"; then
  ok "clarify-check dispatches all four ticket types"
else
  bad "clarify-check dispatches all four ticket types"
fi

printf 'RESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
