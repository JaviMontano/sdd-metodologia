---
name: sdd-03-checklist
description: >-
  SDD Phase 3 — BDD Analysis quality checklists. [GATE G1]
  Enhanced: mandatory gate enforcement, FR→plan alignment check.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-03-checklist v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md]
  never: [tasks.md, "*.feature", analysis.md]
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Phase 3 — Checklist [GATE G1]

## Gate G1 (Mandatory)

```bash
bash scripts/sdd-gate-check.sh 03 "$PROJECT_PATH"
```
If FAIL: **HALT**. Plan must have architecture + data model + FR alignment.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-03-checklist (absorbed) with $ARGUMENTS
```

**Step 2**: SDD extensions:

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 03 "$PROJECT_PATH"
```
