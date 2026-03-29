#!/usr/bin/env bash
# sdd-workspace.sh — Per-task workspace session management
#
# Creates ISO-dated workspace folders isolating inputs, RAG memory, logs,
# and tasklog per interaction/task. Sessions integrate with the ALM dashboard,
# heartbeat nudges, and workspace-aware RAG routing.
#
# Design decisions:
#   - ISO date prefix (yyyy-mm-dd) for chronological filesystem sorting
#   - session.json uses python3 for safe JSON edits (no shell interpolation)
#   - Counters (inputCount, ragCount) are refreshed on every status query,
#     not maintained as running totals, to prevent drift
#   - Exit 0 always — script may run in hooks context where non-zero kills the pipeline
#
# Limits:
#   - One active workspace at a time (tracked via .specify/active-workspace)
#   - Task names > 40 chars are truncated in the slug (date prefix=11, total<=51)
#   - No nested workspace sessions (flat workspace/ directory)
#   - Archive is soft-delete (status flag only); use rm -rf for hard delete
#
# Usage:
#   bash scripts/sdd-workspace.sh create <task-name> [project-path]
#   bash scripts/sdd-workspace.sh list [project-path]
#   bash scripts/sdd-workspace.sh select <session-name> [project-path]
#   bash scripts/sdd-workspace.sh current [project-path]
#   bash scripts/sdd-workspace.sh archive <session-name> [project-path]
#   bash scripts/sdd-workspace.sh done <session-name> [project-path]
#   bash scripts/sdd-workspace.sh stats [project-path]   # aggregate counts

set -uo pipefail

SUBCOMMAND="${1:-help}"
ARG="${2:-}"
PROJECT_PATH="${3:-.}"

# Colors (Neo-Swiss palette)
GOLD='\033[38;5;220m'
BLUE='\033[38;5;33m'
WHITE='\033[1;37m'
MUTED='\033[38;5;245m'
RED='\033[38;5;196m'
RESET='\033[0m'
BOLD='\033[1m'

SPECIFY_DIR="$PROJECT_PATH/.specify"
WORKSPACE_DIR="$PROJECT_PATH/workspace"
ACTIVE_WS_FILE="$SPECIFY_DIR/active-workspace"

# ── Helpers ──

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | \
    sed 's/[áàäâ]/a/g; s/[éèëê]/e/g; s/[íìïî]/i/g; s/[óòöô]/o/g; s/[úùüû]/u/g; s/ñ/n/g' | \
    sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g; s/^-//; s/-$//' | \
    cut -c1-40
}

iso_date() { date +"%Y-%m-%d" 2>/dev/null || echo "unknown"; }
iso_timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown"; }

ensure_specify() {
  if [ ! -d "$SPECIFY_DIR" ]; then
    echo -e "${RED}Not an SDD project${RESET} — run /sdd:init first"
    exit 0
  fi
}

get_active() {
  [ -f "$ACTIVE_WS_FILE" ] && cat "$ACTIVE_WS_FILE" 2>/dev/null | tr -d '\n'
}

# Live-count inputs, RAG files, tasklog entries for a session directory.
# Avoids stale counters — always reads filesystem truth.
count_session() {
  local dir="$1"
  local inputs=0 rags=0 tasks=0 logs=0
  [ -d "$dir/inputs" ] && inputs=$(find "$dir/inputs" -maxdepth 1 -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' ')
  [ -d "$dir/rag" ] && rags=$(find "$dir/rag" -maxdepth 1 -name "rag-memory-of-*" 2>/dev/null | wc -l | tr -d ' ')
  [ -f "$dir/tasklog.md" ] && tasks=$(grep -c '^|[[:space:]]*TL-' "$dir/tasklog.md" 2>/dev/null || echo 0)
  [ -f "$dir/logs/session-log.json" ] && logs=$(grep -c '"timestamp"' "$dir/logs/session-log.json" 2>/dev/null || echo 0)
  echo "$inputs $rags $tasks $logs"
}

# Read status from session.json via grep (no python dependency for reads)
read_status() {
  local json="$1/session.json"
  [ -f "$json" ] && grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$json" 2>/dev/null | head -1 | sed 's/.*"status"[[:space:]]*:[[:space:]]*"//;s/"//' || echo "unknown"
}

