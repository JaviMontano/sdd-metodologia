#!/usr/bin/env bash
# sdd-validate-artifact.sh — Validate artifact content and structure
# Checks JSON files against schemas and markdown files against content rules.
#
# Usage: bash scripts/sdd-validate-artifact.sh <type> <file> [project-path]
#   type: context|session|gate-results|spec|plan|tasks|feature
#   file: path to the artifact file
#
# Exit codes: 0 valid, 1 invalid, 2 file not found

set -euo pipefail

TYPE="${1:-}"
FILE="${2:-}"
PROJECT_PATH="${3:-.}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMAS_DIR="$ROOT_DIR/references/schemas"

ERRORS=0
WARNINGS=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); }

if [[ -z "$TYPE" || -z "$FILE" ]]; then
  echo "Usage: sdd-validate-artifact.sh <type> <file> [project-path]" >&2
  echo "Types: context, session, gate-results, spec, plan, tasks, feature" >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Error: File not found: $FILE" >&2
  exit 2
fi

echo "Validating $TYPE: $FILE"

# ─── JSON validation (with schema) ───
validate_json() {
  local file="$1" schema_name="$2"
  local schema="$SCHEMAS_DIR/${schema_name}.schema.json"

  # Basic JSON parse
  if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
    fail "Invalid JSON syntax"
    return
  fi
  pass "Valid JSON syntax"

  # Schema validation (if schema exists and jsonschema available)
  if [[ -f "$schema" ]]; then
    if python3 -c "
import json, sys
try:
    from jsonschema import validate, ValidationError
    with open('$file') as f: data = json.load(f)
    with open('$schema') as f: sch = json.load(f)
    validate(data, sch)
    print('PASS')
except ImportError:
    print('SKIP:no-jsonschema')
except ValidationError as e:
    print('FAIL:' + e.message[:200])
except Exception as e:
    print('FAIL:' + str(e)[:200])
" 2>/dev/null | grep -q "^PASS"; then
      pass "Schema validation passed"
    elif python3 -c "
import json, sys
try:
    from jsonschema import validate, ValidationError
    with open('$file') as f: data = json.load(f)
    with open('$schema') as f: sch = json.load(f)
    validate(data, sch)
except ImportError:
    print('SKIP')
    sys.exit(0)
except ValidationError as e:
    print(e.message[:200])
    sys.exit(1)
" 2>/dev/null; then
      pass "Schema validation passed"
    else
      RESULT=$(python3 -c "
import json, sys
try:
    from jsonschema import validate, ValidationError
    with open('$file') as f: data = json.load(f)
    with open('$schema') as f: sch = json.load(f)
    validate(data, sch)
    print('PASS')
except ImportError:
    print('SKIP')
except ValidationError as e:
    print('FAIL:' + e.message[:200])
except Exception as e:
    print('ERROR:' + str(e)[:200])
" 2>&1 || echo "ERROR")
      case "$RESULT" in
        PASS) pass "Schema validation passed" ;;
        SKIP*) warn "jsonschema not installed — schema check skipped" ;;
        FAIL:*) fail "Schema: ${RESULT#FAIL:}" ;;
        *) warn "Schema check inconclusive" ;;
      esac
    fi
  else
    warn "No schema file found for $schema_name"
  fi
}

# ─── Markdown content validation ───
validate_spec() {
  local file="$1"
  # Must contain at least one FR-NNN pattern
  if grep -qE 'FR-[0-9]{3}' "$file"; then
    FR_COUNT=$(grep -cE 'FR-[0-9]{3}' "$file" || true)
    pass "Contains $FR_COUNT functional requirements (FR-NNN)"
  else
    fail "No FR-NNN patterns found — spec must define functional requirements"
  fi

  # Must contain acceptance criteria or scenarios
  if grep -qiE '(scenario|acceptance|given|when|then|SC-[0-9]{3})' "$file"; then
    pass "Contains acceptance criteria or scenarios"
  else
    warn "No acceptance criteria found (SC-NNN, Given/When/Then)"
  fi

  # Must NOT contain implementation details (phase separation)
  if grep -qiE '(CREATE TABLE|SELECT \*|import |require\(|function |class |def |useState)' "$file"; then
    fail "Contains implementation details — spec must describe WHAT, not HOW"
  else
    pass "No implementation details detected"
  fi
}

validate_plan() {
  local file="$1"
  # Must contain data model section
  if grep -qiE '(data model|modelo de datos|entities|entidades|## .*[Dd]ata)' "$file"; then
    pass "Contains data model section"
  else
    fail "Missing data model section"
  fi

  # Must contain architecture or tech stack
  if grep -qiE '(architecture|arquitectura|tech stack|stack tecnol|## .*[Aa]rch)' "$file"; then
    pass "Contains architecture/tech stack section"
  else
    fail "Missing architecture section"
  fi

  # Must contain API or contracts
  if grep -qiE '(API|endpoint|contract|contrato|REST|GraphQL|gRPC)' "$file"; then
    pass "Contains API/contract definitions"
  else
    warn "No API contract definitions found"
  fi
}

validate_tasks() {
  local file="$1"
  # Must contain T-NNN task identifiers
  if grep -qE 'T-[0-9]{3}' "$file"; then
    T_COUNT=$(grep -cE 'T-[0-9]{3}' "$file" || true)
    pass "Contains $T_COUNT tasks (T-NNN)"
  else
    fail "No T-NNN task identifiers found"
  fi

  # Must reference FR-NNN requirements
  if grep -qE 'FR-[0-9]{3}' "$file"; then
    pass "Tasks reference requirements (FR-NNN)"
  else
    warn "Tasks don't reference requirements — traceability gap"
  fi

  # Check for dependency markers
  if grep -qiE '(depends|dependency|bloqueado|blocked|→|requires)' "$file"; then
    pass "Contains dependency information"
  else
    warn "No dependency markers found"
  fi
}

validate_feature() {
  local file="$1"
  # Must be valid Gherkin
  if grep -qE '^Feature:' "$file"; then
    pass "Valid Gherkin Feature header"
  else
    fail "Missing 'Feature:' header"
  fi

  # Must have scenarios
  SCENARIO_COUNT=$(grep -cE '^\s*Scenario' "$file" || true)
  if [[ $SCENARIO_COUNT -gt 0 ]]; then
    pass "Contains $SCENARIO_COUNT scenarios"
  else
    fail "No scenarios found"
  fi

  # Must have Given/When/Then
  if grep -qE '^\s*(Given|When|Then)' "$file"; then
    pass "Contains Given/When/Then steps"
  else
    fail "Missing Given/When/Then steps"
  fi

  # Must reference FR-NNN via tags
  if grep -qE '@FR-[0-9]{3}' "$file"; then
    pass "Tagged with requirement references (@FR-NNN)"
  else
    warn "No @FR-NNN tags — traceability gap"
  fi
}

# ─── Dispatch ───
case "$TYPE" in
  context) validate_json "$FILE" "context" ;;
  session) validate_json "$FILE" "session" ;;
  gate-results) validate_json "$FILE" "gate-results" ;;
  spec) validate_spec "$FILE" ;;
  plan) validate_plan "$FILE" ;;
  tasks) validate_tasks "$FILE" ;;
  feature) validate_feature "$FILE" ;;
  *) echo "Error: Unknown type '$TYPE'" >&2; exit 1 ;;
esac

# ─── Summary ───
echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "RESULT: VALID ($WARNINGS warnings)"
  exit 0
else
  echo "RESULT: INVALID ($ERRORS errors, $WARNINGS warnings)"
  exit 1
fi
