# NLM for Learning — State Schema

> Persistent state file: `.specify/nlm-learning-state.json`
> Enables cross-session resume, progress tracking, and checkpoint recovery.

## Schema v1.0.0

```json
{
  "version": "1.0.0",
  "topic": "BMAD Method para desarrollo con IA",
  "slug": "bmad-method-ia",
  "status": "preparing|researching|harvesting|synthesizing|generating_artifacts|complete",
  "mode": "standard|express|deep",
  "created_at": "2026-03-30T17:00:00Z",
  "updated_at": "2026-03-30T17:45:00Z",

  "hub": {
    "notebook_id": "uuid-here",
    "url": "https://notebooklm.google.com/notebook/uuid-here",
    "notes": {
      "index": "note-uuid|null",
      "diagnosis": "note-uuid|null",
      "study_path": "note-uuid|null"
    }
  },

  "dimensions": {
    "D1": {
      "name": "Body of Knowledge",
      "notebook_id": "uuid|null",
      "url": "string|null",
      "task_id": "uuid|null",
      "status": "pending|creating|researching|importing|harvested|error|timeout",
      "source_count": 0,
      "error": "string|null",
      "started_at": "ISO-8601|null",
      "completed_at": "ISO-8601|null"
    },
    "D2": { "name": "State of the Art", "...same_schema..." : "..." },
    "D3": { "name": "Capability Model", "...same_schema..." : "..." },
    "D4": { "name": "Profession Assessment", "...same_schema..." : "..." },
    "D5": { "name": "Maturity Model", "...same_schema..." : "..." },
    "D6": { "name": "Working Prompts", "...same_schema..." : "..." },
    "D7": { "name": "GenAI Applications", "...same_schema..." : "..." }
  },

  "levels": {
    "L1": {
      "name": "Cero a Competente",
      "notebook_id": "uuid|null",
      "url": "string|null",
      "status": "pending|creating|synthesizing|configuring|generating_artifacts|artifacts_ready|error",
      "chat_configured": false,
      "artifacts": {
        "audio": { "id": "uuid|null", "status": "pending|generating|completed|failed" },
        "flashcards": { "id": "uuid|null", "status": "..." },
        "quiz": { "id": "uuid|null", "status": "..." },
        "mind_map": { "id": "uuid|null", "status": "..." }
      },
      "completed_at": "ISO-8601|null"
    },
    "L2": { "name": "Competente a Versado", "...same_schema..." : "..." },
    "L3": { "name": "Versado a Experto", "...same_schema..." : "..." }
  },

  "checkpoints": [
    {
      "phase": "Phase 0: Preparation",
      "timestamp": "2026-03-30T17:00:00Z",
      "detail": "Hub notebook created: uuid-here"
    },
    {
      "phase": "Phase 1: Genesis",
      "timestamp": "2026-03-30T17:01:00Z",
      "detail": "D1 research launched: task-uuid"
    }
  ],

  "gates": {
    "G1_research_launch": { "passed": false, "checked_at": null, "details": "" },
    "G2_source_yield": { "passed": false, "checked_at": null, "details": "" },
    "G3_total_sources": { "passed": false, "checked_at": null, "details": "" },
    "G4_tutor_config": { "passed": false, "checked_at": null, "details": "" },
    "G5_artifacts": { "passed": false, "checked_at": null, "details": "" },
    "G6_hub_complete": { "passed": false, "checked_at": null, "details": "" }
  },

  "metrics": {
    "total_sources": 0,
    "total_artifacts": 0,
    "total_notebooks": 0,
    "pipeline_duration_minutes": 0
  }
}
```

## Resume Logic

```
1. Read state file
2. Check status field:
   - "preparing" → restart from Phase 0
   - "researching" → check each D status, relaunch pending/error
   - "harvesting" → check each D status, import completed researches
   - "synthesizing" → check each L status, create missing levels
   - "generating_artifacts" → check each L artifact status, regenerate failed
   - "complete" → inform user, offer re-run or updates
3. Find last checkpoint timestamp
4. Skip all phases before last checkpoint
5. Continue from interruption point
```

## State File Location Priority

1. `.specify/nlm-learning-state.json` (primary)
2. Active workspace `rag/nlm-learning-state.json` (if workspace active)
3. User-specified path via `--state-file` argument