# Update session.json field(s) atomically via python3.
# Args: <file> key1=val1 key2=val2 ...
# Uses JSON-safe env var passing — no exec() or string interpolation.
update_session_json() {
  local session_json="$1"
  shift
  [ -f "$session_json" ] || return 0

  # Encode updates as JSON object for safe transport
  local updates_json="{"
  local first=true
  for pair in "$@"; do
    local key="${pair%%=*}"
    local val="${pair#*=}"
    $first || updates_json="${updates_json},"
    updates_json="${updates_json}\"${key}\":\"${val}\""
    first=false
  done
  updates_json="${updates_json}}"

  SDD_FILE="$session_json" SDD_UPDATES="$updates_json" python3 -c '
import json, os
f = os.environ["SDD_FILE"]
try:
    with open(f, "r") as fh: data = json.load(fh)
    updates = json.loads(os.environ["SDD_UPDATES"])
    data.update(updates)
    tmp = f + ".tmp"
    with open(tmp, "w") as fh: json.dump(data, fh, indent=2)
    os.rename(tmp, f)
except Exception:
    pass
' 2>/dev/null || true
}

# ── create ──

cmd_create() {
  local task_name="$1"
  if [ -z "$task_name" ]; then
    echo -e "${RED}Usage:${RESET} sdd-workspace.sh create <task-name>"
    echo -e "${MUTED}  Example: bash scripts/sdd-workspace.sh create \"implement auth flow\"${RESET}"
    exit 0
  fi

  ensure_specify

  local slug
  slug=$(slugify "$task_name")
  if [ -z "$slug" ]; then
    echo -e "${RED}Invalid task name${RESET} — must contain at least one alphanumeric character"
    exit 0
  fi

  local date_prefix
  date_prefix=$(iso_date)
  local session_id="${date_prefix}-${slug}"
  local session_dir="$WORKSPACE_DIR/$session_id"

  # Edge case: same task name on same day → reuse existing
  if [ -d "$session_dir" ]; then
    echo -e "${GOLD}Workspace already exists:${RESET} $session_id"
    echo -e "${MUTED}Selecting as active workspace${RESET}"
    echo "$session_id" > "$ACTIVE_WS_FILE.tmp" && mv "$ACTIVE_WS_FILE.tmp" "$ACTIVE_WS_FILE"
    exit 0
  fi

  # Create structure
  mkdir -p "$session_dir/inputs"
  mkdir -p "$session_dir/rag"
  mkdir -p "$session_dir/logs"

  # Initialize session.json with creation metadata
  local now
  now=$(iso_timestamp)
  cat > "$session_dir/session.json" << EOJSON
{
  "schemaVersion": 1,
  "taskName": "$task_name",
  "sessionId": "$session_id",
  "created": "$now",
  "status": "active",
  "inputCount": 0,
  "ragCount": 0,
  "lastActivity": "$now",
  "parentFeature": null,
  "tags": []
}
EOJSON

  # Initialize tasklog.md with standard table
  cat > "$session_dir/tasklog.md" << 'EOMD'
# Task Log

> Tracks discrete work items within this workspace session.
> Add rows manually or via `/sdd:workspace log`.

| ID | Task | Status | Owner | Opened | Closed |
|----|------|--------|-------|--------|--------|
EOMD

  # Initialize rag-index.json and session log
  echo '[]' > "$session_dir/rag-index.json"
  echo '{"events":[]}' > "$session_dir/logs/session-log.json"

  # Create .gitkeep in inputs/ so git tracks empty dir
  touch "$session_dir/inputs/.gitkeep"

  # Set as active (atomic write)
  echo "$session_id" > "$ACTIVE_WS_FILE.tmp" && mv "$ACTIVE_WS_FILE.tmp" "$ACTIVE_WS_FILE"

  echo -e "${GOLD}Workspace created:${RESET} ${WHITE}$session_id${RESET}"
  echo -e "${MUTED}  inputs/    — Drop raw inputs here (auto-indexed)${RESET}"
  echo -e "${MUTED}  rag/       — RAG files routed here while active${RESET}"
  echo -e "${MUTED}  logs/      — Dual-written session events${RESET}"
  echo -e "${MUTED}  tasklog.md — Work item tracking${RESET}"
  echo -e "${BLUE}Active workspace set.${RESET} RAG capture and logs now route here."
}

# ── list ──

