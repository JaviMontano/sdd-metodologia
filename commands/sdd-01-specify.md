---
description: "SDD Phase 1 — User Specs — user stories, functional requirements (FR), success criteria (SC) from natural language"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [PREMISE.md]
  never: [plan.md, tasks.md, "*.feature", analysis.md]
---

# /sdd:01-specify

Generate a feature specification: PRD, user stories, acceptance criteria from natural language description.

## Execution
Run the skill at `skills/sdd-01-specify/SKILL.md` with the user's input.

## Phase Completion
After spec.md is created with FR-NNN requirements:
```bash
bash scripts/sdd-phase-complete.sh 01 "$PROJECT_PATH"
```
