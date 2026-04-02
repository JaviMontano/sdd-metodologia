---
name: sdd-bugfix
description: >-
  SDD Bug report + fix tasks. Enhanced: Quick Flow triage, GitHub issue inbound (#number),
  scope guard against AP-06 (consecutive quick flows).
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-bugfix v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, tasks.md]
  never: [plan.md, analysis.md]
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Bugfix

## Quick Flow Triage (pre-execution)

```bash
bash scripts/sdd-quick-flow-triage.sh "$PROJECT_PATH"
```
If ESCALATE: redirect to `/sdd:spec` for full pipeline.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-bugfix (absorbed) with $ARGUMENTS
```

Upstream handles: bug report structure (BUG-ID, severity, reproduction), GitHub issue inbound (#number), T-B prefix tasks, BDD/TDD flow for bug test cases.

**Step 2**: SDD extensions:

### Capture bug input to RAG:
```bash
bash scripts/sdd-rag-capture.sh "$INPUT_FILE" "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
