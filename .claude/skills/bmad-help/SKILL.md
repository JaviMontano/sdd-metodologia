---
name: bmad-help
description: >-
  This skill should be used when the user asks "what should I do next", "help me with BMAD",
  "where am I in the workflow", "what's my project state", "guide me through BMAD",
  or "recommend next steps". It inspects the project's current state, detects completed
  artifacts and phases, and recommends the next required or optional step with the exact
  skill command to run. Use this skill whenever the user needs context-aware BMAD guidance.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Help — Intelligent Project-State-Aware Guide [EXPLICIT]

Inspect the project's current state, detect what has been completed, and recommend the next required or optional BMAD workflow step with the exact command to run.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). If the user asks a specific BMAD question, answer it directly before providing recommendations.

## Execution Flow

### 1. Scan Project State [EXPLICIT]

Inspect the workspace for BMAD artifacts:

| Artifact | Location | Phase |
|----------|----------|-------|
| Product Brief | `_bmad-output/planning-artifacts/product-brief*` | Phase 1: Analysis |
| Research docs | `_bmad-output/planning-artifacts/*research*` | Phase 1: Analysis |
| PRD | `_bmad-output/planning-artifacts/prd*` | Phase 2: Planning |
| UX Design | `_bmad-output/planning-artifacts/ux-design*` | Phase 2: Planning |
| Architecture | `_bmad-output/planning-artifacts/architecture*` | Phase 3: Solutioning |
| Epics/Stories | `_bmad-output/planning-artifacts/epics*` | Phase 3: Solutioning |
| Readiness Report | `_bmad-output/planning-artifacts/readiness*` | Phase 3: Solutioning |
| Sprint Plan | `_bmad-output/implementation-artifacts/sprint*` | Phase 4: Implementation |
| Story Files | `_bmad-output/implementation-artifacts/*.story.md` | Phase 4: Implementation |
| QA Reports | `_bmad-output/implementation-artifacts/qa-*` | Phase 4: Implementation |

Also check for SDD `.specify/` artifacts to detect hybrid IIKit+BMAD projects.

### 2. Determine Current Phase [EXPLICIT]

Map detected artifacts to BMAD's 4-phase pipeline:
- **Phase 1 (Analysis)**: Optional discovery — brainstorm, research, brief
- **Phase 2 (Planning)**: Required PRD + optional UX design
- **Phase 3 (Solutioning)**: Architecture + stories + readiness gate
- **Phase 4 (Implementation)**: Sprint planning → story cycle → QA

### 3. Generate Recommendations [EXPLICIT]

Present a prioritized list of next steps:

1. **Required steps first** — blocking the pipeline
2. **Recommended steps** — strongly improve quality
3. **Optional steps** — nice to have

For each recommendation, include:
- The exact `/bmad-*` command to run
- Why it's recommended at this point
- What artifact it will produce

### 4. Handle Hybrid Projects [INFERRED]

If both `.specify/` (SDD) and `_bmad-output/` (BMAD) directories exist:
- Note which pipeline the project primarily uses
- Suggest cross-cutting BMAD tools (shard-doc, distillator, elicitation) that complement IIKit
- Never recommend replacing existing IIKit artifacts with BMAD equivalents

### 5. Present Output [EXPLICIT]

Format as a clear status + recommendation report:

```markdown
## 📊 Project State

**Phase**: {current phase} / 4
**Completed**: {list of completed artifacts}
**Pipeline**: {IIKit | BMAD | Hybrid}

## ⏭️ Next Steps

### Required
1. `/bmad-{command}` — {description} → produces {artifact}

### Recommended
2. `/bmad-{command}` — {description}

### Optional
3. `/bmad-{command}` — {description}
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | BMAD artifacts live in `_bmad-output/` | Scan both `_bmad-output/` and project root |
| 2 | User may not have initialized BMAD structure | Suggest `/bmad-brainstorming` or `/bmad-create-prd` as entry points |
| 3 | Project may use IIKit instead of BMAD | Detect `.specify/` and adjust recommendations |
| 4 | Multiple features may exist in parallel | Report state per-feature if possible |
| 5 | User may want general BMAD info, not project help | Check `$ARGUMENTS` for questions vs status requests |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Empty project, no artifacts at all | Suggest starting with `/bmad-brainstorming` or `/bmad-create-prd` |
| 2 | IIKit project, no BMAD artifacts | Recommend cross-cutting tools (shard-doc, distillator, elicitation) |
| 3 | All phases complete | Congratulate, suggest `/bmad-retrospective` |
| 4 | User asks a specific BMAD question | Answer the question first, then show status |
| 5 | Hybrid project with conflicting artifacts | Warn about potential conflicts, recommend alignment |

## Good vs Bad Example

**Good**: User asks "what should I do next" → Skill scans artifacts, finds PRD exists but no architecture → Recommends `/bmad-architect` to create architecture document as next required step.

**Bad**: User asks "what should I do next" → Skill dumps a generic list of all 22 BMAD commands without checking project state.

## Validation Gate [EXPLICIT]

- [ ] V1: Project state was scanned (checked for artifacts in `_bmad-output/` and `.specify/`)
- [ ] V2: Current phase was correctly identified
- [ ] V3: At least one actionable recommendation was provided with exact command
- [ ] V4: Required steps were listed before optional ones
- [ ] V5: Hybrid project detection worked if both SDD and BMAD artifacts exist
- [ ] V6: Output follows the status + recommendation format
