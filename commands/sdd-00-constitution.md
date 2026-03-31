---
description: "SDD Phase 0 — Define project governance principles and coding standards"
user-invocable: true
context-scope:
  always: [.specify/context.json]
  load: [PREMISE.md]
  never: [spec.md, plan.md, tasks.md, "*.feature"]
---

# /sdd:00-constitution

Define project rules, coding standards, quality gates, TDD requirements, and non-negotiable development principles.

## Execution
Run the skill at `skills/sdd-00-constitution/SKILL.md` with the user's input.

## Phase Completion
After CONSTITUTION.md is created/updated:
```bash
bash scripts/sdd-phase-complete.sh 00 "$PROJECT_PATH"
```
