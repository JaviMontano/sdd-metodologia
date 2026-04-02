#!/usr/bin/env bash
# =============================================================================
# nlm-gates.sh — Quality gates for NLM for Learning pipeline
# =============================================================================
# Six gates that validate pipeline integrity at critical checkpoints.
# Each gate returns 0 (pass) or 1 (fail) and prints a diagnostic report.
#
# Gates:
#   G1: Research Launch  — All 7 task_ids are non-null
#   G2: Source Yield      — Per-dimension source count thresholds
#   G3: Total Sources     — Aggregate source count >= 100
#   G4: Tutor Config      — All 3 levels have chat_configured == true
#   G5: Artifacts         — Per-level artifact count meets minimums
#   G6: Hub Complete      — Hub notes (index, diagnosis, study_path) non-null
#
# Usage (as CLI):
#   bash nlm-gates.sh report       # Run all 6 gates, print summary
#   bash nlm-gates.sh g1           # Run gate 1 only
#   bash nlm-gates.sh g2           # Run gate 2 only
#   bash nlm-gates.sh g3           # etc.
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/nlm-common.sh"
source "$SCRIPT_DIR/nlm-state.sh"

nlm_require_jq

# ---------------------------------------------------------------------------
# nlm_gate_g1() — Research Launch
# ---------------------------------------------------------------------------
# Check all 7 dimensions have a non-null task_id (research was launched).
# Returns 0 if all pass, 1 if any fail.
#
# Usage:
#   if nlm_gate_g1; then echo "G1 PASS"; fi
# ---------------------------------------------------------------------------
nlm_gate_g1() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local failures=0

  echo "--- G1: Research Launch ---"

  for d in "${NLM_DIMENSIONS[@]}"; do
    local task_id
    task_id="$(jq -r ".dimensions.${d}.task_id // \"null\"" "$state_path")"
    if [[ "$task_id" == "null" || -z "$task_id" ]]; then
      echo "  FAIL  ${d}: task_id is null (research not launched)"
      ((failures++))
    else
      echo "  PASS  ${d}: task_id=${task_id:0:12}..."
    fi
  done

  echo ""
  if [[ $failures -eq 0 ]]; then
    echo "  Result: G1 PASS (7/7 researches launched)"
    return 0
  else
    echo "  Result: G1 FAIL ($failures dimension(s) missing task_id)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_g2() — Source Yield
# ---------------------------------------------------------------------------
# Per-dimension source_count thresholds:
#   >= 15   PASS
#   10-14   CONCERNS (warning, still passes)
#   < 10    LOW_YIELD (fails)
#   0       FAIL (critical)
#
# Gate passes if ALL dimensions are >= 10. Prints tiered report.
# Returns 0 if pass, 1 if any dimension < 10.
#
# Usage:
#   nlm_gate_g2
# ---------------------------------------------------------------------------
nlm_gate_g2() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local failures=0
  local concerns=0

  echo "--- G2: Source Yield ---"

  for d in "${NLM_DIMENSIONS[@]}"; do
    local count name tier
    count="$(jq -r ".dimensions.${d}.source_count // 0" "$state_path")"
    name="$(jq -r ".dimensions.${d}.name" "$state_path")"

    if [[ "$count" -ge 15 ]]; then
      tier="PASS"
    elif [[ "$count" -ge 10 ]]; then
      tier="CONCERNS"
      ((concerns++))
    elif [[ "$count" -gt 0 ]]; then
      tier="LOW_YIELD"
      ((failures++))
    else
      tier="FAIL"
      ((failures++))
    fi

    printf "  %-10s %s — %-25s sources=%d\n" "$tier" "$d" "$name" "$count"
  done

  echo ""
  if [[ $failures -eq 0 ]]; then
    if [[ $concerns -gt 0 ]]; then
      echo "  Result: G2 PASS with CONCERNS ($concerns dimension(s) between 10-14 sources)"
    else
      echo "  Result: G2 PASS (all dimensions >= 15 sources)"
    fi
    return 0
  else
    echo "  Result: G2 FAIL ($failures dimension(s) below 10 sources)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_g3() — Total Sources
