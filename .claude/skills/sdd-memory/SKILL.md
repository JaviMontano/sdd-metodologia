---
name: sdd-memory
description: >-
  This skill should be used when the user asks to "browse RAG memory", "search captures",
  "list memory files", "find past inputs", "show knowledge base",
  or "review stored context". It browses and searches the RAG memory archive indexed
  in rag-index.json. Use this skill whenever the user mentions memory browsing,
  RAG search, captured files, or knowledge base exploration.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Memory — RAG Memory Browser and Search [EXPLICIT]

Browse and search the RAG memory archive for captured inputs and context.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). Arguments serve as search query.

## Execution Flow

### 1. Load Index

Read `.specify/rag-index.json` for all captured entries.

### 2. Search or Browse

- If arguments provided: filter entries by tags, type, or content match
- If no arguments: list all entries sorted by capture date

### 3. Display Results

```
RAG Memory Archive

| # | File | Type | Tags | Captured |
|---|------|------|------|----------|
| 1 | rag-memory-of-api-spec.md | markdown | api, rest | 2026-03-28 |
| 2 | rag-memory-of-meeting.md | text | stakeholder | 2026-03-27 |

Total: N entries | Workspace: N | Global: N
```

### 4. Detail View

If user selects an entry, display frontmatter + abstract + key takeaways.

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | `.specify/rag-index.json` exists | If missing, suggest `/sdd:capture` first. [EXPLICIT] |
| 2 | Search matches tags, type, filename, and content | Multi-field search for maximum recall. [EXPLICIT] |
| 3 | Both workspace and global entries indexed | Unified view across all capture locations. [EXPLICIT] |
| 4 | Read-only operation | Memory browsing never modifies entries. [EXPLICIT] |
| 5 | Entries sorted by capture date (newest first) | Default sort order for relevance. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No captures exist | rag-index.json empty or missing | Report "no captures", suggest `/sdd:capture`. [EXPLICIT] |
| Search returns no results | No entries match query | Report "no matches", suggest broader search. [EXPLICIT] |
| Large archive (50+ entries) | Many captures | Paginate output, show first 20 with count. [INFERRED] |
| Corrupted entry | RAG file exists but malformed | Skip with warning, report valid count. [INFERRED] |
| Workspace-specific search | User wants only workspace entries | Support `--workspace` flag to filter. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:memory api`
```
RAG Memory — Search: "api"

| # | File | Type | Tags | Captured |
|---|------|------|------|----------|
| 1 | rag-memory-of-api-spec.md | markdown | api, rest, auth | 2026-03-28 |
| 2 | rag-memory-of-api-notes.md | text | api, meeting | 2026-03-25 |

2 results found (of 8 total entries)
```

**Bad**: Memory listing without metadata
```
x Plain file list without tags or dates
x No search capability
x No workspace/global distinction
```

**Why**: Memory browser must provide searchable, tagged, dated entries with workspace awareness. [EXPLICIT]

## Validation Gate

Before marking memory browse as complete, verify: [EXPLICIT]

- [ ] V1: rag-index.json loaded or error reported
- [ ] V2: Entries displayed with metadata (type, tags, date)
- [ ] V3: Search filtered correctly if query provided
- [ ] V4: Entry count reported
- [ ] V5: Workspace vs global distinction shown
