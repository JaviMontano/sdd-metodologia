---
name: notebooklm-for-learning
description: >
  Orchestrate NotebookLM as a structured learning engine. Given any topic,
  generates a 7-dimension knowledge ecosystem (Body of Knowledge, State of the Art,
  Capability Model, Profession Assessment, Maturity Model, Working Prompts,
  GenAI Applications) across 3 progression levels (Zero→Competent, Competent→Versed,
  Versed→Expert). Creates notebooks, runs deep research, imports sources, configures
  AI tutors, and generates multi-modal study artifacts (podcasts, flashcards, quizzes,
  mind maps). Use when: user says "learn about", "study", "become expert in",
  "knowledge ecosystem for", "create learning path", "NLM learn", or invokes /nlm:learn.
license: MIT
metadata:
  version: "1.0.0"
  framework: "7x3 Learning Model"
  engine: "NotebookLM MCP"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - TodoWrite
  - mcp__notebooklm__notebook_create
  - mcp__notebooklm__notebook_get
  - mcp__notebooklm__notebook_list
  - mcp__notebooklm__notebook_query
  - mcp__notebooklm__notebook_rename
  - mcp__notebooklm__notebook_describe
  - mcp__notebooklm__research_start
  - mcp__notebooklm__research_status
  - mcp__notebooklm__research_import
  - mcp__notebooklm__source_add
  - mcp__notebooklm__source_rename
  - mcp__notebooklm__source_describe
  - mcp__notebooklm__source_get_content
  - mcp__notebooklm__chat_configure
  - mcp__notebooklm__studio_create
  - mcp__notebooklm__studio_status
  - mcp__notebooklm__download_artifact
  - mcp__notebooklm__note
  - mcp__notebooklm__tag
context:
  - type: file
    path: references/learning-model.md
  - type: file
    path: references/dimension-prompts.md
  - type: file
    path: references/api-alignment.md
---

# NotebookLM for Learning — Structured Knowledge Ecosystem Builder

## 1. What This Skill Does

Given ANY topic, this skill builds a **complete learning ecosystem** using NotebookLM:

- **7 Dimension Notebooks** — each with deep-researched sources (~40 per dimension)
- **3 Level Notebooks** — configured as AI tutors (beginner, intermediate, expert)
- **1 Hub Notebook** — master index with progress tracking
- **Multi-modal Artifacts** — podcasts, flashcards, quizzes, mind maps, reports per level
- **State Persistence** — resumable across sessions via `nlm-learning-state.json`

**Total**: 11 notebooks, ~280 sources, 9-17 studio artifacts (9 minimum, 17 full suite), 3 configured AI tutors.

## 2. The 7x3 Framework

See `references/learning-model.md` for full model. Summary:

### 7 Dimensions (columns)
| D# | Dimension | Research Focus |
|----|-----------|----------------|
| D1 | Body of Knowledge | Foundational concepts, history, taxonomy, glossary |
| D2 | State of the Art | Latest research, trends, leaders, tools (2024-2026) |
| D3 | Capability Model | Skills taxonomy, competencies, Bloom's mapping |
| D4 | Profession Assessment | Roles, careers, certifications, market demand |
| D5 | Maturity Model | 5-level progression (individual + organizational) |
| D6 | Working Prompts | Practical AI prompts for learning, analysis, creation |
| D7 | GenAI Applications | Current/emerging AI use cases in the domain |

### 3 Levels (rows)
| L# | Level | Progression | Tutor Style |
|----|-------|-------------|-------------|
| L1 | Cero → Competente | Vocabulary, context, fundamentals | Patient, analogies, simple |
| L2 | Competente → Versado | Application, analysis, production | Challenging, trade-offs, projects |
| L3 | Versado → Experto | Innovation, creation, leadership | Peer, frontier, research |

