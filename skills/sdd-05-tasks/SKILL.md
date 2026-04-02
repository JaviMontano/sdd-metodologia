---
name: sdd-05-tasks
description: >-
  SDD Phase 5 — Dependency-ordered task breakdown with parallel markers and story labels.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-05-tasks v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, "*.feature"]
  never: [analysis.md]
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Phase 5 — Tasks

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-05-tasks (absorbed) with $ARGUMENTS
```

Upstream handles: dependency ordering, parallel markers [P], story labels [USn], Tessl convention query, T-NNN identifiers.

**Step 2**: SDD extensions:

### Validate tasks:
```bash
bash scripts/sdd-validate-artifact.sh tasks "$FEATURE_DIR/tasks.md" "$PROJECT_PATH"
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 05 "$PROJECT_PATH"
```
