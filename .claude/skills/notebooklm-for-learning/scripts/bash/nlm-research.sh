#!/usr/bin/env bash
# =============================================================================
# nlm-research.sh — Research orchestration helpers for NLM for Learning
# =============================================================================
# Provides prompt building, poll guidance, and harvest checking.
#
# IMPORTANT: Actual MCP tool calls (research_start, research_status, etc.)
# are executed by the AGENT, not by bash. These functions provide data
# preparation and state inspection that supports the agent's MCP workflow.
#
# Usage (as library):
#   source nlm-common.sh
#   source nlm-state.sh
#   source nlm-research.sh
#
# Usage (as CLI):
#   bash nlm-research.sh build-prompt D1 "BMAD Method"
#   bash nlm-research.sh check-harvest
#   bash nlm-research.sh poll-guidance D1
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/nlm-common.sh"
source "$SCRIPT_DIR/nlm-state.sh"

nlm_require_jq

# ---------------------------------------------------------------------------
# nlm_build_prompt(dimension_number, topic)
# ---------------------------------------------------------------------------
# Read the dimension prompt template from references/dimension-prompts.md,
# extract the code block for the given dimension, and replace {TOPIC}.
#
# The dimension-prompts.md file has sections like:
#   ## D1: Body of Knowledge (BoK)
#   ```
#   Build a comprehensive Body of Knowledge for "{TOPIC}":
#   ...
#   ```
#
# Usage:
#   prompt="$(nlm_build_prompt "D1" "BMAD Method")"
#   prompt="$(nlm_build_prompt "D3" "React Hooks")"
# ---------------------------------------------------------------------------
nlm_build_prompt() {
  local dim="${1:?dimension is required (e.g. D1)}"
  local topic="${2:?topic is required}"

  # Resolve path to dimension-prompts.md relative to skill dir
  local prompts_file
  local root
  root="$(nlm_project_root)"
  prompts_file="${root}/${NLM_SKILL_DIR}/references/dimension-prompts.md"

  if [[ ! -f "$prompts_file" ]]; then
    nlm_log "ERROR" "Dimension prompts file not found: $prompts_file"
    return 1
  fi

  # Extract the code block following the dimension header.
  # Strategy: find the line with "## D{N}:", then capture everything between
  # the next ``` delimiters.
  local in_section=false
  local in_block=false
  local prompt=""

  while IFS= read -r line; do
    # Detect section header (e.g. "## D1:" or "## D3:")
    if [[ "$line" =~ ^##[[:space:]]+${dim}: ]]; then
      in_section=true
      continue
    fi

    # If we hit a new ## section header while in our section, stop
    if $in_section && [[ "$line" =~ ^##[[:space:]] ]] && ! [[ "$line" =~ ^##[[:space:]]+${dim}: ]]; then
      break
    fi

    # Track code block boundaries within our section
    if $in_section; then
      if [[ "$line" =~ ^\`\`\` ]]; then
        if $in_block; then
          # End of code block — we have our prompt
          break
        else
          in_block=true
          continue
        fi
      fi

      if $in_block; then
        if [[ -n "$prompt" ]]; then
          prompt="${prompt}"$'\n'"${line}"
        else
          prompt="${line}"
        fi
      fi
    fi
  done < "$prompts_file"

  if [[ -z "$prompt" ]]; then
    nlm_log "ERROR" "No prompt template found for dimension $dim"
    return 1
  fi

  # Replace {TOPIC} placeholder
  echo "${prompt//\{TOPIC\}/$topic}"
}

# ---------------------------------------------------------------------------
# nlm_poll_status(notebook_id, task_id)
# ---------------------------------------------------------------------------
# This function does NOT call MCP directly — it outputs the guidance pattern
# that the agent should follow when polling research status.
#
# The agent should use:
#   research_status(
#     notebook_id=<id>,
#     task_id=<task_id>,      # IMPORTANT: use latest task_id, it can change
#     max_wait=0,             # Non-blocking: returns immediately
#     compact=true,           # Reduce token usage
#     poll_interval=30        # Ignored when max_wait=0
#   )
#
# For round-robin polling across 7 dimensions, ALWAYS use max_wait=0
# to avoid blocking for 5 minutes per dimension.
#
# Usage:
#   nlm_poll_status "notebook-uuid" "task-uuid"
# ---------------------------------------------------------------------------
nlm_poll_status() {
  local notebook_id="${1:?notebook_id is required}"
  local task_id="${2:?task_id is required}"

  # This is a guidance function — output the MCP call pattern
  cat <<EOF
# ---------------------------------------------------------------
# MCP Poll Pattern for research_status (non-blocking)
# ---------------------------------------------------------------
# Tool: research_status
# Parameters:
#   notebook_id: "${notebook_id}"
#   task_id:     "${task_id}"    # WARNING: may change between polls
#   max_wait:    0               # Non-blocking — returns immediately
#   compact:     true            # Save tokens
#
# Expected response fields:
#   status: "in_progress" | "completed" | "failed"
#   sources_found: <number>
#   report: <string> (if compact=false)
#
# CRITICAL: Deep research task_id can CHANGE between polls.
# Always use the task_id from the LATEST research_status response,
# not the original from research_start.
# ---------------------------------------------------------------
EOF
}

# ---------------------------------------------------------------------------
# nlm_check_harvest_complete()
# ---------------------------------------------------------------------------
# Check if all 7 dimensions have status "harvested" in the state file.
# Returns 0 if all harvested, 1 if any are not.
# Prints a summary of each dimension's status.
#
# Usage:
#   if nlm_check_harvest_complete; then
#     echo "All dimensions harvested!"
#   else
#     echo "Some dimensions still in progress"
#   fi
# ---------------------------------------------------------------------------
nlm_check_harvest_complete() {
  local state_path
  state_path="$(nlm_get_state_path)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found"
    return 1
  fi

  local all_harvested=true
  local harvested_count=0
  local total=7

  echo "=== Harvest Status ==="
  for d in "${NLM_DIMENSIONS[@]}"; do
    local status name
    status="$(jq -r ".dimensions.${d}.status" "$state_path")"
    name="$(jq -r ".dimensions.${d}.name" "$state_path")"
    local source_count
    source_count="$(jq -r ".dimensions.${d}.source_count" "$state_path")"

    local indicator="  "
    if [[ "$status" == "harvested" ]]; then
      indicator="OK"
      ((harvested_count++))
    elif [[ "$status" == "error" || "$status" == "timeout" ]]; then
      indicator="!!"
      all_harvested=false
    else
      indicator=".."
      all_harvested=false
    fi

    printf "[%s] %s — %-25s status=%-12s sources=%s\n" \
      "$indicator" "$d" "$name" "$status" "$source_count"
  done

  echo ""
  echo "Progress: ${harvested_count}/${total} dimensions harvested"

  if $all_harvested; then
    nlm_log "INFO" "All dimensions harvested"
    return 0
  else
    nlm_log "INFO" "Harvest incomplete: ${harvested_count}/${total}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Main: CLI dispatch
# ---------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    build-prompt)
      nlm_build_prompt "$@"
      ;;
    check-harvest)
      nlm_check_harvest_complete
      ;;
    poll-guidance)
      dim="${1:?dimension required (e.g. D1)}"
      nb_id="$(nlm_state_read ".dimensions.${dim}.notebook_id")"
      task_id="$(nlm_state_read ".dimensions.${dim}.task_id")"
      if [[ "$nb_id" == "null" || "$task_id" == "null" ]]; then
        nlm_log "ERROR" "${dim}: notebook_id or task_id is null"
        exit 1
      fi
      nlm_poll_status "$nb_id" "$task_id"
      ;;
    help|*)
      echo "Usage: bash nlm-research.sh <command> [args]"
      echo ""
      echo "Commands:"
      echo "  build-prompt <dim> <topic>  Build research prompt for dimension"
      echo "  check-harvest              Check if all 7 dimensions are harvested"
      echo "  poll-guidance <dim>        Show MCP poll pattern for a dimension"
      ;;
  esac
fi
