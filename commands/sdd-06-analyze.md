---
description: "SDD Phase 6 — Organize Plan — cross-artifact consistency validation, traceability FR→TS→Tasks"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, tasks.md, "*.feature"]
  never: []
---

# /sdd:06-analyze

Validate cross-artifact consistency: requirements traceability, conflict detection. HALTS on inconsistencies.

## Execution
Run the skill at `skills/sdd-06-analyze/SKILL.md` with the user's input.

## Phase Completion
After analysis passes with zero HIGH findings:
```bash
bash scripts/sdd-phase-complete.sh 06 "$PROJECT_PATH"
```
