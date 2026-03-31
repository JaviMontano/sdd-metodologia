#!/usr/bin/env bash
# sdd-hooks-install.sh — Install SDD git hooks for assertion integrity
#
# Usage: bash scripts/sdd-hooks-install.sh [project-path]
#
# Installs pre-commit and post-commit hooks that verify BDD assertion hashes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH="${1:-.}"

GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
RESET='\033[0m'

HOOKS_DIR="$PROJECT_PATH/.git/hooks"

if [[ ! -d "$PROJECT_PATH/.git" ]]; then
  echo -e "${MUTED}Not a git repository — skipping hook installation${RESET}"
  exit 0
fi

mkdir -p "$HOOKS_DIR"

UPSTREAM_PRE="$ROOT_DIR/.claude/skills/iikit-core/scripts/bash/pre-commit-hook.sh"
UPSTREAM_POST="$ROOT_DIR/.claude/skills/iikit-core/scripts/bash/post-commit-hook.sh"

install_hook() {
  local hook_name="$1"
  local upstream_script="$2"
  local target="$HOOKS_DIR/$hook_name"

  if [[ ! -f "$upstream_script" ]]; then
    echo -e "  ${MUTED}$hook_name: upstream script not found, skipping${RESET}"
    return
  fi

  if [[ -f "$target" ]]; then
    # Check if it's an SDD hook
    if grep -q "SDD\|IIKit\|iikit" "$target" 2>/dev/null; then
      cp "$upstream_script" "$target"
      chmod +x "$target"
      echo -e "  ${BLUE}$hook_name${RESET}: updated (SDD hook replaced)"
    else
      echo -e "  ${GOLD}$hook_name${RESET}: existing non-SDD hook preserved"
      echo -e "    ${MUTED}To override: rm $target && re-run this script${RESET}"
    fi
  else
    cp "$upstream_script" "$target"
    chmod +x "$target"
    echo -e "  ${BLUE}$hook_name${RESET}: installed"
  fi
}

echo -e "${WHITE}Installing SDD git hooks...${RESET}"

# Try upstream hooks first, fallback to SDD-native
if [[ -f "$UPSTREAM_PRE" ]]; then
  install_hook "pre-commit" "$UPSTREAM_PRE"
else
  # SDD-native pre-commit: verify assertion hashes on .feature changes (M-04)
  SDD_PRE="$HOOKS_DIR/pre-commit"
  if [[ ! -f "$SDD_PRE" ]] || grep -q "SDD\|IIKit\|iikit" "$SDD_PRE" 2>/dev/null; then
    cat > "$SDD_PRE" << 'HOOKEOF'
#!/usr/bin/env bash
# SDD pre-commit hook — assertion integrity verification
# Blocks commit if .feature files were modified and hashes don't match.

HASH_FILE=".specify/assertion-hashes.json"
SCRIPT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"

# Only check if .feature files are staged AND hashes exist
STAGED_FEATURES=$(git diff --cached --name-only -- '*.feature' 2>/dev/null)
if [ -z "$STAGED_FEATURES" ]; then
  exit 0  # No .feature files staged — allow commit
fi

if [ ! -f "$HASH_FILE" ]; then
  exit 0  # No hashes generated yet — allow (first-time setup)
fi

# Run verification
VERIFY_SCRIPT="$SCRIPT_DIR/scripts/sdd-assertion-hash.sh"
if [ -x "$VERIFY_SCRIPT" ]; then
  if ! bash "$VERIFY_SCRIPT" verify "$SCRIPT_DIR" 2>/dev/null | grep -q "ALL.*verified"; then
    echo ""
    echo "╔══════════════════════════════════════════════════╗"
    echo "║  SDD: Assertion hash MISMATCH detected          ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
    echo "  .feature files were modified after hashing."
    echo "  This may indicate unintended test tampering."
    echo ""
    echo "  To update hashes:  bash scripts/sdd-assertion-hash.sh generate"
    echo "  To force commit:   git commit --no-verify"
    echo ""
    exit 1
  fi
fi

exit 0
HOOKEOF
    chmod +x "$SDD_PRE"
    echo -e "  ${BLUE}pre-commit${RESET}: SDD-native assertion integrity hook installed"
  else
    echo -e "  ${GOLD}pre-commit${RESET}: existing non-SDD hook preserved"
  fi
fi

if [[ -f "$UPSTREAM_POST" ]]; then
  install_hook "post-commit" "$UPSTREAM_POST"
fi

echo ""
echo -e "${BLUE}Hooks installed.${RESET} Assertion integrity verified on each commit."
echo -e "${MUTED}Pre-commit: blocks commit if .feature hashes don't match${RESET}"
echo -e "${MUTED}Re-hash after spec changes: bash scripts/sdd-assertion-hash.sh generate${RESET}"
