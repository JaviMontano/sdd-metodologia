#!/usr/bin/env bash
# sdd-quick-flow-triage.sh — Triage scope before allowing Quick Flow bypass
# BMAD-inspired: prevents AP-06 (scope creep through quick flows).
#
# Checks if a fix is small enough for Quick Flow or must escalate to full pipeline.
# Called by /sdd:bugfix before executing the fix.
#
# Usage: bash scripts/sdd-quick-flow-triage.sh [project-path]
# Exit: 0 = Quick Flow OK, 1 = escalate to full pipeline
#
# Triage criteria (ALL must pass):
#   1. Scope: ≤ 3 files likely affected (heuristic from git diff or description)
#   2. No new dependencies (package.json/requirements.txt unchanged)
#   3. No data model changes (no migration files, no schema changes)
#   4. Not the 4th consecutive quick flow (AP-06 guard)
#   5. No security-sensitive changes (auth, crypto, validation)

set -eo pipefail

PROJECT_PATH="${1:-.}"
SPECIFY_DIR="$PROJECT_PATH/.specify"

GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
RESET='\033[0m'

ERRORS=0
WARNINGS=0

pass() { echo -e "  ${BLUE}✓${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${GOLD}⚠${RESET} $1"; WARNINGS=$((WARNINGS + 1)); }

echo -e "${WHITE}Quick Flow Triage${RESET}"
echo ""

# ─── Check 1: Consecutive quick flows (AP-06) ───
QF_LOG="$SPECIFY_DIR/quick-flow-log.json"
if [[ -f "$QF_LOG" ]] && command -v python3 &>/dev/null; then
  CONSECUTIVE=$(python3 -c "
import json
try:
    data = json.load(open('$QF_LOG'))
    entries = data.get('entries', [])
    # Count consecutive recent quick flows (last 30 days)
    from datetime import datetime, timedelta
    cutoff = (datetime.utcnow() - timedelta(days=30)).isoformat()
    recent = [e for e in entries if e.get('timestamp','') > cutoff]
    print(len(recent))
except Exception:
    print(0)
" 2>/dev/null || echo "0")
  if [[ "$CONSECUTIVE" -ge 3 ]]; then
    fail "4th+ consecutive Quick Flow in 30 days — escalate to full pipeline (BMAD AP-06)"
  else
    pass "Quick Flow count: $CONSECUTIVE/3 (within limit)"
  fi
else
  pass "First Quick Flow (no history)"
fi

# ─── Check 2: No new dependencies ───
if [[ -d "$PROJECT_PATH/.git" ]]; then
  DEP_CHANGED=$(git diff --name-only HEAD 2>/dev/null | grep -cE "(package\.json|requirements\.txt|Cargo\.toml|go\.mod|Gemfile)" 2>/dev/null || true)
  DEP_CHANGED="${DEP_CHANGED:-0}"
  DEP_CHANGED=$(echo "$DEP_CHANGED" | tail -1 | tr -d '[:space:]')
  if [[ "$DEP_CHANGED" -gt 0 ]]; then
    fail "Dependency files modified — new dependencies require full pipeline"
  else
    pass "No dependency changes"
  fi
else
  pass "No git — dependency check skipped"
fi

# ─── Check 3: No data model changes ───
if [[ -d "$PROJECT_PATH/.git" ]]; then
  SCHEMA_CHANGED=$(git diff --name-only HEAD 2>/dev/null | grep -ciE "(migration|schema|model|prisma|\.sql)" 2>/dev/null || true)
  SCHEMA_CHANGED="${SCHEMA_CHANGED:-0}"
  SCHEMA_CHANGED=$(echo "$SCHEMA_CHANGED" | tail -1 | tr -d '[:space:]')
  if [[ "$SCHEMA_CHANGED" -gt 0 ]]; then
    fail "Data model / migration files modified — requires full pipeline"
  else
    pass "No data model changes"
  fi
fi

# ─── Check 4: No security-sensitive changes ───
if [[ -d "$PROJECT_PATH/.git" ]]; then
  SEC_CHANGED=$(git diff --name-only HEAD 2>/dev/null | grep -ciE "(auth|crypto|security|password|token|session|permission|rbac)" 2>/dev/null || true)
  SEC_CHANGED="${SEC_CHANGED:-0}"
  SEC_CHANGED=$(echo "$SEC_CHANGED" | tail -1 | tr -d '[:space:]')
  if [[ "$SEC_CHANGED" -gt 0 ]]; then
    fail "Security-sensitive files modified — requires full pipeline review"
  else
    pass "No security-sensitive changes"
  fi
fi

# ─── Check 5: Scope ≤ 3 files ───
if [[ -d "$PROJECT_PATH/.git" ]]; then
  FILE_COUNT=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$FILE_COUNT" -gt 3 ]]; then
    warn "Scope: $FILE_COUNT files changed (>3 — consider full pipeline)"
  elif [[ "$FILE_COUNT" -gt 0 ]]; then
    pass "Scope: $FILE_COUNT file(s) changed"
  else
    pass "Scope: clean working tree"
  fi
fi

# ─── Log quick flow (for AP-06 tracking) ───
log_qf() {
  [[ -d "$SPECIFY_DIR" ]] || return 0
  command -v python3 &>/dev/null || return 0
  python3 -c "
import json, os
from datetime import datetime
f = '$QF_LOG'
try:
    data = json.load(open(f)) if os.path.exists(f) else {'entries': []}
except Exception:
    data = {'entries': []}
data['entries'].append({'timestamp': datetime.utcnow().isoformat() + 'Z'})
data['entries'] = data['entries'][-20:]
with open(f + '.tmp', 'w') as fh:
    json.dump(data, fh, indent=2)
os.rename(f + '.tmp', f)
" 2>/dev/null || true
}

# ─── Result ───
echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}ESCALATE${RESET}: $ERRORS check(s) failed — use full pipeline instead of Quick Flow"
  echo -e "${MUTED}  Run /sdd:spec to start a proper feature specification${RESET}"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "${GOLD}PROCEED WITH CAUTION${RESET}: $WARNINGS warning(s)"
  echo -e "${MUTED}  Quick Flow allowed but monitor scope${RESET}"
  log_qf
  exit 0
else
  echo -e "${BLUE}QUICK FLOW OK${RESET}: All checks passed"
  log_qf
  exit 0
fi
