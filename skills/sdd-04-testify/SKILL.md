---
name: sdd-04-testify
description: >-
  SDD Phase 4 — Gherkin BDD test specs with cryptographic assertion hashing.
  Enhanced: SHA-256 hash generation, traceability tag validation, assertion integrity.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-04-testify v1.7.0"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, checklist.md]
  never: [tasks.md, analysis.md]
---

# SDD Phase 4 — Testify

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at .claude/skills/iikit-04-testify/SKILL.md with $ARGUMENTS
```

Upstream handles: Gherkin .feature generation, TDD assessment, @TS-XXX/@FR-XXX/@SC-XXX tags, Background/Scenario Outline/Rule constructs, SC-XXX coverage.

**Step 2**: SDD extensions:

### Generate assertion hashes (SHA-256):
```bash
bash scripts/sdd-assertion-hash.sh generate "$PROJECT_PATH"
```
Hashes lock .feature scenario blocks. Any modification during Phase 7 will be detected at Gate G3.

### Validate .feature traceability:
```bash
bash scripts/sdd-validate-artifact.sh feature "$FEATURE_DIR/tests/features/*.feature" "$PROJECT_PATH"
```

### Update pipeline state:
```bash
bash scripts/sdd-phase-complete.sh 04 "$PROJECT_PATH"
```

### Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```
