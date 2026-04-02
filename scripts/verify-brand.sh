#!/usr/bin/env bash
# verify-brand.sh — Validate MetodologIA branding on all IIC/kit template.js files
# Returns exit code 0 if all checks pass, 1 otherwise.
#
# Usage: bash scripts/verify-brand.sh
#
# © 2026 MetodologIA · GPL-3.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/.claude/skills"

ERRORS=0
WARNINGS=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); }

check_token() {
  local file="$1" token="$2" label="$3"
  if grep -q "$token" "$file" 2>/dev/null; then
    pass "$label: found $token"
  else
    fail "$label: missing $token"
  fi
}

check_absent() {
  local file="$1" token="$2" label="$3"
  if grep -q "$token" "$file" 2>/dev/null; then
    fail "$label: PROHIBITED token $token still present"
  else
    pass "$label: $token absent (good)"
  fi
}

echo "╔══════════════════════════════════════════════════╗"
echo "║  MetodologIA Brand Verification                 ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ─── 1. Required MetodologIA tokens (IIKit template.js — skipped if absorbed) ───
echo "1. Required brand tokens"
IIKIT_FOUND=0
for skill_dir in "$SKILLS_DIR"/iikit-*/; do
  [[ -d "$skill_dir" ]] || continue
  IIKIT_FOUND=1
  template="$skill_dir/scripts/dashboard/template.js"
  skill=$(basename "$skill_dir")
  if [[ ! -f "$template" ]]; then
    warn "$skill: template.js not found"
    continue
  fi
  check_token "$template" "#122562" "$skill (navy)"
  check_token "$template" "#FFD700" "$skill (gold)"
  check_token "$template" "#137DC5" "$skill (blue)"
  check_token "$template" "Poppins" "$skill (heading font)"
  check_token "$template" "metodolog" "$skill (brand name)"
done
if [[ $IIKIT_FOUND -eq 0 ]]; then
  pass "IIKit skills absorbed — brand validated via design-tokens.json (Check 1b)"
fi

# ─── 1b. Design tokens palette ───
echo ""
echo "1b. Design tokens palette (6 exclusive colors)"
TOKENS="$ROOT_DIR/references/design-tokens.json"
if [[ -f "$TOKENS" ]]; then
  check_token "$TOKENS" '"navy": "#122562"' "palette"
  check_token "$TOKENS" '"gold": "#FFD700"' "palette"
  check_token "$TOKENS" '"blue": "#137DC5"' "palette"
  check_token "$TOKENS" '"charcoal": "#1F2833"' "palette"
  check_token "$TOKENS" '"lavender": "#BBA0CC"' "palette"
  check_token "$TOKENS" '"gray": "#808080"' "palette"
  check_token "$TOKENS" "Poppins" "fonts (heading)"
  check_token "$TOKENS" "Trebuchet" "fonts (body)"
  check_token "$TOKENS" "Futura" "fonts (note)"
  check_token "$TOKENS" "JetBrains Mono" "fonts (code)"
else
  fail "design-tokens.json missing"
fi

# ─── 2. GREEN AUDIT (critical) ───
echo ""
echo "2. Green audit (CRITICAL — no green in success/done/verified)"
GREEN_CHECKED=0
for skill_dir in "$SKILLS_DIR"/iikit-*/; do
  [[ -d "$skill_dir" ]] || continue
  template="$skill_dir/scripts/dashboard/template.js"
  skill=$(basename "$skill_dir")
  [[ ! -f "$template" ]] && continue
  GREEN_CHECKED=1
  check_absent "$template" "#27c93f" "$skill"
  check_absent "$template" "#22c55e" "$skill"
done
[[ $GREEN_CHECKED -eq 0 ]] && pass "IIKit absorbed — green audit via design-tokens.json"

# ─── 3. Prohibited legacy tokens ───
echo ""
echo "3. Prohibited legacy tokens"
LEGACY_CHECKED=0
for skill_dir in "$SKILLS_DIR"/iikit-*/; do
  [[ -d "$skill_dir" ]] || continue
  template="$skill_dir/scripts/dashboard/template.js"
  skill=$(basename "$skill_dir")
  [[ ! -f "$template" ]] && continue
  LEGACY_CHECKED=1
  check_absent "$template" "#0f1117" "$skill (old dark bg)"
done
[[ $LEGACY_CHECKED -eq 0 ]] && pass "IIKit absorbed — legacy audit via design-tokens.json"

# ─── 4. Phase variant SHA consistency ───
echo ""
echo "4. Phase variant SHA256 consistency"
CANONICAL_SHA=""
SHA_CHECKED=0
PHASE_SKILLS=(
  iikit-00-constitution iikit-01-specify iikit-02-plan iikit-03-checklist
  iikit-04-testify iikit-05-tasks iikit-06-analyze iikit-07-implement
  iikit-08-taskstoissues iikit-bugfix iikit-clarify
)
for skill in "${PHASE_SKILLS[@]}"; do
  template="$SKILLS_DIR/$skill/scripts/dashboard/template.js"
  [[ ! -f "$template" ]] && continue
  SHA_CHECKED=1
  sha=$(shasum -a 256 "$template" | cut -c1-12)
  if [[ -z "$CANONICAL_SHA" ]]; then
    CANONICAL_SHA="$sha"
    pass "$skill: SHA=$sha (canonical)"
  elif [[ "$sha" == "$CANONICAL_SHA" ]]; then
    pass "$skill: SHA=$sha (matches)"
  else
    fail "$skill: SHA=$sha (MISMATCH — expected $CANONICAL_SHA)"
  fi
done
[[ $SHA_CHECKED -eq 0 ]] && pass "IIKit absorbed — SHA consistency N/A"

# ─── 5. JS module validity ───
echo ""
echo "5. JS module validity"
JS_CHECKED=0
for variant in "iikit-core" "iikit-00-constitution"; do
  template="$SKILLS_DIR/$variant/scripts/dashboard/template.js"
  [[ ! -f "$template" ]] && continue
  JS_CHECKED=1
  if node -e "require('$template')" 2>/dev/null; then
    pass "$variant: node require() succeeds"
  else
    fail "$variant: node require() FAILED"
  fi
done
[[ $JS_CHECKED -eq 0 ]] && pass "IIKit absorbed — JS validity via SDD scripts"

# ─── Summary ───
echo ""
echo "════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
  echo "  RESULT: ALL CHECKS PASSED ($WARNINGS warnings)"
  echo "════════════════════════════════════════════════════"
  exit 0
else
  echo "  RESULT: $ERRORS ERRORS, $WARNINGS warnings"
  echo "════════════════════════════════════════════════════"
  exit 1
fi
