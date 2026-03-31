---
description: "SDD Phase 2 — Technical Specs — architecture, data model, API contracts, technology decisions"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, PREMISE.md]
  never: [tasks.md, "*.feature", analysis.md]
---

# /sdd:02-plan

Create technical design: tech stack, data models, API contracts, research. HALTS if decisions violate constitution.

## Execution
Run the skill at `skills/sdd-02-plan/SKILL.md` with the user's input.

## Phase Completion
After plan.md is created with architecture + data model:
```bash
bash scripts/sdd-phase-complete.sh 02 "$PROJECT_PATH"
```
