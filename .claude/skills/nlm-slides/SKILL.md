---
name: nlm-slides
description: >
  Presentation architect for NotebookLM. Generates high-precision slide decks
  (detailed and presenter format) with studio_revise for post-generation
  fine-tuning. Focus prompts ≤5000 chars with dynamic placeholder composition.
license: MIT
metadata:
  version: "1.0.0"
  engine: "NotebookLM MCP"
  max_focus_prompt: 5000
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__notebooklm__notebook_get
  - mcp__notebooklm__notebook_describe
  - mcp__notebooklm__notebook_query
  - mcp__notebooklm__source_describe
  - mcp__notebooklm__chat_configure
  - mcp__notebooklm__studio_create
  - mcp__notebooklm__studio_status
  - mcp__notebooklm__studio_revise
  - mcp__notebooklm__download_artifact
  - mcp__notebooklm__export_artifact
context:
  - type: file
    path: references/format-matrix.md
  - type: file
    path: references/focus-library.md
---

# NLM Slides — NotebookLM Slide Deck Generator

> Generate presentation slide decks from NotebookLM notebooks with intelligent format selection and post-generation slide-by-slide revision.

---

## Commands

| Command | Description |
|---------|-------------|
| `/nlm:slides` | Auto-detect format and generate slide deck |
| `/nlm:slides:detailed` | Force detailed_deck format (comprehensive slides with notes) |
| `/nlm:slides:presenter` | Force presenter_slides format (minimal slides for live talk) |
| `/nlm:slides:revise` | Revise specific slides in an existing deck |
| `/nlm:slides:export` | Export slide deck as PDF or PPTX |

## Architecture

```
nlm-slides/
  SKILL.md              ← This file — skill definition + commands
  agents/
    architect.md        ← Presentation Architect agent (format + revision decisions)
  prompts/
    primary.md          ← Main execution flow with studio_revise step
    meta.md             ← Activation triggers and false positives
  references/
    format-matrix.md    ← 5-row selection matrix (SM-01 to SM-05)
    focus-library.md    ← 5 focus prompt templates + meta-prompt
    quality-gate.md     ← Pre/post generation + slide-by-slide review
  templates/
    system-prompts.md   ← 2 Capa 0 system prompts
  evals/
    evals.json          ← 10 test cases including revise flow
```

## Key Differentiator

Unlike other NLM artifact skills, slides support **post-generation revision** via `studio_revise`. After generation:
1. Poll `studio_status` for completion
2. Analyze slide titles/structure
3. Offer targeted slide-by-slide revision suggestions
4. Execute revisions creating a NEW artifact (original preserved)

## Execution Flow

```
1. Detect intent → meta.md triggers
2. Select format → agents/architect.md decision tree
3. Load focus → references/focus-library.md template
4. Pre-check → references/quality-gate.md pre-generation
5. Generate → studio_create(artifact_type="slide_deck", ...)
6. Poll → studio_status until completed
7. Review → quality-gate.md post-generation + slide review
8. Revise → studio_revise if improvements identified (optional)
9. Export → download_artifact or export_artifact
```

## MCP Tools Used

- `notebook_get` — verify sources
- `studio_create` — generate slide deck (artifact_type: "slide_deck")
- `studio_status` — poll generation status
- `studio_revise` — revise individual slides post-generation
- `download_artifact` — download as PDF/PPTX
- `export_artifact` — export to Google Docs

## Format Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `slide_format` | `detailed_deck`, `presenter_slides` | Deck style |
| `slide_length` | `short`, `default` | Number of slides |
| `language` | BCP-47 code | Content language |
| `focus_prompt` | ≤5000 chars | Content guidance |

## allowed-tools

- mcp__notebooklm__notebook_get
- mcp__notebooklm__studio_create
- mcp__notebooklm__studio_status
- mcp__notebooklm__studio_revise
- mcp__notebooklm__download_artifact
- mcp__notebooklm__export_artifact
- mcp__notebooklm__source_add
- mcp__notebooklm__notebook_create
