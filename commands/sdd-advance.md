---
description: "SDD — Auto-advance to the next pipeline phase based on current state"
user-invocable: true
---

# /sdd:advance

Reads pipeline state, determines the next phase, checks gates, and executes — all in one command. Removes the need to remember which phase comes next.

## Execution

**Step 1**: Determine next phase:
```bash
bash scripts/sdd-next-step.sh "$PROJECT_PATH"
```

**Step 2**: Read `context.json` to get `pipeline.completedPhases` and `pipeline.currentPhase`.

**Step 3**: Map the next phase to its command:

| Phase | Command | Skill |
|-------|---------|-------|
| 00 | `/sdd:00-constitution` | `skills/sdd-00-constitution/SKILL.md` |
| 01 | `/sdd:01-specify` | `skills/sdd-01-specify/SKILL.md` |
| 02 | `/sdd:02-plan` | `skills/sdd-02-plan/SKILL.md` |
| 03 | `/sdd:03-checklist` | `skills/sdd-03-checklist/SKILL.md` (Gate G1) |
| 04 | `/sdd:04-testify` | `skills/sdd-04-testify/SKILL.md` |
| 05 | `/sdd:05-tasks` | `skills/sdd-05-tasks/SKILL.md` |
| 06 | `/sdd:06-analyze` | `skills/sdd-06-analyze/SKILL.md` |
| 07 | `/sdd:07-implement` | `skills/sdd-07-implement/SKILL.md` (Gate G2) |
| 08 | `/sdd:08-issues` | `skills/sdd-08-taskstoissues/SKILL.md` (Gate G3) |

**Step 4**: If the next phase has a gate (03, 07, 08), run gate check first:
```bash
bash scripts/sdd-gate-check.sh $PHASE "$PROJECT_PATH"
```
If FAIL: show findings and stop. Do NOT proceed to the skill.

**Step 5**: Execute the skill for the determined phase.

**Step 6**: After execution, mark phase complete:
```bash
bash scripts/sdd-phase-complete.sh $PHASE "$PROJECT_PATH"
```

**Step 7**: Refresh dashboard:
```bash
node scripts/generate-command-center-data.js "$PROJECT_PATH"
```

**Step 8**: Show the NEXT step after this one completes (preview):
```bash
bash scripts/sdd-next-step.sh "$PROJECT_PATH"
```

## Edge Cases

- **No project initialized**: Suggest `/sdd:init`
- **No active feature**: Suggest `/sdd:feature create <name>`
- **All phases complete**: Congratulate and suggest `/sdd:export` or `/sdd:dashboard`
- **Pipeline done**: Show "Feature complete — run /sdd:dod-check to verify Definition of Done"
