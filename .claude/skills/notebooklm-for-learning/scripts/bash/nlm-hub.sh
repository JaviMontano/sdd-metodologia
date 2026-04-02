#!/usr/bin/env bash
# =============================================================================
# nlm-hub.sh — Hub notebook template rendering and status for NLM for Learning
# =============================================================================
# Renders markdown templates by replacing placeholders with values from the
# state file. Used to generate hub notes (index, diagnosis, study_path).
#
# Template placeholders:
#   {TOPIC}           — Topic name
#   {D1_COUNT}..{D7_COUNT}   — Source counts per dimension
#   {D1_STATUS}..{D7_STATUS} — Status per dimension
#   {L1_STATUS}..{L3_STATUS} — Status per level
#   {TOTAL_SOURCES}   — Aggregate source count
#   {MODE}            — Pipeline mode (standard/express/deep)
#   {PIPELINE_DURATION} — Duration in minutes
#   {TIMESTAMP}       — Current ISO timestamp
#   {L1_ARTIFACTS}..{L3_ARTIFACTS} — Artifact count per level
#   {L1_TUTOR}..{L3_TUTOR}         — Chat configured status per level
#
# Usage (as CLI):
#   bash nlm-hub.sh render notebook-index
#   bash nlm-hub.sh render auto-diagnosis
#   bash nlm-hub.sh render study-path
#   bash nlm-hub.sh status
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/nlm-common.sh"
source "$SCRIPT_DIR/nlm-state.sh"

nlm_require_jq

# ---------------------------------------------------------------------------
# nlm_render_template(template_file)
# ---------------------------------------------------------------------------
# Read a template from the templates/ directory, replace all placeholders
# with values from the state file using jq, and echo the rendered content.
#
# Template files are located at:
#   .claude/skills/notebooklm-for-learning/templates/{name}.md
#
# Accepted template names: notebook-index, auto-diagnosis, study-path
#
# Usage:
#   rendered="$(nlm_render_template "notebook-index")"
#   rendered="$(nlm_render_template "auto-diagnosis")"
# ---------------------------------------------------------------------------
nlm_render_template() {
  local template_name="${1:?template name is required (e.g. notebook-index)}"
  local root
  root="$(nlm_project_root)"
  local template_path="${root}/${NLM_SKILL_DIR}/templates/${template_name}.md"
  local state_path
  state_path="$(nlm_get_state_path)"

  if [[ ! -f "$template_path" ]]; then
    nlm_log "ERROR" "Template not found: $template_path"
    return 1
  fi

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  # Read all values from state
  local topic mode total_sources pipeline_duration
  topic="$(jq -r '.topic // "Unknown"' "$state_path")"
  mode="$(jq -r '.mode // "standard"' "$state_path")"
  total_sources="$(jq -r '.metrics.total_sources // 0' "$state_path")"
  pipeline_duration="$(jq -r '.metrics.pipeline_duration_minutes // 0' "$state_path")"

  # Dimension values
  local d1_count d2_count d3_count d4_count d5_count d6_count d7_count
  d1_count="$(jq -r '.dimensions.D1.source_count // 0' "$state_path")"
  d2_count="$(jq -r '.dimensions.D2.source_count // 0' "$state_path")"
  d3_count="$(jq -r '.dimensions.D3.source_count // 0' "$state_path")"
  d4_count="$(jq -r '.dimensions.D4.source_count // 0' "$state_path")"
  d5_count="$(jq -r '.dimensions.D5.source_count // 0' "$state_path")"
  d6_count="$(jq -r '.dimensions.D6.source_count // 0' "$state_path")"
  d7_count="$(jq -r '.dimensions.D7.source_count // 0' "$state_path")"

  local d1_status d2_status d3_status d4_status d5_status d6_status d7_status
  d1_status="$(jq -r '.dimensions.D1.status // "pending"' "$state_path")"
  d2_status="$(jq -r '.dimensions.D2.status // "pending"' "$state_path")"
  d3_status="$(jq -r '.dimensions.D3.status // "pending"' "$state_path")"
  d4_status="$(jq -r '.dimensions.D4.status // "pending"' "$state_path")"
  d5_status="$(jq -r '.dimensions.D5.status // "pending"' "$state_path")"
  d6_status="$(jq -r '.dimensions.D6.status // "pending"' "$state_path")"
  d7_status="$(jq -r '.dimensions.D7.status // "pending"' "$state_path")"

  # Level values
  local l1_status l2_status l3_status
  l1_status="$(jq -r '.levels.L1.status // "pending"' "$state_path")"
  l2_status="$(jq -r '.levels.L2.status // "pending"' "$state_path")"
  l3_status="$(jq -r '.levels.L3.status // "pending"' "$state_path")"

  # Artifact counts per level (count completed artifacts)
  local l1_artifacts l2_artifacts l3_artifacts
  l1_artifacts="$(jq '[.levels.L1.artifacts | to_entries[] | select(.value.status == "completed")] | length' "$state_path")"
  l2_artifacts="$(jq '[.levels.L2.artifacts | to_entries[] | select(.value.status == "completed")] | length' "$state_path")"
  l3_artifacts="$(jq '[.levels.L3.artifacts | to_entries[] | select(.value.status == "completed")] | length' "$state_path")"

  # Tutor status per level
  local l1_tutor l2_tutor l3_tutor
  l1_tutor="$(jq -r 'if .levels.L1.chat_configured then "Configured" else "Pending" end' "$state_path")"
  l2_tutor="$(jq -r 'if .levels.L2.chat_configured then "Configured" else "Pending" end' "$state_path")"
  l3_tutor="$(jq -r 'if .levels.L3.chat_configured then "Configured" else "Pending" end' "$state_path")"

  local timestamp
  timestamp="$(nlm_now_iso)"

  # Read template and perform replacements
  local content
  content="$(cat "$template_path")"

  content="${content//\{TOPIC\}/$topic}"
  content="${content//\{MODE\}/$mode}"
  content="${content//\{TOTAL_SOURCES\}/$total_sources}"
  content="${content//\{PIPELINE_DURATION\}/$pipeline_duration}"
  content="${content//\{TIMESTAMP\}/$timestamp}"

  content="${content//\{D1_COUNT\}/$d1_count}"
  content="${content//\{D2_COUNT\}/$d2_count}"
  content="${content//\{D3_COUNT\}/$d3_count}"
  content="${content//\{D4_COUNT\}/$d4_count}"
  content="${content//\{D5_COUNT\}/$d5_count}"
  content="${content//\{D6_COUNT\}/$d6_count}"
  content="${content//\{D7_COUNT\}/$d7_count}"

  content="${content//\{D1_STATUS\}/$d1_status}"
  content="${content//\{D2_STATUS\}/$d2_status}"
  content="${content//\{D3_STATUS\}/$d3_status}"
  content="${content//\{D4_STATUS\}/$d4_status}"
  content="${content//\{D5_STATUS\}/$d5_status}"
  content="${content//\{D6_STATUS\}/$d6_status}"
  content="${content//\{D7_STATUS\}/$d7_status}"

  content="${content//\{L1_STATUS\}/$l1_status}"
  content="${content//\{L2_STATUS\}/$l2_status}"
  content="${content//\{L3_STATUS\}/$l3_status}"

  content="${content//\{L1_ARTIFACTS\}/$l1_artifacts}"
  content="${content//\{L2_ARTIFACTS\}/$l2_artifacts}"
  content="${content//\{L3_ARTIFACTS\}/$l3_artifacts}"

  content="${content//\{L1_TUTOR\}/$l1_tutor}"
  content="${content//\{L2_TUTOR\}/$l2_tutor}"
  content="${content//\{L3_TUTOR\}/$l3_tutor}"

  echo "$content"
}