# ---------------------------------------------------------------------------
# Checks metrics.total_sources >= 100. Warns if 70-99.
# Returns 0 if >= 70 (passes with warning), 1 if < 70.
#
# Usage:
#   nlm_gate_g3
# ---------------------------------------------------------------------------
nlm_gate_g3() {
  local state_path
  state_path="$(nlm_get_state_path)"

  echo "--- G3: Total Sources ---"

  local total
  total="$(jq -r ".metrics.total_sources // 0" "$state_path")"

  echo "  Total sources: $total"

  if [[ "$total" -ge 100 ]]; then
    echo "  Result: G3 PASS (>= 100 sources)"
    return 0
  elif [[ "$total" -ge 70 ]]; then
    echo "  Result: G3 PASS with WARNING (70-99 sources — consider supplementing)"
    return 0
  else
    echo "  Result: G3 FAIL (< 70 sources — insufficient coverage)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_g4() — Tutor Config
# ---------------------------------------------------------------------------
# Check all 3 levels have chat_configured == true.
# Returns 0 if all configured, 1 if any missing.
#
# Usage:
#   nlm_gate_g4
# ---------------------------------------------------------------------------
nlm_gate_g4() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local failures=0

  echo "--- G4: Tutor Config ---"

  for l in "${NLM_LEVELS[@]}"; do
    local configured name
    configured="$(jq -r ".levels.${l}.chat_configured // false" "$state_path")"
    name="$(jq -r ".levels.${l}.name" "$state_path")"

    if [[ "$configured" == "true" ]]; then
      echo "  PASS  ${l}: ${name} — chat configured"
    else
      echo "  FAIL  ${l}: ${name} — chat NOT configured"
      ((failures++))
    fi
  done

  echo ""
  if [[ $failures -eq 0 ]]; then
    echo "  Result: G4 PASS (3/3 levels configured)"
    return 0
  else
    echo "  Result: G4 FAIL ($failures level(s) not configured)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_g5() — Artifacts
# ---------------------------------------------------------------------------
# Per-level artifact count meets minimums:
#   L1 >= 3 artifacts (audio, flashcards, quiz required)
#   L2 >= 4 artifacts (audio, flashcards, quiz, mind_map)
#   L3 >= 4 artifacts (audio, flashcards, quiz, mind_map)
#
# Counts artifacts where status == "completed".
# Returns 0 if all meet minimums, 1 if any fall short.
#
# Usage:
#   nlm_gate_g5
# ---------------------------------------------------------------------------
nlm_gate_g5() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local failures=0

  echo "--- G5: Artifacts ---"

  # Minimum artifacts per level
  local -A minimums
  minimums[L1]=3
  minimums[L2]=4
  minimums[L3]=4

  for l in "${NLM_LEVELS[@]}"; do
    local name completed_count
    name="$(jq -r ".levels.${l}.name" "$state_path")"

    # Count completed artifacts
    completed_count="$(jq "[.levels.${l}.artifacts | to_entries[] | select(.value.status == \"completed\")] | length" "$state_path")"

    local min="${minimums[$l]}"
    local total_artifacts
    total_artifacts="$(jq ".levels.${l}.artifacts | length" "$state_path")"

    if [[ "$completed_count" -ge "$min" ]]; then
      echo "  PASS  ${l}: ${name} — ${completed_count}/${total_artifacts} completed (min: ${min})"
    else
      echo "  FAIL  ${l}: ${name} — ${completed_count}/${total_artifacts} completed (min: ${min})"
      ((failures++))
    fi

    # Show individual artifact status
    local artifacts
    artifacts="$(jq -r ".levels.${l}.artifacts | to_entries[] | \"         \\(.key): \\(.value.status)\"" "$state_path")"
    echo "$artifacts"
  done

  echo ""
  if [[ $failures -eq 0 ]]; then
    echo "  Result: G5 PASS (all levels meet artifact minimums)"
    return 0
  else
    echo "  Result: G5 FAIL ($failures level(s) below artifact minimum)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_g6() — Hub Complete
# ---------------------------------------------------------------------------
# Check hub notes: index, diagnosis, study_path all have non-null note IDs.
# Returns 0 if all present, 1 if any missing.
#
# Usage:
#   nlm_gate_g6
# ---------------------------------------------------------------------------
nlm_gate_g6() {
  local state_path
  state_path="$(nlm_get_state_path)"
  local failures=0

  echo "--- G6: Hub Complete ---"

  local notes=("index" "diagnosis" "study_path")

  for note in "${notes[@]}"; do
    local note_id
    note_id="$(jq -r ".hub.notes.${note} // \"null\"" "$state_path")"

    if [[ "$note_id" == "null" || -z "$note_id" ]]; then
      echo "  FAIL  hub.notes.${note}: missing"
      ((failures++))
    else
      echo "  PASS  hub.notes.${note}: ${note_id:0:12}..."
    fi
  done

  # Also check hub notebook_id
  local hub_id
  hub_id="$(jq -r ".hub.notebook_id // \"null\"" "$state_path")"
  if [[ "$hub_id" == "null" || -z "$hub_id" ]]; then
    echo "  FAIL  hub.notebook_id: missing"
    ((failures++))
  else
    echo "  PASS  hub.notebook_id: ${hub_id:0:12}..."
  fi

  echo ""
  if [[ $failures -eq 0 ]]; then
    echo "  Result: G6 PASS (hub fully configured)"
    return 0
  else
    echo "  Result: G6 FAIL ($failures hub item(s) missing)"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# nlm_gate_report()
# ---------------------------------------------------------------------------
# Run all 6 gates, print a summary table, update state.gates, and exit
# with the count of failures.
#
# Usage:
#   nlm_gate_report
#   # Exit code = number of failed gates (0 = all pass)
# ---------------------------------------------------------------------------
nlm_gate_report() {
  local state_path
  state_path="$(nlm_get_state_path)"

  if [[ ! -f "$state_path" ]]; then
    nlm_log "ERROR" "State file not found: $state_path"
    exit 1
  fi

  echo "================================================================"
  echo "  NLM for Learning — Gate Report"
  echo "  Topic: $(jq -r '.topic' "$state_path")"
  echo "  Mode:  $(jq -r '.mode' "$state_path")"
  echo "================================================================"
  echo ""

  local total_failures=0
  local now
  now="$(nlm_now_iso)"

  # Gate 1
  local g1_result="PASS" g1_detail=""
  if nlm_gate_g1; then
    g1_result="PASS"
  else
    g1_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Gate 2
  local g2_result="PASS"
  if nlm_gate_g2; then
    g2_result="PASS"
  else
    g2_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Gate 3
  local g3_result="PASS"
  if nlm_gate_g3; then
    g3_result="PASS"
  else
    g3_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Gate 4
  local g4_result="PASS"
  if nlm_gate_g4; then
    g4_result="PASS"
  else
    g4_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Gate 5
  local g5_result="PASS"
  if nlm_gate_g5; then
    g5_result="PASS"
  else
    g5_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Gate 6
  local g6_result="PASS"
  if nlm_gate_g6; then
    g6_result="PASS"
  else
    g6_result="FAIL"
    ((total_failures++))
  fi
  echo ""

  # Summary table
  echo "================================================================"
  echo "  SUMMARY"
  echo "================================================================"
  printf "  %-5s %-25s %s\n" "Gate" "Name" "Result"
  printf "  %-5s %-25s %s\n" "----" "----" "------"
  printf "  %-5s %-25s %s\n" "G1" "Research Launch" "$g1_result"
  printf "  %-5s %-25s %s\n" "G2" "Source Yield" "$g2_result"
  printf "  %-5s %-25s %s\n" "G3" "Total Sources" "$g3_result"
  printf "  %-5s %-25s %s\n" "G4" "Tutor Config" "$g4_result"
  printf "  %-5s %-25s %s\n" "G5" "Artifacts" "$g5_result"
  printf "  %-5s %-25s %s\n" "G6" "Hub Complete" "$g6_result"
  echo ""
  echo "  Total: $((6 - total_failures))/6 gates passed"
  echo "================================================================"

  # Update state file with gate results
  local tmp="${state_path}.tmp"
  jq \
    --arg now "$now" \
    --arg g1 "$g1_result" \
    --arg g2 "$g2_result" \
    --arg g3 "$g3_result" \
    --arg g4 "$g4_result" \
    --arg g5 "$g5_result" \
    --arg g6 "$g6_result" \
    '
    .gates.G1_research_launch = { passed: ($g1 == "PASS"), checked_at: $now, details: $g1 } |
    .gates.G2_source_yield    = { passed: ($g2 == "PASS"), checked_at: $now, details: $g2 } |
    .gates.G3_total_sources   = { passed: ($g3 == "PASS"), checked_at: $now, details: $g3 } |
    .gates.G4_tutor_config    = { passed: ($g4 == "PASS"), checked_at: $now, details: $g4 } |
    .gates.G5_artifacts       = { passed: ($g5 == "PASS"), checked_at: $now, details: $g5 } |
    .gates.G6_hub_complete    = { passed: ($g6 == "PASS"), checked_at: $now, details: $g6 } |
    .updated_at = $now
    ' "$state_path" > "$tmp" && mv "$tmp" "$state_path"

  nlm_log "INFO" "Gate report complete: $((6 - total_failures))/6 passed"
  return $total_failures
}

# ---------------------------------------------------------------------------
# Main: CLI dispatch
# ---------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    g1) nlm_gate_g1 ;;
    g2) nlm_gate_g2 ;;
    g3) nlm_gate_g3 ;;
    g4) nlm_gate_g4 ;;
    g5) nlm_gate_g5 ;;
    g6) nlm_gate_g6 ;;
    report) nlm_gate_report ;;
    help|*)
      echo "Usage: bash nlm-gates.sh <command>"
      echo ""
      echo "Commands:"
      echo "  g1       Check G1: Research Launch (all task_ids non-null)"
      echo "  g2       Check G2: Source Yield (per-dimension thresholds)"
      echo "  g3       Check G3: Total Sources (>= 100 aggregate)"
      echo "  g4       Check G4: Tutor Config (chat_configured on all levels)"
      echo "  g5       Check G5: Artifacts (per-level minimums met)"
      echo "  g6       Check G6: Hub Complete (all hub notes present)"
      echo "  report   Run all gates + print summary + update state"
      ;;
  esac
fi
