# SDD Skill Taxonomy

Classification of all SDD skill types. Use this to determine the correct phase, naming convention, and integration pattern for new skills. [EXPLICIT]

## Skill Categories

### Pipeline Phase Skills (iikit-00 to iikit-08)

Sequential phases in the SDD pipeline. Each produces specific artifacts. [EXPLICIT]

| Phase | Skill | Command | Produces | Gate |
|-------|-------|---------|----------|------|
| 0 | iikit-00-constitution | /sdd:00-constitution | CONSTITUTION.md | — |
| 1 | iikit-01-specify | /sdd:01-specify | spec.md (FR-NNN, SC-NNN) | — |
| 2 | iikit-02-plan | /sdd:02-plan | plan.md, contracts/ | G1 |
| 3 | iikit-03-checklist | /sdd:03-checklist | checklists/ | — |
| 4 | iikit-04-testify | /sdd:04-testify | *.feature (assertion hashes) | — |
| 5 | iikit-05-tasks | /sdd:05-tasks | tasks.md (T-NNN) | — |
| 6 | iikit-06-analyze | /sdd:06-analyze | analysis report | G2 |
| 7 | iikit-07-implement | /sdd:07-implement | source code | G3 |
| 8 | iikit-08-taskstoissues | /sdd:08-issues | GitHub Issues | — |

Naming: `iikit-{NN}-{name}` where NN is the phase number. [EXPLICIT]

### Utility Skills

Support skills that don't belong to a specific pipeline phase. [EXPLICIT]

| Skill | Command | Purpose |
|-------|---------|---------|
| iikit-core | /sdd:core, /sdd:init | Project init, status, feature selection |
| iikit-clarify | /sdd:clarify | Resolve ambiguities in any artifact |
| iikit-bugfix | /sdd:bugfix | Bug report and fix workflow |
| sdd-skill-forge | /sdd:skill-forge | Create and audit skills |

Naming: `iikit-{name}` or `sdd-{name}` for SDD-specific. [EXPLICIT]

### Intelligence Skills (ambient, zero LLM cost)

Skills that operate via hooks for continuous monitoring. [EXPLICIT]

| Skill | Trigger | Scripts |
|-------|---------|---------|
| Sentinel | /sdd:sentinel | sdd-sentinel.sh (738 lines) |
| Heartbeat | Per-prompt hook | sdd-heartbeat-lite.sh (117 lines) |
| Insights | /sdd:insights | sdd-insights.js |
| Knowledge Graph | /sdd:graph | sdd-knowledge-graph.js |

### Experience Skills

Onboarding, demo, and discovery skills. [EXPLICIT]

| Skill | Command | Purpose |
|-------|---------|---------|
| Tour | /sdd:tour | 8-step guided onboarding |
| Demo | /sdd:demo | Generate demo project + dashboard |
| Seed | /sdd:seed | Seed demo data without dashboard |

## Integration Patterns

### Constitution Loading

Every pipeline skill (phases 1-8) must load the Constitution. Three modes: [EXPLICIT]

| Mode | When | Behavior |
|------|------|----------|
| basic | Phase 0 (constitution itself) | Read principles only |
| soft | Phases 1-3 (specification) | Warn if missing, proceed |
| enforcement | Phases 4-8 (execution) | Block if violations detected |

### Prerequisite Checking

All skills call `check-prerequisites.sh` to verify: [EXPLICIT]
- Required artifacts exist (spec.md for plan, plan.md for testify, etc.)
- Active feature is selected
- Constitution is loaded (if required)
- Previous phase completed

### Next Step Recommendation

All skills call `next-step.sh --phase {NN} --json` to suggest: [EXPLICIT]
- Next command in pipeline
- Alternative steps
- Model tier recommendation (opus vs sonnet vs haiku)
- Whether to suggest `/clear`

## Dependency Graph

```
constitution (0) → specify (1) → plan (2) → checklist (3) → testify (4) → tasks (5) → analyze (6) → implement (7) → issues (8)
                         ↑                                                                    ↑
                    clarify (any)                                                     bugfix (any)
```

Phase separation is strict: artifacts from phase N are immutable once phase N+1 begins.
Changes require `/sdd:clarify` to propagate downstream. [EXPLICIT]
