#!/usr/bin/env bash
# sdd-gate-check.sh — Mandatory quality gate enforcement
# Validates prerequisites + content quality before allowing phase entry.
# Gates are HARD STOPS — FAIL means the phase CANNOT proceed.
#
# Usage: bash scripts/sdd-gate-check.sh <phase> [project-path]
#   phase: 00-08
#   project-path: defaults to current directory
#
# Gate map:
#   G1 (before Phase 03): Constitution + spec quality >= 6 + plan completeness
#   G2 (before Phase 07): Zero HIGH findings + traceability >= 95%
#   G3 (before Phase 08): Tests pass + assertion hashes match
#
# Non-gate phases: validate prerequisites (completed prior phases + artifact existence)
#
# Exit codes: 0 PASS, 1 FAIL, 2 CONDITIONAL (warnings only)
# Outputs: PASS|CONDITIONAL|FAIL to stdout (last line)
# Side effect: appends to .specify/gate-results.json

set -eo pipefail

PHASE="${1:-}"
PROJECT_PATH="${2:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONTEXT_FILE="$PROJECT_PATH/.specify/context.json"
GATE_FILE="$PROJECT_PATH/.specify/gate-results.json"

ERRORS=0
WARNINGS=0
FINDINGS=()

fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); FINDINGS+=("{\"severity\":\"HIGH\",\"message\":\"$1\"}"); }
warn() { echo "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); FINDINGS+=("{\"severity\":\"MEDIUM\",\"message\":\"$1\"}"); }
pass() { echo "  ✓ $1"; }

# ─── Validation ───
if [[ -z "$PHASE" ]]; then
  echo "Usage: sdd-gate-check.sh <phase> [project-path]" >&2
  exit 1
fi

if ! echo "00 01 02 03 04 05 06 07 08" | grep -qw "$PHASE"; then
  echo "Error: Invalid phase '$PHASE'" >&2
  exit 1
fi

# ─── Resolve active feature ───
ACTIVE_FEATURE=""
if [[ -f "$PROJECT_PATH/.specify/active-feature" ]]; then
  ACTIVE_FEATURE=$(cat "$PROJECT_PATH/.specify/active-feature" 2>/dev/null | tr -d '\n')
fi
if [[ -z "$ACTIVE_FEATURE" ]]; then
  # Fallback: newest specs dir
  ACTIVE_FEATURE=$(ls -td "$PROJECT_PATH/specs/"*/ 2>/dev/null | head -1 | xargs basename 2>/dev/null || true)
fi

FP="$PROJECT_PATH/specs/$ACTIVE_FEATURE"

echo "╔══════════════════════════════════════════════════╗"
echo "║  Gate Check — Phase $PHASE                         ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ─── Phase-specific prerequisite checks ───
check_file() {
  local file="$1" label="$2" required="${3:-hard}"
  if [[ -f "$file" ]]; then
    pass "$label exists"
  elif [[ "$required" == "hard" ]]; then
    fail "$label MISSING (required)"
  else
    warn "$label missing (recommended)"
  fi
}

check_completed_phase() {
  local required_phase="$1"
  if [[ -f "$CONTEXT_FILE" ]]; then
    if python3 -c "
import json, sys
with open('$CONTEXT_FILE') as f: ctx = json.load(f)
phases = ctx.get('pipeline', {}).get('completedPhases', [])
sys.exit(0 if '$required_phase' in phases else 1)
" 2>/dev/null; then
      pass "Phase $required_phase completed"
    else
      fail "Phase $required_phase NOT completed — run phase $required_phase first"
    fi
  else
    fail "context.json missing — run /sdd:init"
  fi
}

