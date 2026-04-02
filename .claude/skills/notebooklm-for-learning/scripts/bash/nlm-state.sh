#!/usr/bin/env bash
# =============================================================================
# nlm-state.sh — State management for NLM for Learning
# =============================================================================
# Manages the persistent JSON state file (.specify/nlm-learning-state.json).
# Provides init, read, update, checkpoint, validate, and slugify operations.
#
# Usage (as library):
#   source nlm-common.sh
#   source nlm-state.sh
#
# Usage (as CLI):
#   bash nlm-state.sh init "BMAD Method" standard
#   bash nlm-state.sh read .dimensions.D1.status
#   bash nlm-state.sh update .status researching
#   bash nlm-state.sh checkpoint "Phase 1" "D1 research launched"
#   bash nlm-state.sh validate
#   bash nlm-state.sh slugify "BMAD Method para desarrollo con IA"
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/nlm-common.sh"

nlm_require_jq

# ---------------------------------------------------------------------------
# nlm_slugify(topic)
# ---------------------------------------------------------------------------
# Convert a topic string to a URL-friendly slug.
# Rules: lowercase, remove accents, drop articles (para/con/de/el/la/los/las/
# un/una), replace spaces with hyphens, remove special chars, max 40 chars.
#
# Usage:
#   slug="$(nlm_slugify "BMAD Method para desarrollo con IA")"
#   # Output: bmad-method-desarrollo-ia
# ---------------------------------------------------------------------------
nlm_slugify() {
  local topic="${1:-}"
  echo "$topic" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/á/a/g; s/é/e/g; s/í/i/g; s/ó/o/g; s/ú/u/g; s/ñ/n/g; s/ü/u/g' \
    | sed -E 's/\b(para|con|de|del|el|la|los|las|un|una|y|en|a)\b//g' \
    | sed 's/[^a-z0-9 -]//g' \
    | sed 's/  */ /g' \
    | sed 's/ /-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//; s/-$//' \
    | cut -c1-40 \
    | sed 's/-$//'
}

