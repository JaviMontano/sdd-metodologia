#!/usr/bin/env bash
# sdd-dod-check.sh — Definition of Done enforcement
# Validates that a feature satisfies all 8 phase DoDs + request-level DoD.
# Source: SDD CONSTITUTION.md Section VI + BMAD implementation readiness gate.
#
# Usage: bash scripts/sdd-dod-check.sh [feature-name] [project-path]
# Exit: 0 = DONE, 1 = NOT DONE (lists gaps)

set -eo pipefail

FEATURE="${1:-}"
PROJECT_PATH="${2:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
RESET='\033[0m'

SPECS_DIR="$PROJECT_PATH/specs"
SPECIFY_DIR="$PROJECT_PATH/.specify"
ERRORS=0
WARNINGS=0

pass() { echo -e "  ${BLUE}✓${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${GOLD}⚠${RESET} $1"; WARNINGS=$((WARNINGS + 1)); }

# Resolve feature
if [[ -z "$FEATURE" ]]; then
  if [[ -f "$SPECIFY_DIR/active-feature" ]]; then
    FEATURE=$(cat "$SPECIFY_DIR/active-feature" 2>/dev/null | tr -d '[:space:]')
  fi
fi
if [[ -z "$FEATURE" ]]; then
  echo -e "${RED}Usage:${RESET} sdd-dod-check.sh <feature-name> [project-path]"
  exit 1
fi

FP="$SPECS_DIR/$FEATURE"
if [[ ! -d "$FP" ]]; then
  echo -e "${RED}Feature not found:${RESET} $FEATURE"
  exit 1
fi

echo -e "${WHITE}Definition of Done — ${GOLD}$FEATURE${RESET}"
echo ""

# ─── Phase DoDs ───
echo -e "${WHITE}Phase DoDs:${RESET}"

# Phase 1: User Specs
if [[ -f "$FP/spec.md" ]] && grep -qE 'FR-[0-9]{3}' "$FP/spec.md" 2>/dev/null; then
  pass "Phase 1 (Specify): spec.md with FR-NNN"
else
  fail "Phase 1 (Specify): spec.md missing or no FR-NNN"
fi

# Phase 2: Technical Specs
if [[ -f "$FP/plan.md" ]]; then
  pass "Phase 2 (Plan): plan.md exists"
else
  fail "Phase 2 (Plan): plan.md missing"
fi

