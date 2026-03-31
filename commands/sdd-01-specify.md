---
description: "SDD Phase 1 — User Specs — user stories, functional requirements (FR), success criteria (SC) from natural language"
user-invocable: true
---

# /sdd:01-specify

Generate a feature specification: PRD, user stories, acceptance criteria from natural language description.

## Execution
Run the skill at `.claude/skills/iikit-01-specify/SKILL.md` with the user's input.

## Phase Completion
After spec.md is created with FR-NNN requirements:
```bash
bash scripts/sdd-phase-complete.sh 01 "$PROJECT_PATH"
```
