# Script Patterns — SDD Skills

Conventions for bash and powershell scripts in SDD skills. [EXPLICIT]

## Bash Script Template

```bash
#!/usr/bin/env bash
# sdd-{action}.sh — {one-line description}
# Part of SDD / Intent Integrity Kit | MIT License
# Usage: bash scripts/bash/sdd-{action}.sh [--json] [args...]

set -euo pipefail

# --- Constants ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/../.."

# --- Compatibility (Bash 3.2 / macOS) ---
# No associative arrays, no mapfile, no readarray
# Use: while IFS= read -r line; do ... done < <(command)

# --- Color Constants (MetodologIA) ---
if [[ -t 1 ]]; then
    GOLD='\033[38;2;255;215;0m'
    BLUE='\033[38;2;19;125;197m'
    WHITE='\033[97m'
    MUTED='\033[90m'
    RED='\033[31m'
    RESET='\033[0m'
else
    GOLD='' BLUE='' WHITE='' MUTED='' RED='' RESET=''
fi

# --- Functions ---
die() { echo -e "${RED}Error: $1${RESET}" >&2; exit 1; }

output_json() {
    cat <<EOF
{
  "status": "${1:-ok}",
  "data": ${2:-null}
}
EOF
}

output_human() {
    echo -e "${GOLD}SDD${RESET} | ${WHITE}$1${RESET}"
    echo -e "${MUTED}$2${RESET}"
}

# --- Main ---
main() {
    local json_mode=false
    [[ "${1:-}" == "--json" ]] && { json_mode=true; shift; }

    # ... implementation ...

    if $json_mode; then
        output_json "ok" '{"result": "value"}'
    else
        output_human "Title" "Description"
    fi
}

main "$@"
```

## Key Conventions

| Convention | Rule | Why |
|-----------|------|-----|
| Shebang | `#!/usr/bin/env bash` | Portable across systems [EXPLICIT] |
| Error handling | `set -euo pipefail` | Fail fast on errors [EXPLICIT] |
| Bash version | 3.2 compatible | macOS ships 3.2 by default [EXPLICIT] |
| Output mode | `--json` flag for structured output | Scripts consumed by both humans and tools [EXPLICIT] |
| Colors | MetodologIA palette constants | Brand compliance [EXPLICIT] |
| Exit codes | 0 = success, 1 = error, 0 always for hooks | Hooks must never block [EXPLICIT] |
| Temp files | `mktemp` + atomic rename | Prevent partial writes [EXPLICIT] |
| State files | `.specify/` directory | Centralized project state [EXPLICIT] |

## Common Patterns

### Fast Path (for hooks)
```bash
# Skip immediately if not an SDD project
[[ ! -d ".specify" ]] && exit 0
```

### Atomic JSON Write
```bash
TMP=$(mktemp)
python3 -c "
import json, sys
data = json.load(open('$STATE_FILE')) if os.path.exists('$STATE_FILE') else {}
data['key'] = 'value'
json.dump(data, open('$TMP', 'w'), indent=2)
" && mv "$TMP" "$STATE_FILE"
```

### Cross-Platform Date (BSD vs GNU)
```bash
if date -v+1d &>/dev/null 2>&1; then
    # BSD (macOS)
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
else
    # GNU (Linux)
    NOW=$(date -u --iso-8601=seconds)
fi
```

### Event Rotation (bounded log files)
```bash
# Keep last N events in a JSON array
python3 -c "
import json
data = json.load(open('$LOG'))
data['events'] = data['events'][-200:]  # Keep last 200
json.dump(data, open('$LOG', 'w'), indent=2)
"
```

## PowerShell Equivalents

For every bash script, provide a PowerShell equivalent in `scripts/powershell/`. [EXPLICIT]

Key differences:
- Use `$PSScriptRoot` instead of `BASH_SOURCE`
- Use `ConvertTo-Json` / `ConvertFrom-Json` instead of jq/python
- Use `Write-Host` with `-ForegroundColor` for branded output
- Use `-Json` parameter instead of `--json`
