---
description: "SDD Phase 8 — Ship — export to GitHub Issues, deploy, close loop [GATE G3]"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [tasks.md]
  never: [spec.md, plan.md, "*.feature", analysis.md]
---

# /sdd:08-issues

Ship — export to GitHub Issues, deploy, close loop with labels, dependencies, and project board assignments.

## Gate G3 (Mandatory — hard stop)

Before execution, run the gate check:
```bash
bash scripts/sdd-gate-check.sh 08 "$PROJECT_PATH"
```
If result is FAIL: **HALT**. Tests must pass and assertion hashes must verify.
If result is CONDITIONAL: warn (e.g., no test runner detected) but proceed.

## Execution
Run the skill at `skills/sdd-08-taskstoissues/SKILL.md` with the user's input.

## Post-Export Verification

After issue export:

1. **Verify gh CLI**: confirm `gh` is authenticated (`gh auth status`)
2. **Capture issue URLs**: store created issue URLs in `.specify/issue-map.json`
3. **Cross-check**: verify every T-NNN in tasks.md has a corresponding issue
4. **Update pipeline state**: `bash scripts/sdd-phase-complete.sh 08 "$PROJECT_PATH"`

On `gh` failure: show clear auth instructions (`gh auth login`).
