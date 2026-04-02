---
name: sdd-core
description: >-
  SDD project initialization, status, feature selection, and help.
  Enhanced fork of iikit-core with workspace sessions, heartbeat init, ALM deployment, and SDD branding.
license: GPL-3.0
metadata:
  version: "3.6.0"
  upstream: "iikit-core v1.6.4"
context-scope:
  always: [.specify/context.json]
  load: [PREMISE.md, CONSTITUTION.md]
  never: [spec.md, plan.md, tasks.md]
allowed-tools:
  - Bash(bash scripts/*)
  - Bash(node scripts/*)
  - Read
  - Write
  - Edit
  - TodoWrite
---

# SDD Core — Spec Driven Development by MetodologIA

Enhanced project initialization with ALM dashboard, workspace sessions, and Neo-Swiss branding.

## User Input

```text
$ARGUMENTS
```

## Execution

**Step 1**: Delegate to upstream IIKit core skill:
```
Run the skill at iikit-core (absorbed) with $ARGUMENTS
```

**Step 2**: Apply SDD extensions after upstream completes:

### On `init`:
```bash
bash scripts/sdd-init.sh "$PROJECT_PATH"
```
This runs: upstream init → .specify/context.json → ALM deployment (12 pages) → dashboard generation → QA plan → knowledge graph → heartbeat init → GitHub sync.

### On `status`:
```bash
bash scripts/sdd-status.sh "$PROJECT_PATH"
```
Shows: feature table + pipeline state (completedPhases) + workspace sessions + health score.

### On `use` (feature selection):
After upstream sets active feature, also update workspace if linked:
```bash
bash scripts/sdd-workspace.sh current "$PROJECT_PATH"
```

**Step 3**: Initialize workspace session if none active:
```bash
bash scripts/sdd-workspace.sh current "$PROJECT_PATH"
```
If no active workspace, suggest: `/sdd:workspace create <task-name>`
