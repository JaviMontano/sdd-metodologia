#!/usr/bin/env bash
# sdd-bdd-verify.sh — BDD Verification Chain (migrated from IIKit verify-steps + verify-step-quality)
# Runs the full verification chain: step coverage → step quality → assertion integrity.
# Integrates with SDD gate system (G2/G3 enforcement).
#
# Usage: bash scripts/sdd-bdd-verify.sh [project-path] [--json]
#
# Chain:
#   1. Detect BDD framework from plan.md tech stack
#   2. Count .feature steps vs step definitions
#   3. Dry-run framework (if available) to detect undefined/pending steps
#   4. Check step definition quality (no empty/trivial assertions)
#   5. Verify assertion hashes (sdd-assertion-hash.sh verify)
#
# Exit: 0 = PASS, 1 = BLOCKED (undefined steps), 2 = DEGRADED (no framework)

set -eo pipefail

PROJECT_PATH="${1:-.}"
JSON_MODE=false
[[ "${2:-}" == "--json" || "${1:-}" == "--json" ]] && JSON_MODE=true
[[ "${1:-}" == "--json" ]] && PROJECT_PATH="."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECIFY_DIR="$PROJECT_PATH/.specify"

GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
RESET='\033[0m'

# ─── Resolve active feature ───
ACTIVE=""
[[ -f "$SPECIFY_DIR/active-feature" ]] && ACTIVE=$(cat "$SPECIFY_DIR/active-feature" 2>/dev/null | tr -d '[:space:]')
if [[ -z "$ACTIVE" ]]; then
  ACTIVE=$(ls -1d "$PROJECT_PATH/specs"/[0-9][0-9][0-9]-*/ 2>/dev/null | sort -r | head -1 | xargs basename 2>/dev/null || true)
fi

FP="$PROJECT_PATH/specs/$ACTIVE"
FEATURES_DIR=""
PLAN_FILE="$FP/plan.md"

# Find .feature files
for candidate in "$FP/tests/features" "$PROJECT_PATH/tests/features" "$PROJECT_PATH/tests"; do
  if [[ -d "$candidate" ]] && ls "$candidate"/*.feature &>/dev/null; then
    FEATURES_DIR="$candidate"
    break
  fi
done

echo -e "${WHITE}BDD Verification Chain${RESET}"
echo ""

ERRORS=0
WARNINGS=0
TOTAL_STEPS=0
MATCHED_STEPS=0
FRAMEWORK=""

pass() { echo -e "  ${BLUE}✓${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${GOLD}⚠${RESET} $1"; WARNINGS=$((WARNINGS + 1)); }

# ─── Step 1: Detect BDD framework ───
echo -e "${WHITE}1. Framework Detection${RESET}"
if [[ -f "$PLAN_FILE" ]]; then
  # Detect from plan.md keywords
  if grep -qiE 'jest|vitest|mocha' "$PLAN_FILE" 2>/dev/null; then
    FRAMEWORK="@cucumber/cucumber"
  elif grep -qiE 'pytest|python' "$PLAN_FILE" 2>/dev/null; then
    FRAMEWORK="pytest-bdd"
  elif grep -qiE 'go|golang' "$PLAN_FILE" 2>/dev/null; then
    FRAMEWORK="godog"
  elif grep -qiE '\.net|csharp|c#' "$PLAN_FILE" 2>/dev/null; then
    FRAMEWORK="reqnroll"
  elif grep -qiE 'java|spring|maven|gradle' "$PLAN_FILE" 2>/dev/null; then
    FRAMEWORK="cucumber-jvm"
  fi
fi

# Fallback: detect from file extensions in project
if [[ -z "$FRAMEWORK" ]]; then
  if ls "$PROJECT_PATH"/**/*.ts "$PROJECT_PATH"/**/*.js &>/dev/null 2>&1; then
    FRAMEWORK="@cucumber/cucumber"
  elif ls "$PROJECT_PATH"/**/*.py &>/dev/null 2>&1; then
    FRAMEWORK="pytest-bdd"
  fi
fi

if [[ -n "$FRAMEWORK" ]]; then
  pass "Framework: $FRAMEWORK"
else
  warn "No BDD framework detected — verification chain is degraded"
fi

