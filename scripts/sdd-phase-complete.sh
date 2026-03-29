#!/usr/bin/env bash
# sdd-phase-complete.sh — Update pipeline state after phase completion
# Called at the end of each phase command to track progress.
#
# Usage: bash scripts/sdd-phase-complete.sh <phase> [project-path]
#   phase: 00|01|02|03|04|05|06|07|08
#   project-path: defaults to current directory
#
# Updates .specify/context.json:
#   pipeline.currentPhase → next phase
#   pipeline.completedPhases[] += phase
#   pipeline.lastCompleted → timestamp
#   pipeline.lastGateResult → PASS|CONDITIONAL|FAIL (if gate phase)
#
# Exit codes: 0 success, 1 invalid phase, 2 missing context.json

set -euo pipefail

PHASE="${1:-}"
PROJECT_PATH="${2:-.}"
GATE_RESULT="${SDD_GATE_RESULT:-}"
CONTEXT_FILE="$PROJECT_PATH/.specify/context.json"

VALID_PHASES="00 01 02 03 04 05 06 07 08"
PHASE_NAMES="constitution specify plan checklist testify tasks analyze implement issues"

# ─── Validation ───
if [[ -z "$PHASE" ]]; then
  echo "Usage: sdd-phase-complete.sh <phase> [project-path]" >&2
  exit 1
fi

if ! echo "$VALID_PHASES" | grep -qw "$PHASE"; then
  echo "Error: Invalid phase '$PHASE'. Valid: $VALID_PHASES" >&2
  exit 1
fi

if [[ ! -f "$CONTEXT_FILE" ]]; then
  echo "Error: $CONTEXT_FILE not found. Run /sdd:init first." >&2
  exit 2
fi

# ─── Compute next phase ───
PHASE_NUM=$((10#$PHASE))
if [[ $PHASE_NUM -lt 8 ]]; then
  NEXT=$(printf "%02d" $((PHASE_NUM + 1)))
else
  NEXT="done"
fi

# ─── Timestamp ───
if command -v python3 &>/dev/null; then
  TS=$(python3 -c "from datetime import datetime; print(datetime.utcnow().isoformat() + 'Z')")
else
  TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
fi

# ─── Update context.json atomically ───
TEMP_FILE="$CONTEXT_FILE.tmp"

python3 -c "
import json, sys

ctx_path = '$CONTEXT_FILE'
phase = '$PHASE'
next_phase = '$NEXT'
ts = '$TS'
gate_result = '$GATE_RESULT'

with open(ctx_path, 'r') as f:
    ctx = json.load(f)

pipe = ctx.setdefault('pipeline', {})
completed = pipe.setdefault('completedPhases', [])

if phase not in completed:
    completed.append(phase)
    completed.sort()

pipe['currentPhase'] = next_phase
pipe['lastCompleted'] = ts

if gate_result:
    pipe['lastGateResult'] = gate_result

with open('$TEMP_FILE', 'w') as f:
    json.dump(ctx, f, indent=2)
    f.write('\n')
" 2>/dev/null

if [[ -f "$TEMP_FILE" ]]; then
  mv "$TEMP_FILE" "$CONTEXT_FILE"
else
  echo "Warning: Failed to update pipeline state" >&2
  exit 0
fi