## 3. Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `/nlm:learn <topic>` | — | **Full pipeline**: 7 dimensions + 3 levels + hub |
| `/nlm:learn:dimension <N> <topic>` | `/nlm:dim` | Single dimension deep research |
| `/nlm:learn:level <N> <topic>` | `/nlm:lvl` | Single level notebook + artifacts |
| `/nlm:learn:status` | `/nlm:st` | Show pipeline progress + resumable state |
| `/nlm:learn:artifacts <notebook_id>` | `/nlm:art` | Generate studio artifacts for a notebook |
| `/nlm:learn:hub <topic>` | `/nlm:hub` | Create/update hub notebook with index |
| `/nlm:learn:configure <notebook_id> <level>` | `/nlm:cfg` | Configure AI tutor system prompt |
| `/nlm:learn:resume` | `/nlm:res` | Resume interrupted pipeline from state file |

## 4. Full Pipeline — Execution Flow

### Phase 0: Preparation
```
Input: topic string from user
Actions:
  1. Sanitize topic → generate slug (kebab-case)
  2. Create state file: .specify/nlm-learning-state.json
  3. Create Hub notebook: "{TOPIC} — Learning Hub"
  4. Store hub_notebook_id in state
  5. Tag hub notebook with topic tags
```

### Phase 1: Genesis — 7 Deep Researches (PARALLEL)
```
For each dimension D1..D7:
  1. Create notebook: "{TOPIC} — D{N}: {Dimension Name}"
  2. Store notebook_id in state[dimensions][N]
  3. Build research prompt from references/dimension-prompts.md
  4. Replace {TOPIC} placeholder with user's topic
  5. Launch deep research: mode=deep, source=web
  6. Store task_id in state[dimensions][N].task_id
  7. Mark state: "researching"

PARALLEL EXECUTION: All 7 researches launch simultaneously.
CHECKPOINT: Save state after each launch.
```

### Phase 2: Harvest — Import & Label Sources
```
For each dimension D1..D7 (poll until complete):
  1. Poll research_status (interval=60s, max_wait=600s)
  2. When completed: import all sources
  3. Label sources with dimension prefix: "[D{N}] {title}"
  4. Record source_count in state
  5. Mark state: "harvested"
  6. GATE: if sources < 10, flag as LOW_YIELD → user decision

CHECKPOINT: Save state after each harvest.
```

### Phase 3: Synthesis — Create Level Notebooks
```
For each level L1..L3:
  1. Create notebook: "{TOPIC} — L{N}: {Level Name}"
  2. Store notebook_id in state[levels][N]
  3. Query each D1..D7 notebook with level-appropriate prompt
  4. Add query results as text sources to level notebook
  5. Configure chat with level system prompt (references/studio-recipes.md)
  6. Mark state: "synthesized"

CHECKPOINT: Save state after each level.
```

### Phase 4: Artifacts — Generate Study Materials
```
For each level L1..L3:
  1. Generate audio overview (podcast) with level focus prompt
  2. Generate flashcards (difficulty per level)
  3. Generate quiz (difficulty per level, question_count per level)
  4. Generate mind map
  5. Poll studio_status until all complete
  6. Record artifact_ids in state
  7. Mark state: "artifacts_ready"

CHECKPOINT: Save state after each artifact batch.
```

### Phase 5: Hub — Assemble Master Index
```
  1. Create index note in hub notebook (from templates/notebook-index.md)
  2. Create auto-diagnosis note (from templates/auto-diagnosis.md)
  3. Create study path note (from templates/study-path.md)
  4. Tag all notebooks for cross-query
  5. Mark state: "complete"
  6. Present summary to user with all notebook URLs
```

## 5. State Management

State is persisted in `.specify/nlm-learning-state.json`:

