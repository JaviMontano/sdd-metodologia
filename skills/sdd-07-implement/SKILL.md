---
name: sdd-07-implement
description: >-
  SDD Phase 7 — Iterative TDD implementation with BDD verification chain. [GATE G2]
  Enhanced: mandatory gate, step coverage verification, assertion integrity, feature immutability.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-07-implement v1.6.4"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [tasks.md, plan.md, "*.feature"]
  never: [spec.md, analysis.md]
---

# SDD Phase 7 — Implement [GATE G2]

## Gate G2 (Mandatory)

```bash
bash scripts/sdd-gate-check.sh 07 "$PROJECT_PATH"
```
If FAIL: **HALT**. All analysis findings must be resolved.

## BDD Verification Chain (pre-implementation)

```bash
bash scripts/sdd-bdd-verify.sh "$PROJECT_PATH"
```
Validates: framework detection → step coverage → step quality → assertion integrity → feature immutability.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at .claude/skills/iikit-07-implement/SKILL.md with $ARGUMENTS
```

Upstream handles: task dispatch, red-green-refactor cycle, feature file immutability enforcement, task commits with trailers, parallel task execution via subagents, dependency satisfaction tracking.

**Step 2**: SDD extensions after implementation:

### Re-verify BDD chain (post-implementation):
```bash
bash scripts/sdd-bdd-verify.sh "$PROJECT_PATH"
```

### Regenerate assertion hashes (if .feature files untouched, should still match):
```bash
bash scripts/sdd-assertion-hash.sh verify "$PROJECT_PATH"
```

### Run Definition of Done check:
```bash
bash scripts/sdd-dod-check.sh "$ACTIVE_FEATURE" "$PROJECT_PATH"
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 07 "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
