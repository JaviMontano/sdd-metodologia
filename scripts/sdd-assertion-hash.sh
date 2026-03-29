#!/usr/bin/env bash
# sdd-assertion-hash.sh — Cryptographic assertion hashing for .feature files
# Computes SHA-256 of scenario blocks (excluding comments and blank lines).
# Detects tampering between testify (Phase 4) and implement (Phase 7).
#
# Usage:
#   bash scripts/sdd-assertion-hash.sh generate [project-path]  # Hash all .feature files
#   bash scripts/sdd-assertion-hash.sh verify [project-path]    # Verify hashes match
#
# Exit codes: 0 match/generated, 1 mismatch found, 2 no .feature files

set -euo pipefail

ACTION="${1:-generate}"
PROJECT_PATH="${2:-.}"
HASH_FILE="$PROJECT_PATH/.specify/assertion-hashes.json"

# ─── Find .feature files ───
FEATURES=()
while IFS= read -r f; do
  FEATURES+=("$f")
done < <(find "$PROJECT_PATH" -name "*.feature" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | sort)

if [[ ${#FEATURES[@]} -eq 0 ]]; then
  echo "No .feature files found" >&2
  exit 2
fi

# ─── Hash function: SHA-256 of non-blank, non-comment lines ───
hash_feature() {
  local file="$1"
  grep -vE '^\s*(#|$)' "$file" 2>/dev/null | shasum -a 256 | cut -c1-64
}

case "$ACTION" in
  generate)
    echo "Generating assertion hashes for ${#FEATURES[@]} .feature files..."
    mkdir -p "$(dirname "$HASH_FILE")"

    # Build JSON
    ENTRIES=""
    for f in "${FEATURES[@]}"; do
      REL_PATH="${f#$PROJECT_PATH/}"
      HASH=$(hash_feature "$f")
      ENTRIES+="\"$REL_PATH\": \"$HASH\","
      echo "  ✓ $REL_PATH → $HASH"
    done
    ENTRIES="${ENTRIES%,}"

    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$HASH_FILE.tmp" << EOF
{
  "generated": "$TS",
  "algorithm": "sha256",
  "scope": "non-blank, non-comment lines",
  "count": ${#FEATURES[@]},
  "hashes": {
    $ENTRIES
  }
}
EOF
    mv "$HASH_FILE.tmp" "$HASH_FILE"
    echo ""
    echo "Hashes written to $HASH_FILE"
    ;;

  verify)
    if [[ ! -f "$HASH_FILE" ]]; then
      echo "No assertion hashes file — run 'generate' first" >&2
      exit 2
    fi

    echo "Verifying assertion hashes..."
    MISMATCHES=0
    VERIFIED=0

    for f in "${FEATURES[@]}"; do
      REL_PATH="${f#$PROJECT_PATH/}"
      CURRENT_HASH=$(hash_feature "$f")
      STORED_HASH=$(python3 -c "
import json
with open('$HASH_FILE') as fh: data = json.load(fh)
print(data.get('hashes', {}).get('$REL_PATH', 'NOT_FOUND'))
" 2>/dev/null || echo "ERROR")

      if [[ "$STORED_HASH" == "NOT_FOUND" ]]; then
        echo "  ⚠ $REL_PATH — not in hash file (new file?)"
      elif [[ "$CURRENT_HASH" == "$STORED_HASH" ]]; then
        echo "  ✓ $REL_PATH — verified"
        VERIFIED=$((VERIFIED + 1))
      else
        echo "  ✗ $REL_PATH — TAMPERED"
        echo "    stored:  $STORED_HASH"
        echo "    current: $CURRENT_HASH"
        MISMATCHES=$((MISMATCHES + 1))
      fi
    done

    echo ""
    if [[ $MISMATCHES -gt 0 ]]; then
      echo "RESULT: $MISMATCHES MISMATCHES detected ($VERIFIED verified)"
      exit 1
    else
      echo "RESULT: ALL $VERIFIED hashes verified"
      exit 0
    fi
    ;;

  *)
    echo "Usage: sdd-assertion-hash.sh <generate|verify> [project-path]" >&2
    exit 1
    ;;
esac
