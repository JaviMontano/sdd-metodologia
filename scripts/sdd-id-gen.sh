#!/usr/bin/env bash
# sdd-id-gen.sh — Deterministic ID generation for SDD artifacts
# Replaces probabilistic LLM ID assignment with monotonic counters.
#
# Usage:
#   bash scripts/sdd-id-gen.sh <type> [count] [project-path]
#   type: FR | SC | US | TS | T | BUG | CHK
#   count: number of IDs to generate (default: 1)
#
# Output (stdout): FR-001 FR-002 FR-003 (space-separated)
# Side effect: updates .specify/id-counters.json atomically
#
# Features:
#   - Monotonic: IDs never reused, even after feature deletion
#   - Per-feature allocation tracking
#   - Backward compat: initializes from existing artifact scan
#   - Concurrency safe: mkdir-based lock

set -eo pipefail

TYPE="${1:-}"
COUNT="${2:-1}"
PROJECT_PATH="${3:-.}"

SPECIFY_DIR="$PROJECT_PATH/.specify"
COUNTER_FILE="$SPECIFY_DIR/id-counters.json"
LOCK_DIR="$SPECIFY_DIR/.id-lock"

VALID_TYPES="FR SC US TS T BUG CHK"

# ─── Validation ───
if [[ -z "$TYPE" ]] || ! echo "$VALID_TYPES" | grep -qw "$TYPE"; then
  echo "Usage: sdd-id-gen.sh <FR|SC|US|TS|T|BUG|CHK> [count] [project-path]" >&2
  exit 1
fi

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [[ "$COUNT" -lt 1 ]]; then
  echo "Error: count must be a positive integer" >&2
  exit 1
fi

mkdir -p "$SPECIFY_DIR"

# ─── Initialize counters if missing ───
init_counters() {
  if [[ -f "$COUNTER_FILE" ]]; then
    return
  fi

  # Scan existing artifacts for highest IDs
  local max_fr=0 max_sc=0 max_us=0 max_ts=0 max_t=0 max_bug=0

  for f in "$PROJECT_PATH"/specs/*/spec.md; do
    [[ -f "$f" ]] || continue
    local n
    n=$(grep -oE 'FR-([0-9]+)' "$f" 2>/dev/null | sed 's/FR-//' | sort -n | tail -1 || true)
    [[ -n "$n" ]] && [[ "$((10#$n))" -gt "$max_fr" ]] && max_fr=$((10#$n)) || true
    n=$(grep -oE 'SC-([0-9]+)' "$f" 2>/dev/null | sed 's/SC-//' | sort -n | tail -1 || true)
    [[ -n "$n" ]] && [[ "$((10#$n))" -gt "$max_sc" ]] && max_sc=$((10#$n)) || true
    n=$(grep -oE 'US-([0-9]+)' "$f" 2>/dev/null | sed 's/US-//' | sort -n | tail -1 || true)
    [[ -n "$n" ]] && [[ "$((10#$n))" -gt "$max_us" ]] && max_us=$((10#$n)) || true
  done

  for f in "$PROJECT_PATH"/specs/*/tests/features/*.feature; do
    [[ -f "$f" ]] || continue
    local n
    n=$(grep -oE 'TS-([0-9]+)' "$f" 2>/dev/null | sed 's/TS-//' | sort -n | tail -1 || true)
    [[ -n "$n" ]] && [[ "$((10#$n))" -gt "$max_ts" ]] && max_ts=$((10#$n)) || true
  done

  for f in "$PROJECT_PATH"/specs/*/tasks.md; do
    [[ -f "$f" ]] || continue
    local n
    n=$(grep -oE 'T-([0-9]+)' "$f" 2>/dev/null | sed 's/T-//' | sort -n | tail -1 || true)
    [[ -n "$n" ]] && [[ "$((10#$n))" -gt "$max_t" ]] && max_t=$((10#$n)) || true
  done

  python3 -c "
import json
data = {
    'version': '1.0.0',
    'counters': {
        'FR': $max_fr, 'SC': $max_sc, 'US': $max_us,
        'TS': $max_ts, 'T': $max_t, 'BUG': 0, 'CHK': 0
    },
    'allocations': {},
    'lastUpdated': ''
}
with open('$COUNTER_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
}

# ─── Acquire lock ───
acquire_lock() {
  local attempts=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    attempts=$((attempts + 1))
    if [[ $attempts -gt 20 ]]; then
      # Stale lock (>2s old) — force remove
      if [[ -d "$LOCK_DIR" ]]; then
        local age
        age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || stat -c %Y "$LOCK_DIR" 2>/dev/null || echo "0") ))
        if [[ $age -gt 2 ]]; then
          rmdir "$LOCK_DIR" 2>/dev/null
          continue
        fi
      fi
      echo "Error: could not acquire ID lock" >&2
      exit 1
    fi
    sleep 0.1
  done
}

release_lock() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

# ─── Generate IDs ───
init_counters

acquire_lock
trap release_lock EXIT

# Read current counter, allocate, write back
RESULT=$(python3 -c "
import json, os
from datetime import datetime

f = '$COUNTER_FILE'
id_type = '$TYPE'
count = $COUNT

with open(f) as fh:
    data = json.load(fh)

current = data['counters'].get(id_type, 0)
ids = []
for i in range(count):
    current += 1
    ids.append(f'{id_type}-{current:03d}')

data['counters'][id_type] = current
data['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'

# Track allocation for active feature
active_feature_file = os.path.join('$SPECIFY_DIR', 'active-feature')
if os.path.exists(active_feature_file):
    feature = open(active_feature_file).read().strip()
    if feature:
        alloc = data.setdefault('allocations', {}).setdefault(feature, {})
        existing = alloc.get(id_type, [0, 0])
        if existing[0] == 0:
            existing[0] = current - count + 1
        existing[1] = current
        alloc[id_type] = existing

tmp = f + '.tmp'
with open(tmp, 'w') as fh:
    json.dump(data, fh, indent=2)
os.rename(tmp, f)

print(' '.join(ids))
" 2>/dev/null)

release_lock
trap - EXIT

echo "$RESULT"
