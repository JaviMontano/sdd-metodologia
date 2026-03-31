#!/usr/bin/env bash
# sdd-session-log.sh — Append events to .specify/session-log.json
# Dual-writes to workspace log when active. MUST exit 0 always.
# Uses Python fcntl.flock for cross-platform file locking (macOS + Linux).

TYPE="${1:-}"
DESCRIPTION="${2:-}"
COMMAND="${3:-}"
PROJECT_PATH="${4:-.}"

[ -z "$TYPE" ] && exit 0
[ -d "$PROJECT_PATH/.specify" ] || exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")
[ -z "$DESCRIPTION" ] && DESCRIPTION="Hook: $TYPE"

# Append a JSON event with file locking (fcntl.flock — works on macOS + Linux).
# Atomic write via tmp + rename. Keeps last 200 events.
append_event() {
  local target="$1"
  [ -f "$target" ] || echo '{"events":[]}' > "$target"

  SDD_LOG_FILE="$target" \
  SDD_TIMESTAMP="$TIMESTAMP" \
  SDD_TYPE="$TYPE" \
  SDD_DESC="$DESCRIPTION" \
  SDD_CMD="$COMMAND" \
  python3 -c '
import json, os, fcntl, time

f = os.environ["SDD_LOG_FILE"]
lock_path = f + ".lock"
max_retries = 3

for attempt in range(max_retries):
    try:
        lock_fd = open(lock_path, "w")
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            with open(f, "r") as fh:
                data = json.load(fh)
        except Exception:
            data = {"events": []}
        if "events" not in data:
            data["events"] = []
        event = {
            "timestamp": os.environ["SDD_TIMESTAMP"],
            "type": os.environ["SDD_TYPE"],
            "description": os.environ["SDD_DESC"]
        }
        cmd = os.environ.get("SDD_CMD", "")
        if cmd:
            event["command"] = cmd
        data["events"].append(event)
        data["events"] = data["events"][-200:]
        tmp = f + ".tmp"
        with open(tmp, "w") as fh:
            json.dump(data, fh, indent=2)
        os.rename(tmp, f)
        fcntl.flock(lock_fd, fcntl.LOCK_UN)
        lock_fd.close()
        break
    except (IOError, OSError):
        try:
            lock_fd.close()
        except Exception:
            pass
        if attempt < max_retries - 1:
            time.sleep(0.05 * (attempt + 1))
    except Exception:
        break
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
