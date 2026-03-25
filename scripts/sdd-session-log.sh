#!/usr/bin/env bash
# sdd-session-log.sh — Append events to .specify/session-log.json
# Dual-writes to workspace log when active. MUST exit 0 always.

TYPE="${1:-}"
DESCRIPTION="${2:-}"
COMMAND="${3:-}"
PROJECT_PATH="${4:-.}"

[ -z "$TYPE" ] && exit 0
[ -d "$PROJECT_PATH/.specify" ] || exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")
[ -z "$DESCRIPTION" ] && DESCRIPTION="Hook: $TYPE"

# Append a JSON event to a log file (atomic write via tmp + rename).
# Uses env vars to avoid shell interpolation in python.
append_event() {
  local target="$1"
  [ -f "$target" ] || echo '{"events":[]}' > "$target"
  SDD_LOG_FILE="$target" \
  SDD_TIMESTAMP="$TIMESTAMP" \
  SDD_TYPE="$TYPE" \
  SDD_DESC="$DESCRIPTION" \
  SDD_CMD="$COMMAND" \
  python3 -c '
import json, os
f = os.environ["SDD_LOG_FILE"]
try:
    with open(f, "r") as fh: data = json.load(fh)
except Exception:
    data = {"events": []}
if "events" not in data: data["events"] = []
event = {"timestamp": os.environ["SDD_TIMESTAMP"], "type": os.environ["SDD_TYPE"], "description": os.environ["SDD_DESC"]}
cmd = os.environ.get("SDD_CMD", "")
if cmd: event["command"] = cmd
data["events"].append(event)
data["events"] = data["events"][-200:]
tmp = f + ".tmp"
with open(tmp, "w") as fh: json.dump(data, fh, indent=2)
os.rename(tmp, f)
' 2>/dev/null || true
}

# Global log (always)
append_event "$PROJECT_PATH/.specify/session-log.json"

# Workspace log (if active workspace exists)
ACTIVE_WS_FILE="$PROJECT_PATH/.specify/active-workspace"
if [ -f "$ACTIVE_WS_FILE" ]; then
  ACTIVE_WS=$(cat "$ACTIVE_WS_FILE" 2>/dev/null | tr -d '\n')
  if [ -n "$ACTIVE_WS" ] && [ -d "$PROJECT_PATH/workspace/$ACTIVE_WS/logs" ]; then
    append_event "$PROJECT_PATH/workspace/$ACTIVE_WS/logs/session-log.json"
  fi
fi

exit 0