cmd_list() {
  ensure_specify

  if [ ! -d "$WORKSPACE_DIR" ] || [ -z "$(ls -d "$WORKSPACE_DIR"/*/ 2>/dev/null)" ]; then
    echo -e "${MUTED}No workspace sessions yet.${RESET}"
    echo -e "Create one: ${GOLD}/sdd:workspace create my-task${RESET}"
    exit 0
  fi

  local active
  active=$(get_active)
  local count=0
  local total_inputs=0 total_rags=0 total_tasks=0

  echo -e "${GOLD}${BOLD}Workspace Sessions${RESET}"
  echo -e "${MUTED}──────────────────────────────────────────────────────────────${RESET}"
  printf "${MUTED}%-3s %-34s %-10s %5s %5s %5s %5s${RESET}\n" "" "Session" "Status" "In" "RAG" "Tasks" "Logs"
  echo -e "${MUTED}──────────────────────────────────────────────────────────────${RESET}"

  for dir in "$WORKSPACE_DIR"/*/; do
    [ -d "$dir" ] || continue
    local name
    name=$(basename "$dir")
    [[ "$name" == "." || "$name" == ".." || "$name" == .* ]] && continue

    local status
    status=$(read_status "$dir")

    # Live-count (filesystem truth, not cached session.json)
    local counts
    counts=$(count_session "$dir")
    local inputs rags tasks logs
    read -r inputs rags tasks logs <<< "$counts"

    total_inputs=$((total_inputs + inputs))
    total_rags=$((total_rags + rags))
    total_tasks=$((total_tasks + tasks))

    # Active indicator
    local indicator="  "
    [ "$name" = "$active" ] && indicator="${GOLD}▸ ${RESET}"

    # Status color
    local status_display="$status"
    case "$status" in
      active)   status_display="${GOLD}active${RESET}" ;;
      archived) status_display="${MUTED}archived${RESET}" ;;
      done)     status_display="${BLUE}done${RESET}" ;;
    esac

    printf "${WHITE}${indicator}%-34s${RESET} %-10b %5s %5s %5s %5s\n" "$name" "$status_display" "$inputs" "$rags" "$tasks" "$logs"
    count=$((count + 1))
  done

  echo -e "${MUTED}──────────────────────────────────────────────────────────────${RESET}"
  printf "${MUTED}%s session(s) — Totals: %s inputs, %s RAG, %s tasks${RESET}\n" "$count" "$total_inputs" "$total_rags" "$total_tasks"
}

# ── select ──

cmd_select() {
  local name="$1"
  if [ -z "$name" ]; then
    echo -e "${RED}Usage:${RESET} sdd-workspace.sh select <session-name>"
    echo -e "${MUTED}  Tip: use partial match — e.g. 'auth' matches '2026-03-25-auth-flow'${RESET}"
    exit 0
  fi

  ensure_specify

  # Exact match first
  if [ -d "$WORKSPACE_DIR/$name" ]; then
    echo "$name" > "$ACTIVE_WS_FILE.tmp" && mv "$ACTIVE_WS_FILE.tmp" "$ACTIVE_WS_FILE"
    echo -e "${BLUE}Active workspace:${RESET} ${WHITE}$name${RESET}"
    exit 0
  fi

  # Partial match: find first session containing the query
  local match=""
  for dir in "$WORKSPACE_DIR"/*/; do
    [ -d "$dir" ] || continue
    local base
    base=$(basename "$dir")
    if echo "$base" | grep -qi "$name"; then
      match="$base"
      break
    fi
  done

  if [ -n "$match" ]; then
    echo "$match" > "$ACTIVE_WS_FILE"
    echo -e "${BLUE}Active workspace:${RESET} ${WHITE}$match${RESET} ${MUTED}(matched from '$name')${RESET}"
  else
    echo -e "${RED}Session not found:${RESET} $name"
    echo -e "Run ${GOLD}/sdd:workspace list${RESET} to see available sessions."
  fi
}

# ── current ──

cmd_current() {
  ensure_specify

  local active
  active=$(get_active)

  if [ -z "$active" ]; then
    echo -e "${MUTED}No active workspace.${RESET}"
    echo -e "Create one: ${GOLD}/sdd:workspace create my-task${RESET}"
  elif [ ! -d "$WORKSPACE_DIR/$active" ]; then
    echo -e "${RED}Active workspace missing:${RESET} ${WHITE}$active${RESET}"
    echo -e "${MUTED}The folder was deleted. Run /sdd:workspace create or /sdd:workspace select.${RESET}"
    echo "" > "$ACTIVE_WS_FILE.tmp" && mv "$ACTIVE_WS_FILE.tmp" "$ACTIVE_WS_FILE"
  else
    local counts
    counts=$(count_session "$WORKSPACE_DIR/$active")
    local inputs rags tasks logs
    read -r inputs rags tasks logs <<< "$counts"
    echo -e "${BLUE}Active workspace:${RESET} ${WHITE}$active${RESET}"
    echo -e "${MUTED}  Inputs: $inputs | RAG: $rags | Tasks: $tasks | Log events: $logs${RESET}"
  fi
}

