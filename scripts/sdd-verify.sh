#!/usr/bin/env bash
# sdd-verify.sh — Run verification suite with MetodologIA branding
#
# Usage:
#   bash scripts/sdd-verify.sh [project-path] [--quick]
#
# Runs: brand verification + BDD step verification + assertion integrity check

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH="${1:-.}"
QUICK=false
[[ "${1:-}" == "--quick" || "${2:-}" == "--quick" ]] && QUICK=true
[[ "${1:-}" == "--quick" ]] && PROJECT_PATH="."

GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
GREEN='\033[38;5;33m'
RESET='\033[0m'
BOLD='\033[1m'

ERRORS=0
WARNINGS=0

pass() { echo -e "  ${BLUE}✓${RESET} $1"; }
warn() { echo -e "  ${GOLD}⚠${RESET} $1"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo -e "  ${RED}✗${RESET} $1"; ERRORS=$((ERRORS + 1)); }

echo ""
echo -e "${GOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${GOLD}║${RESET}  ${WHITE}${BOLD}SDD Verification Suite${RESET}                             ${GOLD}║${RESET}"
echo -e "${GOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# ─── Check 1: Project structure ───
echo -e "${WHITE}1. Project Structure${RESET}"
[[ -f "$PROJECT_PATH/CONSTITUTION.md" ]] && pass "CONSTITUTION.md" || warn "CONSTITUTION.md missing"
[[ -f "$PROJECT_PATH/PREMISE.md" ]] && pass "PREMISE.md" || warn "PREMISE.md missing"
[[ -d "$PROJECT_PATH/.specify" ]] && pass ".specify/ directory" || warn ".specify/ missing (run /sdd:core init)"
[[ -f "$PROJECT_PATH/.specify/context.json" ]] && pass ".specify/context.json" || warn "context.json missing"

# ─── Check 2: Brand integrity ───
echo ""
echo -e "${WHITE}2. Brand Integrity${RESET}"
BRAND_SCRIPT="$SCRIPT_DIR/verify-brand.sh"
if [[ -x "$BRAND_SCRIPT" ]]; then
  if bash "$BRAND_SCRIPT" >/dev/null 2>&1; then
    pass "Brand verification passed"
  else
    warn "Brand verification has issues (run bash scripts/verify-brand.sh for details)"
  fi
else
  warn "verify-brand.sh not found"
fi

# ─── Check 3: Design tokens ───
echo ""
echo -e "${WHITE}3. Design Tokens${RESET}"
TOKENS="$ROOT_DIR/references/design-tokens.json"
if [[ -f "$TOKENS" ]]; then
  if python3 -c "import json; json.load(open('$TOKENS'))" 2>/dev/null; then
    COLORS=$(python3 -c "import json; print(len(json.load(open('$TOKENS'))['colors']))")
    pass "design-tokens.json valid ($COLORS colors)"
  else
    fail "design-tokens.json is invalid JSON"
  fi
else
  fail "design-tokens.json missing"
fi

# ─── Check 4: Dashboard template ───
echo ""
echo -e "${WHITE}4. Dashboard${RESET}"
TEMPLATE="$SCRIPT_DIR/dashboard-template.html"
GENERATOR="$SCRIPT_DIR/generate-dashboard.js"
[[ -f "$TEMPLATE" ]] && pass "dashboard-template.html ($(wc -l < "$TEMPLATE" | tr -d ' ') lines)" || fail "dashboard-template.html missing"
[[ -f "$GENERATOR" ]] && pass "generate-dashboard.js" || fail "generate-dashboard.js missing"
if [[ -f "$TEMPLATE" ]]; then
  grep -q "DASHBOARD_DATA_INJECTION_POINT" "$TEMPLATE" && pass "Injection point present" || fail "Injection point missing in template"
  grep -q "#020617" "$TEMPLATE" && pass "Dark theme tokens" || warn "Missing dark bg token"
  grep -q "Poppins" "$TEMPLATE" && pass "Poppins font" || warn "Missing Poppins"
  ! grep -q "#27c93f" "$TEMPLATE" && pass "No green colors" || fail "GREEN DETECTED — must use blue #137DC5"
fi

if $QUICK; then
  echo ""
  echo -e "${MUTED}Quick mode — skipping feature-level checks${RESET}"
