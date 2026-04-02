---
name: sdd-06-analyze
description: >-
  SDD Phase 6 — Cross-artifact consistency validation, traceability FR→TS→Tasks.
  Enhanced: knowledge graph rebuild, orphan detection, health scoring.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-06-analyze v1.7.6"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, tasks.md, "*.feature"]
  never: []
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Phase 6 — Analyze

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-06-analyze (absorbed) with $ARGUMENTS
```

Upstream handles: 8 detection passes (duplication, ambiguity, underspec, constitution alignment, phase separation, coverage gaps, inconsistency, prose range), feature file traceability, health score calculation.

**Step 2**: SDD extensions:

### Rebuild knowledge graph with orphan detection:
```bash
node scripts/sdd-knowledge-graph.js "$PROJECT_PATH"
```

### Generate QA plan:
```bash
node scripts/sdd-qa-plan.js "$PROJECT_PATH"
```

### Run insights snapshot:
```bash
node scripts/sdd-insights.js "$PROJECT_PATH" --snapshot
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 06 "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