# ── archive / done ──

cmd_set_status() {
  local new_status="$1"
  local name="$2"
  if [ -z "$name" ]; then
    echo -e "${RED}Usage:${RESET} sdd-workspace.sh $new_status <session-name>"
    exit 0
  fi

  ensure_specify

  local session_dir="$WORKSPACE_DIR/$name"
  if [ ! -d "$session_dir" ]; then
    echo -e "${RED}Session not found:${RESET} $name"
    exit 0
  fi

  local now
  now=$(iso_timestamp)
  update_session_json "$session_dir/session.json" "status=$new_status" "lastActivity=$now"

  # Clear active if this was the active workspace
  local active
  active=$(get_active)
  if [ "$active" = "$name" ]; then
    echo "" > "$ACTIVE_WS_FILE.tmp" && mv "$ACTIVE_WS_FILE.tmp" "$ACTIVE_WS_FILE"
  fi

  local label=""
  case "$new_status" in
    archived) label="${MUTED}Archived${RESET}" ;;
    done)     label="${BLUE}Done${RESET}" ;;
  esac
  echo -e "$label: ${WHITE}$name${RESET}"
}

# ── stats (aggregate) ──

cmd_stats() {
  ensure_specify

  if [ ! -d "$WORKSPACE_DIR" ]; then
    echo -e "${MUTED}No workspace sessions.${RESET}"
    exit 0
  fi

  local total=0 active=0 archived=0 done=0
  local total_inputs=0 total_rags=0 total_tasks=0

  for dir in "$WORKSPACE_DIR"/*/; do
    [ -d "$dir" ] || continue
    local name
    name=$(basename "$dir")
    [[ "$name" == .* ]] && continue

    total=$((total + 1))
    local status
    status=$(read_status "$dir")
    case "$status" in
      active) active=$((active + 1)) ;;
      archived) archived=$((archived + 1)) ;;
      done) done=$((done + 1)) ;;
    esac

    local counts
    counts=$(count_session "$dir")
    local i r t l
    read -r i r t l <<< "$counts"
    total_inputs=$((total_inputs + i))
    total_rags=$((total_rags + r))
    total_tasks=$((total_tasks + t))
  done

  echo -e "${GOLD}${BOLD}Workspace Stats${RESET}"
  echo -e "  Sessions:  ${WHITE}$total${RESET} (active: $active, done: $done, archived: $archived)"
  echo -e "  Inputs:    ${WHITE}$total_inputs${RESET}"
  echo -e "  RAG files: ${WHITE}$total_rags${RESET}"
  echo -e "  Tasks:     ${WHITE}$total_tasks${RESET}"
}

# ── help ──

cmd_help() {
  echo -e "${GOLD}${BOLD}SDD Workspace Sessions${RESET}"
  echo ""
  echo -e "  ${WHITE}create${RESET} <name>    Create new session (sets as active)"
  echo -e "  ${WHITE}list${RESET}             List sessions with live-counted stats"
  echo -e "  ${WHITE}select${RESET} <name>    Set active (supports partial match)"
  echo -e "  ${WHITE}current${RESET}          Show active workspace + stats"
  echo -e "  ${WHITE}done${RESET} <name>      Mark session as done"
  echo -e "  ${WHITE}archive${RESET} <name>   Archive session (soft-delete)"
  echo -e "  ${WHITE}stats${RESET}            Aggregate counts across all sessions"
  echo ""
  echo -e "  ${MUTED}Active workspace routes RAG capture and logs automatically.${RESET}"
  echo -e "  ${MUTED}Dashboard Workspace page shows session cards.${RESET}"
}

# ── Dispatch ──

case "$SUBCOMMAND" in
  create)  cmd_create "$ARG" ;;
  list|ls) cmd_list ;;
  select|use) cmd_select "$ARG" ;;
  current) cmd_current ;;
  done)    cmd_set_status "done" "$ARG" ;;
  archive) cmd_set_status "archived" "$ARG" ;;
  stats)   cmd_stats ;;
  help|--help|-h) cmd_help ;;
  *)
    echo -e "${RED}Unknown subcommand:${RESET} $SUBCOMMAND"
    cmd_help
    ;;
esac

exit 0
