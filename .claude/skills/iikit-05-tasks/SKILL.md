---
name: iikit-05-tasks
description: >-
  Transforms specs and plans into dependency-ordered T-NNN tasks with effort estimates and parallel markers.
  This skill should be used when the user asks to "break down work into tasks",
  "create a task list", "generate implementation tasks", "plan the work breakdown",
  or "produce dependency-ordered tasks".
  It is invoked whenever the user mentions task planning or work breakdown,
  even if they do not explicitly ask for "tasks".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Tasks [EXPLICIT]

Generate an actionable, dependency-ordered tasks.md for the feature.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (basic mode — note TDD requirements for task ordering).

## Prerequisites Check

1. Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase 05 --json`
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase 05 -Json`
2. Parse JSON for `FEATURE_DIR` and `AVAILABLE_DOCS`. If missing plan.md: ERROR. If script exits with testify error: STOP and tell the user to run `/iikit-04-testify` first.
3. If JSON contains `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.
4. Checklist gate per [checklist-gate.md](../iikit-core/references/checklist-gate.md).

## Plan Readiness Validation

1. **Tech stack**: verify plan.md has Language/Version defined (WARNING if missing)
2. **User story mapping**: verify each story in spec.md has acceptance criteria
3. **Dependency pre-analysis**: identify shared entities used by multiple stories -> suggest Foundational phase

Report readiness per [formatting-guide.md](../iikit-core/references/formatting-guide.md) (Plan Readiness section).

## Execution Flow

### 1. Load Documents

- **Required**: `plan.md`, `spec.md`
- **Optional**: `data-model.md`, `contracts/`, `research.md`, `quickstart.md`, `tests/features/` (.feature files)

If .feature files exist (or legacy test-specs.md), tasks reference specific test IDs (e.g., "T012 [US1] Implement to pass TS-001").

### 2. Tessl Convention Consultation

If Tessl installed: query primary framework tile for project structure conventions and testing framework tile for test organization. Apply to file paths and task ordering. If not available: skip silently.

### 3. Generate Tasks

Extract tech stack from plan.md, user stories from spec.md, entities from data-model.md, endpoints from contracts/, decisions from research.md. Organize by user story with dependency graph and parallel markers.

### 4. Task Format (REQUIRED)

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

- Checkbox: always `- [ ]`
- Task ID: sequential (T001, T002...)
- [P]: only if parallelizable (different files, no dependencies)
- [USn]: required for user story tasks only (not Setup/Foundational/Polish)
- Description: clear action with exact file path

**Examples**:
- `- [ ] T001 Create project structure per implementation plan` (setup, no story)
- `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py` (parallel, no story)
- `- [ ] T012 [P] [US1] Create User model in src/models/user.py` (parallel, story)
- `- [ ] T014 [US1] Implement UserService in src/services/user_service.py` (sequential, story)

**Wrong** — missing required elements:
- `- [ ] Create User model` (no ID, no story label)
- `T001 [US1] Create model` (no checkbox)
- `- [ ] [US1] Create User model` (no task ID)

**Traceability**: When referencing multiple test spec IDs, enumerate them explicitly as a comma-separated list. Do NOT use English prose ranges like "TS-005 through TS-010" — these break automated traceability checks.

**Correct**: `[TS-005, TS-006, TS-007, TS-008, TS-009, TS-010]`
**Wrong**: `TS-005 through TS-010`

### 5. Phase Structure

- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundational (blocking prerequisites, complete before stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...) — tests -> models -> services -> endpoints -> integration
- **Final**: Polish & Cross-Cutting Concerns

### 6. Task Organization

Map each component to its user story. Shared entities serving multiple stories go in Setup/Foundational. Each contract gets a contract test task. Story dependencies marked explicitly.

### 7. Dependency Graph Validation

After generating, validate:
1. **Circular dependencies**: detect cycles, ERROR if found with resolution options
2. **Orphan tasks**: warn about tasks with no dependencies and not blocking anything
3. **Critical path**: identify longest chain, suggest parallelization, list parallel batches per phase
4. **Phase boundaries**: no backward cross-phase dependencies
5. **Story independence**: warn on priority inversions (higher-priority depending on lower)

### 8. Write tasks.md

Use [tasks-template.md](../iikit-core/templates/tasks-template.md) with phases, dependencies, parallel examples, and implementation strategy.

## Report

Output: path to tasks.md, total count, count per story, parallel opportunities, MVP scope suggestion, format validation.

## Semantic Diff on Re-run

If tasks.md exists: preserve `[x]` completion status, map old IDs to new by similarity, warn about changes to completed tasks. Ask confirmation before overwriting. Use format from [formatting-guide.md](../iikit-core/references/formatting-guide.md) (Semantic Diff section).

## Commit

```bash
git add specs/*/tasks.md
git commit -m "tasks: <feature-short-name> task breakdown"
```

## Dashboard Refresh

Regenerate the dashboard so the pipeline reflects the new tasks:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```

Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 05 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 05 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

Format:
```
Tasks generated!
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

---

## Assumptions and Limits

| # | Assumption / Limit | Rationale |
|---|---|---|
| 1 | `plan.md` and `spec.md` exist and are well-formed before invocation | Prerequisites script enforces this; skill does not create specs |
| 2 | Task IDs are globally unique within a single feature's `tasks.md` | Sequential T001..T999 allocation; cross-feature uniqueness is not guaranteed |
| 3 | Parallel markers `[P]` are advisory — runtime may fall back to sequential | Not all agent runtimes support subagent dispatch |
| 4 | Effort estimates are rough order-of-magnitude, not contractual | Based on task complexity heuristics, not historical velocity data |
| 5 | Maximum 200 tasks per feature before readability degrades | Beyond this threshold, consider splitting the feature |

## Edge Cases

| # | Edge Case | Expected Behavior |
|---|---|---|
| 1 | Circular task dependencies detected in dependency graph | ERROR with cycle details and resolution options; tasks.md is NOT written |
| 2 | Single-task feature (trivial scope) | Generate a valid tasks.md with one task in Phase 1; skip dependency graph validation |
| 3 | Task references a test spec (TS-NNN) that does not yet exist | WARNING logged; task is still generated with the reference for forward traceability |
| 4 | `plan.md` has no clear implementation steps or phases | WARNING on plan readiness; generate best-effort tasks from spec.md user stories only |
| 5 | `tasks.md` already exists for the feature (re-run scenario) | Semantic diff: preserve `[x]` completion status, map old IDs by similarity, ask confirmation before overwrite |

## Good vs Bad Example

**Good output** (correct format, traceability, phases):
```markdown
## Phase 1: Setup
- [ ] T001 Create project structure per implementation plan

## Phase 2: Foundational
- [ ] T002 [P] Define shared User entity in src/models/user.py
- [ ] T003 [P] Define shared Config entity in src/config.py

## Phase 3: US1 — User Registration
- [ ] T004 [US1] Implement registration endpoint in src/routes/auth.py [TS-001, TS-002]
- [ ] T005 [US1] Add input validation middleware [TS-003]
```

**Bad output** (missing IDs, no phases, prose ranges):
```markdown
- [ ] Create project structure
- [ ] Implement user registration
- [ ] Add tests TS-001 through TS-005
- [ ] Deploy
```
Problems: no task IDs, no phase grouping, no `[USn]` labels, prose range instead of explicit list, no file paths.

## Validation Gate

Before marking this skill invocation as complete, verify ALL of the following:

- [ ] Every task line matches format `- [ ] [TaskID] [P?] [Story?] Description with file path`
- [ ] Task IDs are sequential (T001, T002, ...) with no gaps or duplicates
- [ ] Phase structure is present (Setup, Foundational, User Stories, Polish)
- [ ] Dependency graph validation passed (no circular dependencies)
- [ ] All test spec references use explicit comma-separated IDs (no prose ranges)
- [ ] Semantic diff was performed if `tasks.md` already existed
- [ ] `tasks.md` was written to the correct `FEATURE_DIR` path
