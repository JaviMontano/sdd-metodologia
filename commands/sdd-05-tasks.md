---
description: "SDD Phase 5 — Task — dependency-ordered, parallelism-marked task breakdown"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, "*.feature"]
  never: [analysis.md]
---

# /sdd:05-tasks

Break features into implementable tasks with dependency ordering and parallel markers.

## Execution
Run the skill at `skills/sdd-05-tasks/SKILL.md` with the user's input.

## Phase Completion
After tasks.md is created with T-NNN identifiers:
```bash
bash scripts/sdd-phase-complete.sh 05 "$PROJECT_PATH"
```
