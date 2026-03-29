#!/usr/bin/env bash
# SDD Heartbeat Lite — Per-prompt ambient intelligence
# Runs via UserPromptSubmit hook. MUST complete < 100ms.
# stdout = context injection (empty if healthy). Exit 0 always.
# Bash 3.2 compatible (macOS default). Zero external deps.

set -uo pipefail
# NOTE: Do NOT use set -e — grep returns exit 1 on no match which kills the script.
# This script MUST always exit 0 (hooks treat non-zero as error).

# ── Config ──
STALE_DAYS=7
CRITICAL_SCORE=40
SUPPRESS_MINUTES=30  # CLR-004: Fixed 30 min suppression (balanced)

# ── Detect project ──
SPECIFY_DIR=".specify"
[ -d "$SPECIFY_DIR" ] || exit 0  # Not an SDD project — silent

# ── Init mode ──
if [ "${1:-}" = "--init" ]; then
  STATE="$SPECIFY_DIR/sentinel-state.json"
  if [ ! -f "$STATE" ]; then
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$STATE" << EOJSON
{
  "enabled": true,
  "lastRun": "$NOW",
  "runCount": 0,
  "intervalMinutes": $SUPPRESS_MINUTES,
  "suppressedUntil": null,
  "findings": [],
  "autoClosedCount": 0
}
EOJSON
    echo "SDD sentinel initialized"
  fi
  exit 0
fi

# ── Check suppression (fast path — grep, no python) ──
STATE="$SPECIFY_DIR/sentinel-state.json"
if [ -f "$STATE" ]; then
  SUPPRESSED_RAW=$(grep -o '"suppressedUntil"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//')
  if [ -n "$SUPPRESSED_RAW" ] && [ "$SUPPRESSED_RAW" != "null" ]; then
    # Compare timestamps (epoch seconds)
    NOW_EPOCH=$(date +%s)
    # Parse ISO date — handle both GNU and BSD date
    if SUP_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$SUPPRESSED_RAW" +%s 2>/dev/null); then
      :
    elif SUP_EPOCH=$(date -d "$SUPPRESSED_RAW" +%s 2>/dev/null); then
      :
    else
      SUP_EPOCH=0
    fi
    [ "$NOW_EPOCH" -lt "$SUP_EPOCH" ] && exit 0  # Suppressed — silent
  fi
fi

# ── Quick scan ──
FINDINGS=0
STALE=0
MISSING=0
HEALTH=""
WS_NUDGE=0

# Stale artifacts — bounded scan (max 50 files, no find)
# Uses stat + epoch comparison for guaranteed < 50ms on any project size
if [ -d "$SPECIFY_DIR" ]; then
  NOW_SEC=$(date +%s)
  STALE_SEC=$((STALE_DAYS * 86400))
  STALE=0
  for f in "$SPECIFY_DIR"/*.md "$SPECIFY_DIR"/*/*.md; do
    [ -f "$f" ] || continue
    STALE=$((STALE + 1))
    [ "$STALE" -gt 50 ] && break  # Bounded — never scan more than 50
    # macOS stat: -f %m (mod time epoch); GNU stat: -c %Y
    MTIME=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo "$NOW_SEC")
    AGE=$((NOW_SEC - MTIME))
    [ "$AGE" -gt "$STALE_SEC" ] || STALE=$((STALE - 1))
  done
  [ "$STALE" -gt 0 ] && FINDINGS=$((FINDINGS + STALE))
fi

# Missing critical files
[ ! -f "CONSTITUTION.md" ] && MISSING=$((MISSING + 1))
[ ! -f "PREMISE.md" ] && MISSING=$((MISSING + 1))
[ ! -f "$SPECIFY_DIR/context.json" ] && MISSING=$((MISSING + 1))
[ "$MISSING" -gt 0 ] && FINDINGS=$((FINDINGS + MISSING))

# Workspace session check (~1ms)
ACTIVE_WS_FILE="$SPECIFY_DIR/active-workspace"
if [ ! -f "$ACTIVE_WS_FILE" ] || [ -z "$(cat "$ACTIVE_WS_FILE" 2>/dev/null | tr -d '\n')" ]; then
  # No active workspace — nudge if this is a real SDD project
  if [ -d "specs" ] || [ -f "CONSTITUTION.md" ]; then
    WS_NUDGE=1
  fi
else
  ACTIVE_WS=$(cat "$ACTIVE_WS_FILE" 2>/dev/null | tr -d '\n')
  if [ -n "$ACTIVE_WS" ] && [ ! -d "workspace/$ACTIVE_WS" ]; then
    MISSING=$((MISSING + 1))  # Active workspace folder missing
    FINDINGS=$((FINDINGS + 1))
  fi
fi

# Health score regression (read last score from health-history.json)
HH="$SPECIFY_DIR/health-history.json"
if [ -f "$HH" ]; then
  # Extract last score via grep — works with both array and object formats
  LAST_SCORE=$(grep -o '"score"[[:space:]]*:[[:space:]]*[0-9]*' "$HH" | tail -1 | grep -o '[0-9]*$')
  if [ -n "$LAST_SCORE" ] && [ "$LAST_SCORE" -lt "$CRITICAL_SCORE" ]; then
    HEALTH="CRITICAL:${LAST_SCORE}"
    FINDINGS=$((FINDINGS + 1))
  fi
fi

# ── Report (single line to minimize context noise) ──
if [ "$FINDINGS" -gt 0 ] || [ "$WS_NUDGE" -gt 0 ]; then
  MSG=""
  [ "$STALE" -gt 0 ] && MSG="${MSG}${STALE} stale"
  [ "$MISSING" -gt 0 ] && { [ -n "$MSG" ] && MSG="${MSG}, "; MSG="${MSG}${MISSING} missing"; }
  [ -n "$HEALTH" ] && { [ -n "$MSG" ] && MSG="${MSG}, "; MSG="${MSG}health:${HEALTH}"; }
  [ "$WS_NUDGE" -gt 0 ] && { [ -n "$MSG" ] && MSG="${MSG} | "; MSG="${MSG}no workspace"; }
  HINT="/sdd:sentinel"
  [ "$WS_NUDGE" -gt 0 ] && [ "$FINDINGS" -eq 0 ] && HINT="/sdd:workspace create <name>"
  echo "⚡ SDD: ${MSG} — ${HINT}"
fi

exit 0
