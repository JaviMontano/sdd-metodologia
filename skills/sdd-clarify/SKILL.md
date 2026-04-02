---
name: sdd-clarify
description: >-
  SDD Utility — Resolve ambiguities in any artifact at any phase.
  Enhanced: auto-detect artifact, structured questions per ambiguity taxonomy, RAG capture.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-clarify v2.5.0"
context-scope:
  always: [CONSTITUTION.md, .specify/context.json]
  load: []
  never: []
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Clarify

Cross-phase utility for resolving ambiguities. Can be invoked at any point in the pipeline.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream:
```
Run the skill at iikit-clarify (absorbed) with $ARGUMENTS
```

Upstream handles: auto-detect artifact type (spec, plan, checklist, testify, tasks, constitution), structured questions per ambiguity-taxonomies.md, integration of answers into artifact with Clarifications section.

**Step 2**: SDD extensions:

### Capture clarification input to RAG:
```bash
bash scripts/sdd-rag-capture.sh "$CLARIFICATION_INPUT" "$PROJECT_PATH"
```
