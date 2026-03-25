---
description: "SDD — Manage per-task workspace sessions (create, list, select, done, archive, stats)"
user-invocable: true
---

# /sdd:workspace

Isolates inputs, RAG memory, logs, and tasklog per interaction/task. Each session is a dated folder under `workspace/` that integrates with the ALM dashboard, heartbeat nudge, and workspace-aware RAG routing.

**Trade-off**: One active workspace at a time. This simplifies routing (RAG capture, session logs) at the cost of preventing parallel task isolation. For parallel work, create one session per task and switch with `select`.

## Subcommands

### create — Start a new session
```bash
bash scripts/sdd-workspace.sh create "implement auth flow" .
```
Creates `workspace/yyyy-mm-dd-implement-auth-flow/` with full structure. Sets as active immediately. If a session with the same slug exists for today, reuses it (idempotent).

**Acceptance**: folder exists with `inputs/`, `rag/`, `logs/`, `tasklog.md`, `session.json`; `.specify/active-workspace` points to it.

### list — Show all sessions with live stats
```bash
bash scripts/sdd-workspace.sh list .
```
Counts are live from filesystem (not cached `session.json`), preventing counter drift.

### select — Set active workspace (supports partial match)
```bash
bash scripts/sdd-workspace.sh select auth .
```
Partial match: `auth` finds `2026-03-25-implement-auth-flow`. Exact match takes priority.

### current — Show active session + stats
```bash
bash scripts/sdd-workspace.sh current .
```
If the active workspace folder was deleted, clears the stale reference and warns.

### done — Mark session complete
```bash
bash scripts/sdd-workspace.sh done <session-name> .
```
Sets status to "done" and clears active if it was this session. Dashboard renders with blue badge.

### archive — Soft-delete a session
```bash
bash scripts/sdd-workspace.sh archive <session-name> .
```
Sets status to "archived". Folder and data preserved. Dashboard renders with muted badge.

### stats — Aggregate counts
```bash
bash scripts/sdd-workspace.sh stats .
```
Totals across all sessions: count, inputs, RAG files, tasks, by status.

## Structure

```
workspace/
  yyyy-mm-dd-task-name/
    inputs/          # Raw inputs (files, URLs saved as .txt)
    inputs/.gitkeep  # Ensures git tracks empty dir
    rag/             # RAG memory files (auto-routed from /sdd:capture)
    rag-index.json   # Per-session RAG index
    logs/            # Session event log (dual-written)
    tasklog.md       # Work item table (TL-NNN format)
    session.json     # Schema v1 metadata
```

### session.json schema (v1)
```json
{
  "schemaVersion": 1,
  "taskName": "string",
  "sessionId": "yyyy-mm-dd-slug",
  "created": "ISO-8601",
  "status": "active|done|archived",
  "inputCount": 0,
  "ragCount": 0,
  "lastActivity": "ISO-8601",
  "parentFeature": "null|feature-id",
  "tags": []
}
```

## Integration Points

| System | Behavior when workspace active | Behavior when no workspace |
|--------|-------------------------------|---------------------------|
| **RAG capture** | Routes to `workspace/{id}/rag/` | Routes to `.specify/rag-memory/` (default) |
| **Session log** | Dual-write: global + `workspace/{id}/logs/` | Global only |
| **Heartbeat** | Checks folder exists; warns if missing | Nudges: "No workspace — /sdd:workspace create" |
| **Dashboard** | Session cards in Workspace page | Empty state with CTA |
| **`--global` flag** | Forces `.specify/` routing (bypass workspace) | N/A |

## Edge Cases

- **Same task, same day**: Reuses existing session (idempotent create)
- **Deleted folder**: `current` detects and clears stale reference; heartbeat warns
- **Empty task name**: Rejected with error (must contain alphanumeric)
- **Long names**: Slug truncated at 60 chars
- **No .specify/**: All subcommands exit 0 with "Not an SDD project" message
- **Partial select match**: First chronological match wins; use exact name for precision