```json
{
  "version": "1.0.0",
  "topic": "string",
  "slug": "string",
  "status": "preparing|researching|harvesting|synthesizing|generating_artifacts|complete",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "hub": {
    "notebook_id": "uuid",
    "url": "string"
  },
  "dimensions": {
    "D1": { "notebook_id": "uuid", "task_id": "uuid", "status": "pending|researching|harvested|error", "source_count": 0 },
    "D2": { "...same..." },
    "...D3-D7..."
  },
  "levels": {
    "L1": { "notebook_id": "uuid", "status": "pending|synthesized|artifacts_ready", "artifacts": {} },
    "L2": { "...same..." },
    "L3": { "...same..." }
  },
  "checkpoints": [
    { "phase": "string", "timestamp": "ISO-8601", "detail": "string" }
  ]
}
```

**Resume Logic**: On `/nlm:learn:resume`, read state file → find last checkpoint → skip completed phases → continue from interruption point.

## 6. Failure Recovery

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Research timeout (>20min) | Poll returns in_progress after max_wait | Retry once; if still stuck, mark dimension as `partial` and continue |
| Low yield (<10 sources) | source_count < 10 after import | Warn user; offer to re-research with refined prompt |
| NotebookLM rate limit | API error 429 | Exponential backoff: 30s, 60s, 120s, then pause and inform user |
| Session interruption | State file has status != "complete" | `/nlm:learn:resume` picks up from last checkpoint |
| Artifact generation failure | studio_status returns "failed" | Retry once; if fails again, skip artifact and log warning |
| Auth expired | Auth error from MCP | Prompt user to run `nlm login` then `/nlm:learn:resume` |

## 7. Quality Gates

| Gate | Phase | Criteria | Action on Fail |
|------|-------|----------|----------------|
| G1 | After Phase 1 | All 7 researches launched | Retry failed launches |
| G2 | After Phase 2 | Per-dimension yield: ≥15 PASS, 10-14 CONCERNS, <10 LOW_YIELD, 0 FAIL | Tiered: warn/re-research/retry |
| G3 | After Phase 2 | Total sources ≥100 | Warn; continue if ≥70 |
| G4 | After Phase 3 | All 3 levels configured with system prompt | Re-configure failed levels |
| G5 | After Phase 4 | Each level has ≥3 artifacts | Retry failed artifacts |
| G6 | After Phase 5 | Hub has index + diagnosis + study path notes | Regenerate missing notes |

## 8. Validation Gate (Output Quality)

- [ ] State file exists and is valid JSON
- [ ] All 11 notebooks created with correct naming convention
- [ ] Each dimension notebook has ≥15 sources (PASS) or ≥10 (CONCERNS acknowledged)
- [ ] Each level notebook has chat configured with system prompt
- [ ] Each level has ≥3 studio artifacts (audio + flashcards + quiz minimum)
- [ ] Hub notebook has index, auto-diagnosis, and study path notes
- [ ] All notebooks tagged for cross-query
- [ ] No dimensions in "error" state (or documented with user acknowledgment)

## 9. Assumptions & Limits

- Requires active NotebookLM MCP connection with valid auth
- Deep research takes 10-20 minutes per dimension (~20 min parallel, ~140 min sequential)
- NotebookLM may rate-limit concurrent researches — skill handles with backoff
- Maximum 300 sources per notebook (NotebookLM limit)
- Studio artifact generation is asynchronous — requires polling
- State file enables cross-session resume but does NOT survive NotebookLM account changes
- Topic must be specific enough for meaningful research (not "everything about science")

## 10. Reference Index

| Need | Read |
|------|------|
| 7x3 model, levels, routes, quality gates | `references/learning-model.md` |
| Deep research prompts per dimension | `references/dimension-prompts.md` |
| Studio recipes, system prompts, note templates | `references/studio-recipes.md` |
| State file schema | `references/state-schema.md` |
| Notebook naming conventions | `references/naming-conventions.md` |
| NotebookLM MCP tool signatures | `references/api-alignment.md` |
| Automation rails (agent-executed) | `scripts/bash/nlm-*.sh` |