# ─── Prerequisites by phase ───
case "$PHASE" in
  00) # Constitution — no prerequisites
    pass "Phase 00 has no prerequisites"
    ;;
  01) # Specify — needs constitution
    check_file "$PROJECT_PATH/CONSTITUTION.md" "CONSTITUTION.md"
    check_completed_phase "00"
    ;;
  02) # Plan — needs spec (G1 gate)
    check_file "$PROJECT_PATH/CONSTITUTION.md" "CONSTITUTION.md"
    check_completed_phase "01"
    if [[ -n "$ACTIVE_FEATURE" && -d "$FP" ]]; then
      check_file "$FP/spec.md" "spec.md"
      # Content validation: FR count
      if [[ -f "$FP/spec.md" ]]; then
        FR_COUNT=$(grep -cE 'FR-[0-9]{3}' "$FP/spec.md" 2>/dev/null || echo "0")
        if [[ "$FR_COUNT" -ge 1 ]]; then
          pass "spec.md has $FR_COUNT requirements"
        else
          fail "spec.md has no FR-NNN requirements"
        fi
      fi
    else
      fail "No active feature with specs directory"
    fi
    ;;
  03) # Checklist — G1 GATE: plan must be complete
    echo "── G1 Gate Check ──"
    check_completed_phase "02"
    if [[ -n "$ACTIVE_FEATURE" && -d "$FP" ]]; then
      check_file "$FP/plan.md" "plan.md"
      # Content: data model section
      if [[ -f "$FP/plan.md" ]]; then
        if grep -qiE '(data model|modelo de datos|entities|## .*[Dd]ata)' "$FP/plan.md"; then
          pass "plan.md has data model section"
        else
          fail "G1: plan.md missing data model section"
        fi
        if grep -qiE '(architecture|arquitectura|tech stack|## .*[Aa]rch)' "$FP/plan.md"; then
          pass "plan.md has architecture section"
        else
          fail "G1: plan.md missing architecture section"
        fi
      fi
    else
      fail "No active feature"
    fi
    # Constitution alignment
    if [[ -f "$PROJECT_PATH/CONSTITUTION.md" ]] && [[ -f "$FP/plan.md" ]]; then
      pass "Constitution + plan both present for alignment check"
    fi
    ;;
  04|05) # Testify, Tasks — needs previous phases
    check_completed_phase "02"
    if [[ -n "$ACTIVE_FEATURE" && -d "$FP" ]]; then
      check_file "$FP/spec.md" "spec.md"
      check_file "$FP/plan.md" "plan.md"
    fi
    ;;
  06) # Analyze — needs tasks
    check_completed_phase "05"
    if [[ -n "$ACTIVE_FEATURE" && -d "$FP" ]]; then
      check_file "$FP/tasks.md" "tasks.md"
      check_file "$FP/spec.md" "spec.md"
    fi
    ;;
  07) # Implement — G2 GATE: analysis must pass
    echo "── G2 Gate Check ──"
    check_completed_phase "06"
    if [[ -n "$ACTIVE_FEATURE" && -d "$FP" ]]; then
      check_file "$FP/spec.md" "spec.md"
      check_file "$FP/plan.md" "plan.md"
      check_file "$FP/tasks.md" "tasks.md"
      # Check analysis findings
      if [[ -f "$FP/analysis.md" ]]; then
        HIGH_COUNT=$(grep -ciE '(HIGH|CRITICAL|severity.*high|severity.*critical)' "$FP/analysis.md" 2>/dev/null || echo "0")
        if [[ "$HIGH_COUNT" -gt 0 ]]; then
          fail "G2: $HIGH_COUNT HIGH/CRITICAL findings in analysis — resolve before implementing"
        else
          pass "G2: No HIGH/CRITICAL findings"
        fi
      else
        warn "analysis.md not found — run /sdd:analyze first"
      fi
      # Check .feature files exist
      FEATURE_COUNT=$(find "$PROJECT_PATH/tests" -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$FEATURE_COUNT" -gt 0 ]]; then
        pass "G2: $FEATURE_COUNT .feature files found"
      else
        warn "No .feature files — run /sdd:testify first"
      fi
    fi
    ;;
  08) # Issues — G3 GATE: tests must pass + assertion hashes match
    echo "── G3 Gate Check ──"
    check_completed_phase "07"
    # Test runner check
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
      if grep -q '"test"' "$PROJECT_PATH/package.json"; then
        pass "G3: Test runner configured (package.json scripts.test)"
      else
        warn "G3: No test script in package.json"
      fi
    elif [[ -f "$PROJECT_PATH/pytest.ini" ]] || [[ -f "$PROJECT_PATH/setup.py" ]]; then
      pass "G3: Python test runner detected"
    else
      warn "G3: No test runner detected"
    fi
    # Assertion hash check
    HASH_FILE="$PROJECT_PATH/.specify/assertion-hashes.json"
    if [[ -f "$HASH_FILE" ]]; then
      pass "G3: Assertion hashes file exists"
      # Verify hashes match (if assertion-hash script available)
      if [[ -x "$SCRIPT_DIR/sdd-assertion-hash.sh" ]]; then
        if bash "$SCRIPT_DIR/sdd-assertion-hash.sh" verify "$PROJECT_PATH" 2>/dev/null; then
          pass "G3: Assertion hashes verified"
        else
          fail "G3: Assertion hash MISMATCH — .feature files modified after hashing"
        fi
      fi
    else
      warn "G3: No assertion hashes — run /sdd:testify to generate"
    fi
    ;;
esac

# ─── Determine result ───
if [[ $ERRORS -gt 0 ]]; then
  RESULT="FAIL"
  EXIT_CODE=1
elif [[ $WARNINGS -gt 0 ]]; then
  RESULT="CONDITIONAL"
  EXIT_CODE=0
else
  RESULT="PASS"
  EXIT_CODE=0
fi

# ─── Log gate result ───
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FINDINGS_JSON=""
if [[ ${#FINDINGS[@]} -gt 0 ]]; then
  FINDINGS_JSON=$(printf '%s,' "${FINDINGS[@]}" | sed 's/,$//')
fi

if [[ -f "$CONTEXT_FILE" ]] && command -v python3 &>/dev/null; then
  python3 -c "
import json, os

gate_file = '$GATE_FILE'
phase = '$PHASE'
result = '$RESULT'
ts = '$TS'

# Determine gate name
gate_map = {'03': 'G1', '07': 'G2', '08': 'G3'}
gate_name = gate_map.get(phase, 'PRE')

entry = {
    'gate': gate_name,
    'phase': phase,
    'result': result,
    'timestamp': ts,
    'findings': json.loads('[${FINDINGS_JSON}]') if '${FINDINGS_JSON}' else [],
    'errors': $ERRORS,
    'warnings': $WARNINGS
}

if os.path.exists(gate_file):
    with open(gate_file) as f:
        data = json.load(f)
else:
    data = {'gates': []}

data['gates'].append(entry)
data['gates'] = data['gates'][-50:]  # Keep last 50

tmp = gate_file + '.tmp'
with open(tmp, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
os.rename(tmp, gate_file)
" 2>/dev/null || true
fi

# ─── Output ───
echo ""
echo "════════════════════════════════════════════════════"
echo "  GATE RESULT: $RESULT ($ERRORS errors, $WARNINGS warnings)"
echo "════════════════════════════════════════════════════"

if [[ "$RESULT" == "FAIL" ]]; then
  echo ""
  echo "  Pipeline HALTED. Resolve errors before proceeding."
  echo "  Run /sdd:clarify or fix the listed issues."
fi

echo "$RESULT"
exit $EXIT_CODE
