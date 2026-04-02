#!/usr/bin/env bash
# =============================================================================
# nlm-common.sh — Shared utilities for NLM for Learning skill
# =============================================================================
# Source this file from other NLM scripts:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/nlm-common.sh"
#
# Provides: logging, jq check, state path, timestamps, constants.
# Uses set -uo pipefail (NOT -e, because ((VAR++)) exits when VAR=0 under -e).
# =============================================================================
set -uo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# State file location (relative to project root)
NLM_STATE_FILE=".specify/nlm-learning-state.json"

# Skill directory (relative to .claude/skills/)
NLM_SKILL_DIR=".claude/skills/notebooklm-for-learning"

# Dimension names for iteration
NLM_DIMENSIONS=("D1" "D2" "D3" "D4" "D5" "D6" "D7")

# Level names for iteration
NLM_LEVELS=("L1" "L2" "L3")

# Version
NLM_VERSION="1.0.0"

# ---------------------------------------------------------------------------
# nlm_log(level, msg)
# ---------------------------------------------------------------------------
# Print a prefixed log message with timestamp and severity level.
#
# Usage:
#   nlm_log "INFO" "Hub notebook created"
#   nlm_log "WARN" "Source count below threshold"
#   nlm_log "ERROR" "State file not found"
# ---------------------------------------------------------------------------
nlm_log() {
  local level="${1:-INFO}"
  local msg="${2:-}"
  local timestamp
  timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  echo "[NLM] ${timestamp} [${level}] ${msg}" >&2
}

# ---------------------------------------------------------------------------
# nlm_require_jq()
# ---------------------------------------------------------------------------
# Verify jq is installed and accessible. Exit 1 if not.
#
# Usage:
#   nlm_require_jq
# ---------------------------------------------------------------------------
nlm_require_jq() {
  if ! command -v jq &>/dev/null; then
    nlm_log "ERROR" "jq is required but not installed. Install with: brew install jq"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_get_state_path()
# ---------------------------------------------------------------------------
# Echo the canonical state file path.
#
# Usage:
#   state_path="$(nlm_get_state_path)"
# ---------------------------------------------------------------------------
nlm_get_state_path() {
  echo "${NLM_STATE_FILE}"
}

# ---------------------------------------------------------------------------
# nlm_now_iso()
# ---------------------------------------------------------------------------
# Echo current time in ISO 8601 format (with timezone offset).
#
# Usage:
#   ts="$(nlm_now_iso)"
# ---------------------------------------------------------------------------
nlm_now_iso() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# ---------------------------------------------------------------------------
# nlm_project_root()
# ---------------------------------------------------------------------------
# Attempt to find the project root by looking for .specify/ or .claude/.
# Falls back to current directory.
#
# Usage:
#   root="$(nlm_project_root)"
# ---------------------------------------------------------------------------
nlm_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.specify" ]] || [[ -d "$dir/.claude" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  # Fallback: current directory
  echo "$PWD"
}
