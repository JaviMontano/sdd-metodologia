---
name: nlm-learning-primary
type: execution
version: 1.0.0
description: "Execute the NLM for Learning full pipeline or subcommand."
triad:
  lead: "nlm-learning-lead"
  support: "nlm-learning-support"
  guardian: "nlm-learning-guardian"
---

# NLM for Learning — Execute

## Dynamic Parameters

| Parameter | Description | Required | Filled By |
|-----------|-------------|----------|-----------|
| `{{topic}}` | Subject to learn about | Yes | User input |
| `{{command}}` | Subcommand (learn, dimension, level, status, resume, artifacts, hub, configure) | No | Parsed from input, default: learn |
| `{{dimension}}` | Dimension number (1-7) for /nlm:learn:dimension | No | User input |
| `{{level}}` | Level number (1-3) for /nlm:learn:level | No | User input |
| `{{notebook_id}}` | Target notebook for artifacts/configure | No | State file or user input |

## Execution Steps

### Step 1: Parse Command
1. Extract topic from user input
2. Determine subcommand (full pipeline, single dimension, single level, status, resume)
3. Check for existing state file (.specify/nlm-learning-state.json)
4. If state exists and command is not explicit, offer: continue vs start fresh

### Step 2: User Confirmation
Before launching pipeline, confirm with user:
- Topic understood correctly
- Approximate time: ~25 min parallel, ~2h sequential
- Will create 11 notebooks in NotebookLM
- Will generate ~15 studio artifacts (requires confirm=true)
- **Get explicit user approval before proceeding**

### Step 3: Execute Pipeline
Route to appropriate phase based on command:
- `/nlm:learn <topic>` → Full pipeline (Phase 0-5)
- `/nlm:learn:dimension <N> <topic>` → Phase 1-2 for dimension N only
- `/nlm:learn:level <N> <topic>` → Phase 3-4 for level N only
- `/nlm:learn:status` → Read state, report progress
- `/nlm:learn:resume` → Read state, continue from last checkpoint
- `/nlm:learn:artifacts <notebook_id>` → Phase 4 for specified notebook
- `/nlm:learn:hub <topic>` → Phase 5 only
- `/nlm:learn:configure <notebook_id> <level>` → Configure AI tutor

### Step 4: Quality Gates
After each phase, run guardian validation:
- G1 after Phase 1: All researches launched
- G2 after Phase 2: Source yield per dimension ≥10
- G3 after Phase 2: Total sources ≥100
- G4 after Phase 3: All levels configured
- G5 after Phase 4: Artifacts generated per level ≥3
- G6 after Phase 5: Hub complete with index + diagnosis + path

### Step 5: Delivery
Present to user:
- Summary table of all notebooks with URLs and source counts
- Study path recommendation (L1 → L2 → L3)
- Quick-start suggestion: "Listen to the L1 podcast first"
- State file location for future resume
