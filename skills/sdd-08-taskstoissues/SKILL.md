---
name: sdd-08-taskstoissues
description: >-
  SDD Phase 8 — Export tasks to GitHub Issues with labels and dependencies. [GATE G3]
  Enhanced: mandatory gate, issue-map tracking, cross-check verification.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-08-taskstoissues v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [tasks.md]
  never: [spec.md, plan.md, "*.feature", analysis.md]
---

# SDD Phase 8 — Ship [GATE G3]

## Gate G3 (Mandatory)

```bash
bash scripts/sdd-gate-check.sh 08 "$PROJECT_PATH"
```
If FAIL: **HALT**. Tests must pass and assertion hashes must verify.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at .claude/skills/iikit-08-taskstoissues/SKILL.md with $ARGUMENTS
```

Upstream handles: issue creation, label assignment, parallel dispatch, cross-reference linking.

**Step 2**: SDD extensions:

### Store issue mapping:
Capture created issue URLs in `.specify/issue-map.json`.

### Cross-check:
Verify every T-NNN in tasks.md has a corresponding GitHub issue.

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 08 "$PROJECT_PATH"
```

### Final dashboard refresh:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