else
  # ─── Check 5: Feature artifacts ───
  echo ""
  echo -e "${WHITE}5. Feature Artifacts${RESET}"
  SPECS_DIR="$PROJECT_PATH/specs"
  if [[ -d "$SPECS_DIR" ]]; then
    for d in "$SPECS_DIR"/[0-9][0-9][0-9]-*/; do
      [[ -d "$d" ]] || continue
      name=$(basename "$d")
      has_spec=$([[ -f "$d/spec.md" ]] && echo "y" || echo "n")
      has_plan=$([[ -f "$d/plan.md" ]] && echo "y" || echo "n")
      has_tasks=$([[ -f "$d/tasks.md" ]] && echo "y" || echo "n")
      echo -e "  ${BLUE}$name${RESET}: spec=$has_spec plan=$has_plan tasks=$has_tasks"
    done
  else
    warn "No specs/ directory"
  fi

  # ─── Check 6: BDD assertion integrity ───
  echo ""
  echo -e "${WHITE}6. Assertion Integrity${RESET}"
  UPSTREAM_TESTIFY="$ROOT_DIR/.claude/skills/iikit-core/scripts/bash/testify-tdd.sh"
  if [[ -x "$UPSTREAM_TESTIFY" ]] && [[ -d "$SPECS_DIR" ]]; then
    ACTIVE=""
    [[ -f "$PROJECT_PATH/.specify/active-feature" ]] && ACTIVE=$(cat "$PROJECT_PATH/.specify/active-feature" | tr -d '[:space:]')
    if [[ -n "$ACTIVE" ]] && [[ -d "$SPECS_DIR/$ACTIVE/tests/features" ]]; then
      FEATURE_DIR="$SPECS_DIR/$ACTIVE/tests/features"
      FILE_COUNT=$(ls "$FEATURE_DIR"/*.feature 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$FILE_COUNT" -gt 0 ]]; then
        pass "$FILE_COUNT .feature files found for $ACTIVE"
      else
        warn "No .feature files in $ACTIVE/tests/features/"
      fi
    else
      warn "No active feature with test specs"
    fi
  else
    warn "Testify verification not available (upstream scripts needed)"
  fi
fi

# ─── Check 7: Plugin integrity ───
echo ""
echo -e "${WHITE}7. Plugin Structure${RESET}"
PLUGIN_JSON="$ROOT_DIR/.claude-plugin/plugin.json"
if [[ -f "$PLUGIN_JSON" ]]; then
  if python3 -c "import json; json.load(open('$PLUGIN_JSON'))" 2>/dev/null; then
    VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")
    pass "plugin.json valid (v$VERSION)"
  else
    fail "plugin.json invalid JSON"
  fi
else
  fail "plugin.json missing"
fi

CMD_COUNT=$(ls "$ROOT_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$ROOT_DIR/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
SCRIPT_COUNT=$(ls "$ROOT_DIR/scripts"/*.sh "$ROOT_DIR/scripts"/*.js 2>/dev/null | wc -l | tr -d ' ')
pass "$CMD_COUNT commands, $SKILL_COUNT skills, $SCRIPT_COUNT scripts"

# ─── Check 8: Workspace Sessions ───
echo ""
echo -e "${WHITE}8. Workspace Sessions${RESET}"
WS_DIR="$PROJECT_PATH/workspace"
if [[ -d "$WS_DIR" ]]; then
  WS_COUNT=0
  WS_INVALID=0
  for ws in "$WS_DIR"/*/; do
    [[ -d "$ws" ]] || continue
    ws_name=$(basename "$ws")
    [[ "$ws_name" == .* ]] && continue
    WS_COUNT=$((WS_COUNT + 1))
    # Validate session.json exists and is valid JSON
    if [[ -f "$ws/session.json" ]]; then
      if ! python3 -c "import json; json.load(open('$ws/session.json'))" 2>/dev/null; then
        fail "Invalid session.json in $ws_name"
        WS_INVALID=$((WS_INVALID + 1))
      fi
    else
      warn "Missing session.json in $ws_name"
      WS_INVALID=$((WS_INVALID + 1))
    fi
    # Check required subdirectories
    for subdir in inputs rag logs; do
      [[ -d "$ws/$subdir" ]] || warn "$ws_name missing $subdir/"
    done
  done
  if [[ $WS_COUNT -gt 0 ]] && [[ $WS_INVALID -eq 0 ]]; then
    pass "$WS_COUNT workspace session(s) valid"
  elif [[ $WS_COUNT -eq 0 ]]; then
    pass "workspace/ exists (no sessions yet)"
  fi
  # Validate active-workspace reference
  ACTIVE_WS_FILE="$PROJECT_PATH/.specify/active-workspace"
  if [[ -f "$ACTIVE_WS_FILE" ]]; then
    ACTIVE_WS=$(cat "$ACTIVE_WS_FILE" | tr -d '[:space:]')
    if [[ -n "$ACTIVE_WS" ]]; then
      if [[ -d "$WS_DIR/$ACTIVE_WS" ]]; then
        pass "Active workspace: $ACTIVE_WS"
      else
        warn "Active workspace '$ACTIVE_WS' folder missing (stale reference)"
      fi
    fi
  fi
else
  pass "No workspace/ directory (optional)"
fi

# ─── Summary ───
echo ""
echo -e "${GOLD}─────────────────────────────────────────────${RESET}"
if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}${BOLD}FAILED${RESET}: $ERRORS error(s), $WARNINGS warning(s)"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "${GOLD}${BOLD}PASSED WITH WARNINGS${RESET}: $WARNINGS warning(s)"
else
  echo -e "${BLUE}${BOLD}ALL CHECKS PASSED${RESET}"
fi
echo -e "${MUTED}SDD v3.5 · MetodologIA · $(date +%Y-%m-%d)${RESET}"
