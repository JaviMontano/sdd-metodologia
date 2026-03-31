---
name: sdd-workspace
description: >-
  This skill should be used when the user asks to "create workspace", "list workspaces",
  "select workspace", "archive workspace", "manage workspace sessions",
  or "switch task context". It manages per-task workspace sessions with isolated
  inputs, RAG files, logs, and tasklog per interaction. Use this skill whenever
  the user mentions workspace, session management, task isolation, or context switching.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Workspace — Per-Task Session Manager [EXPLICIT]

Manage per-task workspace sessions that isolate inputs, RAG files, logs, and progress per task.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `create <name>` | Create a new workspace session and set as active |
| `list` | List all sessions with stats |
| `select <name>` | Set active session |
| `current` | Show active session details |
| `archive <name>` | Archive a completed session |
| `done <name>` | Mark session as done and archive |
| `stats` | Show workspace statistics |

## Execution Flow

### 1. Parse Subcommand

Determine subcommand from arguments. If empty, default to `list` if workspaces exist, otherwise suggest `create`.

### 2. Execute

```bash
bash scripts/sdd-workspace.sh <subcommand> [args]
```

### 3. Report

```
Workspace: <action completed>

Active: yyyy-mm-dd-task-name
  Inputs: N files
  RAG: N captures
  Logs: N entries
  Status: active/archived/done

Sessions: N total (N active, N archived)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Workspace directory is `workspace/` at project root | Created on first `create` if missing. [EXPLICIT] |
| 2 | Active workspace tracked in `.specify/active-workspace` | Single active workspace at a time. [EXPLICIT] |
| 3 | RAG captures route to active workspace's `rag/` folder | When active, captures go to workspace instead of global `.specify/rag-memory/`. [EXPLICIT] |
| 4 | Session logs dual-write to both global and workspace logs | Ensures both global and task-level audit trail. [EXPLICIT] |
| 5 | Workspace names are ISO-dated: `yyyy-mm-dd-task-name` | Script auto-prefixes current date if not provided. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No workspaces exist | `workspace/` empty or missing | Suggest `create` with example name. [EXPLICIT] |
| Duplicate workspace name | Session with same name exists | Append incrementing suffix (-2, -3). [EXPLICIT] |
| Archive active workspace | User archives the currently active workspace | Clear `.specify/active-workspace` after archiving. [EXPLICIT] |
| Very old workspaces | Sessions >30 days old | Suggest archiving in `list` output. [INFERRED] |
| No active workspace | `.specify/active-workspace` empty or missing | Warn that RAG captures go to global; suggest selecting one. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:workspace create auth-refactor`
```
Workspace created!

Active: 2026-03-30-auth-refactor
  Path: workspace/2026-03-30-auth-refactor/
  Inputs: 0 files
  RAG: 0 captures
  Status: active

RAG captures now route to workspace/2026-03-30-auth-refactor/rag/
```

**Bad**: No session isolation
```
x Files mixed in global directories
x No per-task tracking
x No active workspace indicator
```

**Why**: Workspace sessions isolate per-task inputs, RAG, and logs for clean context switching. [EXPLICIT]

## Validation Gate

Before marking workspace action as complete, verify: [EXPLICIT]

- [ ] V1: Subcommand parsed and executed
- [ ] V2: Workspace directory structure created (for `create`)
- [ ] V3: `.specify/active-workspace` updated (for `create`/`select`)
- [ ] V4: Session stats reported (input count, RAG count, status)
- [ ] V5: session.json written/updated in workspace directory