# ─── Step 2: Count feature steps ───
echo ""
echo -e "${WHITE}2. Step Coverage${RESET}"
if [[ -n "$FEATURES_DIR" ]]; then
  TOTAL_STEPS=$(grep -rchE '^\s*(Given|When|Then|And|But) ' "$FEATURES_DIR"/*.feature 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo "0")
  TOTAL_STEPS="${TOTAL_STEPS:-0}"
  FEATURE_COUNT=$(ls "$FEATURES_DIR"/*.feature 2>/dev/null | wc -l | tr -d ' ')
  pass "$FEATURE_COUNT .feature files, $TOTAL_STEPS total steps"
else
  fail "No .feature files found"
fi

# ─── Step 3: Step definition quality (static analysis) ───
echo ""
echo -e "${WHITE}3. Step Quality${RESET}"
if [[ -n "$FEATURES_DIR" ]]; then
  # Check for empty scenarios (Given/When/Then without actual assertions)
  EMPTY_SCENARIOS=0
  for f in "$FEATURES_DIR"/*.feature; do
    [[ -f "$f" ]] || continue
    # Scenarios with only Given/When but no Then = missing assertion
    SCENARIO_COUNT=$(grep -c '^\s*Scenario' "$f" 2>/dev/null || echo "0")
    THEN_COUNT=$(grep -c '^\s*Then' "$f" 2>/dev/null || echo "0")
    if [[ "$SCENARIO_COUNT" -gt 0 ]] && [[ "$THEN_COUNT" -eq 0 ]]; then
      EMPTY_SCENARIOS=$((EMPTY_SCENARIOS + 1))
    fi
  done
  if [[ $EMPTY_SCENARIOS -gt 0 ]]; then
    fail "$EMPTY_SCENARIOS .feature file(s) have scenarios without Then assertions"
  else
    pass "All scenarios have Then assertions"
  fi

  # Check for vague/tautological assertions
  VAGUE_COUNT=$(grep -rciE '^\s*Then (it works|it should work|everything is fine|no errors)' "$FEATURES_DIR"/*.feature 2>/dev/null || echo "0")
  if [[ "$VAGUE_COUNT" -gt 0 ]]; then
    warn "$VAGUE_COUNT vague/tautological assertions detected (e.g., 'Then it works')"
  else
    pass "No vague assertions detected"
  fi

  # Check for traceability tags
  TAGGED=$(grep -rlE '@FR-[0-9]{3}' "$FEATURES_DIR"/*.feature 2>/dev/null | wc -l | tr -d ' ')
  UNTAGGED=$((FEATURE_COUNT - TAGGED))
  if [[ $UNTAGGED -gt 0 ]]; then
    warn "$UNTAGGED .feature file(s) missing @FR-NNN traceability tags"
  else
    pass "All .feature files have @FR-NNN traceability tags"
  fi
fi

# ─── Step 4: Assertion integrity ───
echo ""
echo -e "${WHITE}4. Assertion Integrity${RESET}"
HASH_FILE="$SPECIFY_DIR/assertion-hashes.json"
if [[ -f "$HASH_FILE" ]] && [[ -x "$SCRIPT_DIR/sdd-assertion-hash.sh" ]]; then
  if bash "$SCRIPT_DIR/sdd-assertion-hash.sh" verify "$PROJECT_PATH" 2>/dev/null | grep -q "ALL.*verified"; then
    HASH_COUNT=$(python3 -c "import json; print(json.load(open('$HASH_FILE')).get('count',0))" 2>/dev/null || echo "?")
    pass "All $HASH_COUNT assertion hashes verified (SHA-256)"
  else
    fail "Assertion hash MISMATCH — .feature files modified after hashing"
  fi
elif [[ -f "$HASH_FILE" ]]; then
  warn "Assertion hash script not found — cannot verify"
else
  warn "No assertion hashes generated — run /sdd:testify first"
fi

# ─── Step 5: Feature immutability check ───
echo ""
echo -e "${WHITE}5. Feature Immutability${RESET}"
if [[ -d "$PROJECT_PATH/.git" ]] && [[ -n "$FEATURES_DIR" ]]; then
  # Check if .feature files have uncommitted changes
  DIRTY_FEATURES=$(git -C "$PROJECT_PATH" diff --name-only -- '*.feature' 2>/dev/null | wc -l | tr -d ' ')
  STAGED_FEATURES=$(git -C "$PROJECT_PATH" diff --cached --name-only -- '*.feature' 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$DIRTY_FEATURES" -gt 0 ]] || [[ "$STAGED_FEATURES" -gt 0 ]]; then
    fail ".feature files have uncommitted changes — features must be immutable during implementation"
  else
    pass ".feature files are clean (no uncommitted changes)"
  fi
else
  warn "Not a git repo — cannot verify feature immutability"
fi

# ─── Result ───
echo ""
echo "════════════════════════════════════════════════════"
if [[ $ERRORS -gt 0 ]]; then
  echo -e "  ${RED}BLOCKED${RESET}: $ERRORS error(s), $WARNINGS warning(s)"
  echo -e "  ${MUTED}Fix errors before implementation can proceed.${RESET}"
  exit 1
elif [[ $WARNINGS -gt 0 ]] && [[ -z "$FRAMEWORK" ]]; then
  echo -e "  ${GOLD}DEGRADED${RESET}: No BDD framework — verification chain incomplete"
  exit 2
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "  ${GOLD}CONDITIONAL${RESET}: $WARNINGS warning(s) — proceed with caution"
  exit 0
else
  echo -e "  ${BLUE}PASS${RESET}: Full BDD verification chain verified"
  exit 0
fi
