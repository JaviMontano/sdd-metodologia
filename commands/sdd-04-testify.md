---
description: "SDD Phase 4 — BDD Gherkin test specs with assertion hashing"
user-invocable: true
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: [spec.md, plan.md, checklist.md]
  never: [tasks.md, analysis.md]
---

# /sdd:04-testify

Generate Gherkin .feature files with BDD verification and cryptographic assertion integrity hashing.

## Execution
Run the skill at `skills/sdd-04-testify/SKILL.md` with the user's input.

## Assertion Hashing
After .feature files are generated, hash all scenario blocks:
```bash
bash scripts/sdd-assertion-hash.sh generate "$PROJECT_PATH"
```
Hashes are verified at G3 (Phase 8) — any modification between now and then will be detected.

## Phase Completion
```bash
bash scripts/sdd-phase-complete.sh 04 "$PROJECT_PATH"
```
