---
name: sdd-02-plan
description: >-
  SDD Phase 2 — Technical Specs: architecture, data model, API contracts, technology decisions.
  Enhanced: Tessl tile discovery, context validation, schema enforcement.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-02-plan v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, PREMISE.md]
  never: [tasks.md, "*.feature", analysis.md]
---

# SDD Phase 2 — Plan

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at .claude/skills/iikit-02-plan/SKILL.md with $ARGUMENTS
```

Upstream handles: Tessl tile discovery, research phase, data-model.md, contracts/, constitution check, phase separation.

**Step 2**: SDD extensions:

### Validate plan:
```bash
bash scripts/sdd-validate-artifact.sh plan "$FEATURE_DIR/plan.md" "$PROJECT_PATH"
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 02 "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