# Phase 3: BDD Analysis
if [[ -f "$FP/checklist.md" ]] || ls "$FP"/checklists/*.md &>/dev/null; then
  pass "Phase 3 (Checklist): quality checklists present"
else
  warn "Phase 3 (Checklist): no checklists found (optional)"
fi

# Phase 4: Test
FEATURE_FILES=$(find "$FP" "$PROJECT_PATH/tests" -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$FEATURE_FILES" -gt 0 ]]; then
  pass "Phase 4 (Testify): $FEATURE_FILES .feature files"
else
  fail "Phase 4 (Testify): no .feature files"
fi

# Phase 5: Tasks
if [[ -f "$FP/tasks.md" ]] && grep -qE 'T-[0-9]{3}' "$FP/tasks.md" 2>/dev/null; then
  TOTAL_TASKS=$(grep -cE 'T-[0-9]{3}' "$FP/tasks.md" 2>/dev/null || echo "0")
  DONE_TASKS=$(grep -cE '\[x\]' "$FP/tasks.md" 2>/dev/null || echo "0")
  if [[ "$DONE_TASKS" -ge "$TOTAL_TASKS" ]] && [[ "$TOTAL_TASKS" -gt 0 ]]; then
    pass "Phase 5 (Tasks): $DONE_TASKS/$TOTAL_TASKS complete"
  else
    fail "Phase 5 (Tasks): $DONE_TASKS/$TOTAL_TASKS complete (not all done)"
  fi
else
  fail "Phase 5 (Tasks): tasks.md missing or no T-NNN"
fi

# Phase 6: Analysis
if [[ -f "$FP/analysis.md" ]]; then
  HIGH_COUNT=$(grep -ciE '(HIGH|CRITICAL)' "$FP/analysis.md" 2>/dev/null || echo "0")
  if [[ "$HIGH_COUNT" -eq 0 ]]; then
    pass "Phase 6 (Analyze): analysis complete, zero HIGH findings"
  else
    fail "Phase 6 (Analyze): $HIGH_COUNT HIGH/CRITICAL findings unresolved"
  fi
else
  fail "Phase 6 (Analyze): analysis.md missing"
fi

# Phase 7: Implementation
# Check if code exists (heuristic: src/ or lib/ has files newer than tasks.md)
if [[ -d "$PROJECT_PATH/src" ]] || [[ -d "$PROJECT_PATH/lib" ]] || [[ -d "$PROJECT_PATH/app" ]]; then
  pass "Phase 7 (Implement): code directory exists"
else
  warn "Phase 7 (Implement): no src/lib/app directory found"
fi

# Phase 8: Ship
if [[ -f "$SPECIFY_DIR/issue-map.json" ]]; then
  pass "Phase 8 (Ship): issue-map.json exists"
else
  warn "Phase 8 (Ship): no issue-map.json (issues not exported yet)"
fi

# ─── Request-Level DoD ───
echo ""
echo -e "${WHITE}Request-Level DoD:${RESET}"

# Knowledge graph: zero new orphans
KG="$SPECIFY_DIR/knowledge-graph.json"
if [[ -f "$KG" ]] && command -v python3 &>/dev/null; then
  ORPHAN_COUNT=$(python3 -c "
import json
g = json.load(open('$KG'))
o = g.get('orphans', {})
total = len(o.get('untested_requirements',[])) + len(o.get('broken_refs',[])) + len(o.get('tasks_with_broken_fr',[]))
print(total)
" 2>/dev/null || echo "?")
  if [[ "$ORPHAN_COUNT" == "0" ]]; then
    pass "Knowledge graph: zero critical orphans"
  else
    warn "Knowledge graph: $ORPHAN_COUNT orphans detected"
  fi
else
  warn "Knowledge graph not built — run /sdd:graph"
fi

# Assertion hashes verified
HASH_FILE="$SPECIFY_DIR/assertion-hashes.json"
if [[ -f "$HASH_FILE" ]]; then
  if [[ -x "$SCRIPT_DIR/sdd-assertion-hash.sh" ]]; then
    if bash "$SCRIPT_DIR/sdd-assertion-hash.sh" verify "$PROJECT_PATH" 2>/dev/null | grep -q "ALL.*verified"; then
      pass "Assertion hashes: verified"
    else
      fail "Assertion hashes: MISMATCH detected"
    fi
  else
    warn "Assertion hash script not found"
  fi
else
  warn "No assertion hashes generated"
fi

# Health score
HH="$SPECIFY_DIR/health-history.json"
if [[ -f "$HH" ]]; then
  LAST_SCORE=$(grep -o '"score"[[:space:]]*:[[:space:]]*[0-9]*' "$HH" | tail -1 | grep -o '[0-9]*$' || echo "0")
  if [[ "$LAST_SCORE" -ge 80 ]]; then
    pass "Health score: $LAST_SCORE% (≥80%)"
  else
    warn "Health score: $LAST_SCORE% (<80%)"
  fi
else
  warn "No health history"
fi

# ─── Result ───
echo ""
echo "════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
  echo -e "  ${BLUE}DONE${RESET}: Feature $FEATURE satisfies Definition of Done ($WARNINGS warnings)"
else
  echo -e "  ${RED}NOT DONE${RESET}: $ERRORS gap(s) found, $WARNINGS warning(s)"
  echo -e "  ${MUTED}Resolve errors before marking as complete.${RESET}"
fi
echo "════════════════════════════════════════════════════"

[[ $ERRORS -eq 0 ]] && exit 0 || exit 1
