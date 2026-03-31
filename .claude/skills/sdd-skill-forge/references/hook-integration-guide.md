# Hook Integration Guide — SDD Skills

How to integrate SDD skills with the Claude Code hook system for ambient intelligence. [EXPLICIT]

## Hook Lifecycle

```
SessionStart → UserPromptSubmit → [Tool Use] → PostToolUse → ... → PreCompact
```

| Hook Point | Fires When | Max Time | Use For |
|-----------|-----------|----------|---------|
| SessionStart | New session or /clear | 10s | Context restore, feature detection |
| UserPromptSubmit | Every user message | 5s (target <100ms) | Health monitoring, drift detection |
| PostToolUse | After Write/Edit tools | 5s | Audit logging, validation triggers |
| PreCompact | Before context compression | 5s | State snapshots, log preservation |

## Hook Configuration

Hooks are defined in `hooks/hooks.json`: [EXPLICIT]

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "bash path/to/script.sh",
        "timeout": 5
      }]
    }],
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "bash path/to/audit.sh post-write",
        "timeout": 5
      }]
    }]
  }
}
```

The `matcher` field is a regex against tool names. Empty string matches all. [EXPLICIT]

## Script Conventions for Hooks

### Performance Requirements

| Hook Type | Target | Hard Limit |
|-----------|--------|-----------|
| UserPromptSubmit | < 100ms | 5s timeout |
| PostToolUse | < 500ms | 5s timeout |
| SessionStart | < 2s | 10s timeout |
| PreCompact | < 500ms | 5s timeout |

### Mandatory Patterns

```bash
#!/usr/bin/env bash
# Always exit 0 — never block the hook pipeline
set -euo pipefail
trap 'exit 0' ERR  # Catch errors, still exit clean

# Fast path: skip if not an SDD project
[[ ! -d ".specify" ]] && exit 0

# Suppression check (grep, not jq — performance critical)
STATE_FILE=".specify/sentinel-state.json"
if [[ -f "$STATE_FILE" ]]; then
    SUPPRESSED=$(grep -o '"suppressedUntil":"[^"]*"' "$STATE_FILE" | cut -d'"' -f4)
    # Compare timestamps...
fi

# Output: single line to stdout (injected as context)
# Empty output = silent (no context injection)
echo "⚡ SDD: findings summary — /sdd:command"
exit 0
```

### Key Rules

1. Always `exit 0` — a failing hook blocks the entire session [EXPLICIT]
2. Use `grep` over `jq` in hot paths — jq adds 50-200ms [EXPLICIT]
3. Use atomic writes (temp file + mv) for state files [EXPLICIT]
4. Bash 3.2 compatible (macOS default): no associative arrays, no mapfile [EXPLICIT]
5. Dual output: `--json` for machine, human-readable by default [EXPLICIT]
6. State files in `.specify/` (sentinel-state.json, session-log.json, health-history.json) [EXPLICIT]

## Sentinel Pattern

The sentinel pattern is SDD's ambient intelligence architecture: [EXPLICIT]

```
Heartbeat (per-prompt, <100ms)
  ├── Fast path: check suppression timestamp
  ├── Scan: stale artifacts (7-day threshold)
  ├── Scan: missing critical files
  ├── Scan: health regression (>10 point drop)
  └── Output: 1-line summary or silence

Sentinel (on-demand, full cycle)
  ├── PERCEIVE: collect all project state
  ├── DECIDE: score severity, rank priorities
  ├── ACT: generate recommendations
  └── Output: branded report or JSON
```

Suppression: 45-90 minutes of quiet after a clean sentinel run. [EXPLICIT]

## Adding Hooks to a New Skill

1. Generate the hook script in `scripts/bash/`
2. Test with: `time bash scripts/bash/hook-script.sh` (must be < target time)
3. Document the hook configuration entry in the skill's SKILL.md
4. Provide the `hooks.json` snippet for manual registration
5. Never auto-modify `hooks.json` — user must approve hook changes [EXPLICIT]