# ---------------------------------------------------------------------------
# nlm_hub_status()
# ---------------------------------------------------------------------------
# Read hub note IDs from the state file and print which are present/missing.
# Also shows the hub notebook_id and URL.
#
# Usage:
#   nlm_hub_status
# ---------------------------------------------------------------------------
nlm_hub_status() {
  local state_path
  state_path="$(nlm_get_state_path)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  echo "=== Hub Notebook Status ==="

  local hub_id hub_url
  hub_id="$(jq -r '.hub.notebook_id // "null"' "$state_path")"
  hub_url="$(jq -r '.hub.url // "null"' "$state_path")"

  if [[ "$hub_id" == "null" ]]; then
    echo "  Hub notebook: NOT CREATED"
    return 1
  fi

  echo "  Notebook ID: $hub_id"
  echo "  URL: $hub_url"
  echo ""
  echo "  Notes:"

  local notes=("index" "diagnosis" "study_path")
  local present=0
  local total=${#notes[@]}

  for note in "${notes[@]}"; do
    local note_id
    note_id="$(jq -r ".hub.notes.${note} // \"null\"" "$state_path")"

    if [[ "$note_id" == "null" || -z "$note_id" ]]; then
      echo "    ${note}: MISSING"
    else
      echo "    ${note}: ${note_id}"
      ((present++))
    fi
  done

  echo ""
  echo "  Hub completeness: ${present}/${total} notes"

  if [[ $present -eq $total ]]; then
    return 0
  else
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
    render)
      template="${1:-}"
      if [[ -z "$template" ]]; then
        echo "Error: template name required"
        echo "Available: notebook-index, auto-diagnosis, study-path"
        exit 1
      fi
      nlm_render_template "$template"
      ;;
    status)
      nlm_hub_status
      ;;
    help|*)
      echo "Usage: bash nlm-hub.sh <command> [args]"
      echo ""
      echo "Commands:"
      echo "  render <template>  Render a template with state values"
      echo "                     Templates: notebook-index, auto-diagnosis, study-path"
      echo "  status             Show hub notebook status and note presence"
      ;;
  esac
fi
