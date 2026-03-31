---
name: sdd-00-constitution
description: >-
  SDD Phase 0 — Define governance principles, coding standards, quality gates, and TDD policy.
  Enhanced: validates context.json, updates pipeline state, suggests workspace creation.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-00-constitution v1.6.4"
context-scope:
  always: [.specify/context.json]
  load: [PREMISE.md]
  never: [spec.md, plan.md, tasks.md, "*.feature"]
---

# SDD Phase 0 — Constitution

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at .claude/skills/iikit-00-constitution/SKILL.md with $ARGUMENTS
```

**Step 2**: SDD extensions after CONSTITUTION.md is created:

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 00 "$PROJECT_PATH"
```

### Validate context:
```bash
bash scripts/sdd-validate-artifact.sh context .specify/context.json "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
