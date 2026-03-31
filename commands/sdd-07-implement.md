---
description: "SDD Phase 7 — Deliver — iterative TDD implementation (red/green/refactor per task) [GATE G2]"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [tasks.md, plan.md, "*.feature"]
  never: [spec.md, analysis.md]
---

# /sdd:07-implement

Deliver — iterative TDD implementation (red/green/refactor per task): process tasks, run tests, validate output. HALTS if checklists incomplete.

## Gate G2 (Mandatory — hard stop)

Before execution, run the gate check:
```bash
bash scripts/sdd-gate-check.sh 07 "$PROJECT_PATH"
```
If result is FAIL: **HALT**. Show findings and ask user to resolve before proceeding.
If result is CONDITIONAL: warn but proceed.

## Execution
Run the skill at `skills/sdd-07-implement/SKILL.md` with the user's input.

## Post-Implementation Verification (G3 prep)

After implementation completes:

1. **Detect test runner**: check package.json `scripts.test`, pytest.ini, Makefile test target
2. **Run tests**: execute the test runner and capture exit code
3. **Generate assertion hashes**: `bash scripts/sdd-assertion-hash.sh generate "$PROJECT_PATH"`
4. **Verify no spec drift**: check that specs/ files haven't changed since Phase 6
5. **Update pipeline state**: `bash scripts/sdd-phase-complete.sh 07 "$PROJECT_PATH"`

If tests fail: report failures and do NOT mark phase as complete.