# ---------------------------------------------------------------------------
# nlm_state_init(topic, mode)
# ---------------------------------------------------------------------------
# Create the initial JSON state file with all dimensions, levels, gates,
# and metrics initialized to defaults.
#
# Usage:
#   nlm_state_init "BMAD Method" "standard"
#   nlm_state_init "React Hooks" "deep"
# ---------------------------------------------------------------------------
nlm_state_init() {
  local topic="${1:?topic is required}"
  local mode="${2:-standard}"
  local slug
  slug="$(nlm_slugify "$topic")"
  local now
  now="$(nlm_now_iso)"
  local state_path
  state_path="$(nlm_get_state_path)"

  # Ensure parent directory exists
  mkdir -p "$(dirname "$state_path")"

  jq -n \
    --arg version "$NLM_VERSION" \
    --arg topic "$topic" \
    --arg slug "$slug" \
    --arg mode "$mode" \
    --arg now "$now" \
    '{
      version: $version,
      topic: $topic,
      slug: $slug,
      status: "preparing",
      mode: $mode,
      created_at: $now,
      updated_at: $now,

      hub: {
        notebook_id: null,
        url: null,
        notes: {
          index: null,
          diagnosis: null,
          study_path: null
        }
      },

      dimensions: {
        D1: { name: "Body of Knowledge",     notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D2: { name: "State of the Art",       notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D3: { name: "Capability Model",       notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D4: { name: "Profession Assessment",  notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D5: { name: "Maturity Model",         notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D6: { name: "Working Prompts",        notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null },
        D7: { name: "GenAI Applications",     notebook_id: null, url: null, task_id: null, status: "pending", source_count: 0, error: null, started_at: null, completed_at: null }
      },

      levels: {
        L1: { name: "Cero a Competente",     notebook_id: null, url: null, status: "pending", chat_configured: false, artifacts: { audio: {id:null,status:"pending"}, flashcards: {id:null,status:"pending"}, quiz: {id:null,status:"pending"}, mind_map: {id:null,status:"pending"} }, completed_at: null },
        L2: { name: "Competente a Versado",   notebook_id: null, url: null, status: "pending", chat_configured: false, artifacts: { audio: {id:null,status:"pending"}, flashcards: {id:null,status:"pending"}, quiz: {id:null,status:"pending"}, mind_map: {id:null,status:"pending"} }, completed_at: null },
        L3: { name: "Versado a Experto",      notebook_id: null, url: null, status: "pending", chat_configured: false, artifacts: { audio: {id:null,status:"pending"}, flashcards: {id:null,status:"pending"}, quiz: {id:null,status:"pending"}, mind_map: {id:null,status:"pending"} }, completed_at: null }
      },

      checkpoints: [],

      gates: {
        G1_research_launch: { passed: false, checked_at: null, details: "" },
        G2_source_yield:    { passed: false, checked_at: null, details: "" },
        G3_total_sources:   { passed: false, checked_at: null, details: "" },
        G4_tutor_config:    { passed: false, checked_at: null, details: "" },
        G5_artifacts:       { passed: false, checked_at: null, details: "" },
        G6_hub_complete:    { passed: false, checked_at: null, details: "" }
      },

      metrics: {
        total_sources: 0,
        total_artifacts: 0,
        total_notebooks: 0,
        pipeline_duration_minutes: 0
      }
    }' > "$state_path"

  nlm_log "INFO" "State initialized: topic='$topic' slug='$slug' mode='$mode'"
  nlm_log "INFO" "State file: $state_path"
}

# ---------------------------------------------------------------------------
# nlm_state_read(field)
# ---------------------------------------------------------------------------
# Read any jq path from the state file. Returns raw jq output.
#
# Usage:
#   nlm_state_read ".topic"
#   nlm_state_read ".dimensions.D1.status"
#   nlm_state_read ".gates.G2_source_yield.passed"
# ---------------------------------------------------------------------------
nlm_state_read() {
  local field="${1:?jq path is required (e.g. .topic)}"
  local state_path
  state_path="$(nlm_get_state_path)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  jq -r "$field" "$state_path"
}

# ---------------------------------------------------------------------------
# nlm_state_update(field, value)
# ---------------------------------------------------------------------------
# Update a single field in the state file and refresh updated_at.
# Value is treated as a raw JSON value (string, number, bool, null).
# For string values, wrap in quotes. For booleans/numbers, pass raw.
#
# Usage:
#   nlm_state_update ".status" '"researching"'
#   nlm_state_update ".dimensions.D1.task_id" '"abc-123"'
#   nlm_state_update ".dimensions.D1.source_count" '42'
#   nlm_state_update ".gates.G1_research_launch.passed" 'true'
# ---------------------------------------------------------------------------
nlm_state_update() {
  local field="${1:?jq path is required}"
  local value="${2:?value is required}"
  local state_path
  state_path="$(nlm_get_state_path)"
  local now
  now="$(nlm_now_iso)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  local tmp="${state_path}.tmp"
  jq "${field} = ${value} | .updated_at = \"${now}\"" "$state_path" > "$tmp" \
    && mv "$tmp" "$state_path"

  nlm_log "INFO" "State updated: ${field} = ${value}"
}

# ---------------------------------------------------------------------------
# nlm_state_checkpoint(phase, detail)
# ---------------------------------------------------------------------------
# Append a timestamped checkpoint entry to the checkpoints array.
#
# Usage:
#   nlm_state_checkpoint "Phase 0: Preparation" "Hub notebook created: uuid-here"
#   nlm_state_checkpoint "Phase 1: Genesis" "D1 research launched: task-uuid"
# ---------------------------------------------------------------------------
nlm_state_checkpoint() {
  local phase="${1:?phase name is required}"
  local detail="${2:?detail message is required}"
  local state_path
  state_path="$(nlm_get_state_path)"
  local now
  now="$(nlm_now_iso)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  local tmp="${state_path}.tmp"
  jq --arg phase "$phase" --arg detail "$detail" --arg ts "$now" \
    '.checkpoints += [{ phase: $phase, timestamp: $ts, detail: $detail }] | .updated_at = $ts' \
    "$state_path" > "$tmp" && mv "$tmp" "$state_path"

  nlm_log "INFO" "Checkpoint: [$phase] $detail"
}

# ---------------------------------------------------------------------------
# nlm_state_validate()
# ---------------------------------------------------------------------------
# Validate the state file: exists, valid JSON, has required top-level fields.
# Returns 0 if valid, 1 if invalid. Prints issues to stderr.
#
# Usage:
#   if nlm_state_validate; then echo "OK"; else echo "INVALID"; fi
# ---------------------------------------------------------------------------
nlm_state_validate() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local errors=0

  # Check file exists
  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    return 1
  fi

  # Check valid JSON
  if ! jq empty "$state_path" 2>/dev/null; then
    nlm_log "ERROR" "State file is not valid JSON"
    return 1
  fi

  # Check required top-level fields
  local required_fields=("version" "topic" "slug" "status" "dimensions" "levels" "hub")
  for field in "${required_fields[@]}"; do
    local val
    val="$(jq -r ".${field} // empty" "$state_path")"
    if [[ -z "$val" ]]; then
      nlm_log "ERROR" "Missing required field: $field"
      ((errors++))
    fi
  done

  # Check all 7 dimensions exist
  for d in "${NLM_DIMENSIONS[@]}"; do
    local exists
    exists="$(jq -r ".dimensions.${d} // empty" "$state_path")"
    if [[ -z "$exists" ]]; then
      nlm_log "ERROR" "Missing dimension: $d"
      ((errors++))
    fi
  done

  # Check all 3 levels exist
  for l in "${NLM_LEVELS[@]}"; do
    local exists
    exists="$(jq -r ".levels.${l} // empty" "$state_path")"
    if [[ -z "$exists" ]]; then
      nlm_log "ERROR" "Missing level: $l"
      ((errors++))
    fi
  done

  if [[ $errors -gt 0 ]]; then
    nlm_log "ERROR" "Validation failed with $errors error(s)"
    return 1
  fi

  nlm_log "INFO" "State validation passed"
  return 0
}

# ---------------------------------------------------------------------------
# Main: CLI dispatch
# ---------------------------------------------------------------------------
# When called directly (not sourced), dispatch subcommands.
#
# Usage:
#   bash nlm-state.sh init "Topic Name" standard
#   bash nlm-state.sh read .dimensions.D1.status
#   bash nlm-state.sh update .status '"researching"'
#   bash nlm-state.sh checkpoint "Phase 1" "Detail here"
#   bash nlm-state.sh validate
#   bash nlm-state.sh slugify "Topic Name Here"
# ---------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init)
      nlm_state_init "$@"
      ;;
    read)
      nlm_state_read "$@"
      ;;
    update)
      nlm_state_update "$@"
      ;;
    checkpoint)
      nlm_state_checkpoint "$@"
      ;;
    validate)
      nlm_state_validate
      ;;
    slugify)
      nlm_slugify "$@"
      ;;
    help|*)
      echo "Usage: bash nlm-state.sh <command> [args]"
      echo ""
      echo "Commands:"
      echo "  init <topic> [mode]        Create initial state (mode: standard|express|deep)"
      echo "  read <jq-path>             Read a field (e.g. .dimensions.D1.status)"
      echo "  update <jq-path> <value>   Update a field (value is raw JSON)"
      echo "  checkpoint <phase> <detail> Append a checkpoint entry"
      echo "  validate                   Validate state file integrity"
      echo "  slugify <topic>            Generate slug from topic string"
      ;;
  esac
fi
