---
description: "SDD — Resume work after absence: show state, last activity, health, and next action"
user-invocable: true
---

# /sdd:resume

Restores context after being away. Shows pipeline state, last activity, health score, active workspace, and recommends the next action.

## Execution

**Step 1**: Read pipeline state:
```bash
bash scripts/sdd-status.sh "$PROJECT_PATH"
```

**Step 2**: Read last session events (most recent 5):
Read `.specify/session-log.json` and extract the last 5 events with timestamps.

**Step 3**: Read active workspace:
```bash
bash scripts/sdd-workspace.sh current "$PROJECT_PATH"
```

**Step 4**: Run heartbeat to detect issues:
```bash
bash scripts/sdd-heartbeat-lite.sh
```

**Step 5**: Determine next action:
```bash
bash scripts/sdd-next-step.sh "$PROJECT_PATH"
```

**Step 6**: Present summary to user:

```
Welcome back to SDD.

Project: [name]
Feature: [active feature] — Phase [current] of 8
Completed: [list of completed phases]
Last activity: [timestamp] — [description]
Workspace: [active session name]
Health: [score]%

Next step: /sdd:[command] — [reason]

Quick actions:
  /sdd:a        — Continue from where you left off
  /sdd:status   — Full pipeline overview
  /sdd:dashboard — Open Command Center
```
