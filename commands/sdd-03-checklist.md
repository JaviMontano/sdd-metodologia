---
description: "SDD Phase 3 — BDD Analysis — requirements quality checklists (not implementation testing) [GATE G1]"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md]
  never: [tasks.md, "*.feature", analysis.md]
---

# /sdd:03-checklist

Generate domain-specific quality checklists validating requirements completeness. Gates before implementation.

## Gate G1 (Mandatory — hard stop)

Before execution, run the gate check:
```bash
bash scripts/sdd-gate-check.sh 03 "$PROJECT_PATH"
```
If result is FAIL: **HALT**. Plan must have architecture + data model sections.
If result is CONDITIONAL: warn but proceed.

## Execution
Run the skill at `skills/sdd-03-checklist/SKILL.md` with the user's input.

## Phase Completion
After checklists are generated:
```bash
bash scripts/sdd-phase-complete.sh 03 "$PROJECT_PATH"
```
