---
name: sdd-01-specify
description: >-
  SDD Phase 1 — User Specs from natural language. FR-NNN, SC-NNN, acceptance scenarios.
  Enhanced: bug-fix intent detection, semantic diff on re-run, workspace RAG capture.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-01-specify v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [PREMISE.md]
  never: [plan.md, tasks.md, "*.feature", analysis.md]
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Phase 1 — Specify

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-01-specify (absorbed) with $ARGUMENTS
```

Upstream handles: bug-fix intent detection, feature numbering, branch creation, spec quality checklist.

**Step 2**: SDD extensions:

### Semantic diff warning (on re-run):
If spec.md already exists, warn before overwriting:
> "spec.md already exists. Modifications may impact downstream artifacts (plan.md, tasks.md, .feature files). Proceed with re-specification?"

### Validate spec:
```bash
bash scripts/sdd-validate-artifact.sh spec "$FEATURE_DIR/spec.md" "$PROJECT_PATH"
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 01 "$PROJECT_PATH"
```

### Capture input to RAG:
If user provided external input (file, URL), capture:
```bash
bash scripts/sdd-rag-capture.sh "$INPUT_FILE" "$PROJECT_PATH"
```
