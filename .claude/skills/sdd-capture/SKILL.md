---
name: sdd-capture
description: >-
  This skill should be used when the user asks to "capture input", "save to RAG memory",
  "index a file", "store reference material", "capture document for context",
  or "add to knowledge base". It captures session inputs as RAG memory files with
  frontmatter, abstract, key takeaways, and full content. Workspace-aware routing
  sends captures to the active workspace's rag/ folder. Use this skill whenever the
  user mentions capture, RAG, memory indexing, or knowledge base storage.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Capture — RAG Memory Capture with Auto-Detect [EXPLICIT]

Capture files as RAG memory entries with frontmatter, abstract, key takeaways, and workspace-aware routing.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The argument should be a file path.

## Execution Flow

### 1. Run Capture Script

```bash
bash scripts/sdd-rag-capture.sh <file-path> [--global]
```

### 2. Auto-Detect File Type

Supported: text, markdown, HTML, images, audio, PDFs.

### 3. Generate RAG Entry

Creates `rag-memory-of-{slug}.md` with:
- Frontmatter: source, type, size, tags, captured timestamp
- Abstract + Key Takeaways + Relevant Insights
- Full Content (verbatim for text, structure summary for HTML, description for images)

### 4. Index

Updates `.specify/rag-index.json` with new entry.

### 5. Routing

- If workspace active: captures go to `workspace/{session}/rag/`
- If no workspace or `--global`: captures go to `.specify/rag-memory/`

## Report

```
Captured!

File: <source-file>
RAG entry: <output-path>/rag-memory-of-{slug}.md
Type: <detected-type>
Size: <file-size>
Routed to: workspace/2026-03-30-task/rag/ (or .specify/rag-memory/)
Index: .specify/rag-index.json updated
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | File path provided as argument | If empty, ERROR with usage example. [EXPLICIT] |
| 2 | File exists and is readable | If not found, ERROR. [EXPLICIT] |
| 3 | Workspace-aware routing is default | Active workspace's rag/ used unless `--global`. [EXPLICIT] |
| 4 | RAG entry includes LLM-generated abstract | Requires AI inference for abstract/takeaways. [EXPLICIT] |
| 5 | Index file tracks all captures | `.specify/rag-index.json` updated atomically. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No file argument | Empty $ARGUMENTS | ERROR with usage: `/sdd:capture <file-path>`. [EXPLICIT] |
| File not found | Path doesn't exist | ERROR with "file not found" message. [EXPLICIT] |
| Binary file (image/audio) | MIME type detection | Generate description instead of verbatim content. [EXPLICIT] |
| Very large file (>1MB) | File size check | Truncate content, note truncation in frontmatter. [INFERRED] |
| Duplicate capture | Same file already captured | Update existing entry, note "re-captured" in frontmatter. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:capture docs/api-spec.md`
```
Captured!
File: docs/api-spec.md
RAG entry: workspace/2026-03-30-task/rag/rag-memory-of-api-spec.md
Type: markdown | Size: 12KB
Abstract: API specification for REST endpoints...
Key Takeaways: 3 endpoints, JWT auth, rate limiting
```

**Bad**: Capture without metadata
```
x File copied without frontmatter
x No abstract or takeaways
x Not indexed in rag-index.json
```

**Why**: RAG capture must generate structured entries with frontmatter, abstract, and index updates for retrieval. [EXPLICIT]

## Validation Gate

Before marking capture as complete, verify: [EXPLICIT]

- [ ] V1: Source file read successfully
- [ ] V2: RAG entry created with proper frontmatter
- [ ] V3: Abstract and key takeaways generated
- [ ] V4: Entry routed to correct location (workspace or global)
- [ ] V5: `.specify/rag-index.json` updated
