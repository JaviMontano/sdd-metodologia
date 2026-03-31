---
name: iikit-03-checklist
description: >-
  This skill should be used when the user asks to "review requirements quality",
  "generate a quality checklist", "audit the specification", "verify BDD readiness",
  or "check requirement completeness".
  It generates structured checklists that validate spec and plan quality
  before proceeding to test generation.
  Use this skill whenever the user wants quality assurance on specifications,
  even if they don't explicitly ask for "checklist".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Checklist [EXPLICIT]

Generate "Unit Tests for English" — checklists that validate REQUIREMENTS quality, not implementation.

## Core Principle

Every checklist item evaluates the **requirements themselves** for completeness, clarity, consistency, measurability, and coverage. Items MUST NOT test implementation behavior.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (basic mode).

## Prerequisites Check

1. Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase 03 --json`
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase 03 -Json`
2. Parse JSON for `FEATURE_DIR` and `AVAILABLE_DOCS`.
3. If JSON contains `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.

## Execution Steps

### 1. Clarify Intent

Derive up to THREE contextual questions (skip if unambiguous from `$ARGUMENTS`):
- Scope: include integration touchpoints?
- Risk: which areas need mandatory gating?
- Depth: lightweight sanity list or formal release gate?
- Audience: author-only or peer PR review?

### 2. Load Feature Context

Read from FEATURE_DIR: `spec.md` (required), `plan.md` (optional), `tasks.md` (optional).

### 3. Generate Checklist

**Starting point**: `FEATURE_DIR/checklists/requirements.md` already exists (created by `/iikit-01-specify`). Review it, extend it with additional items, and resolve gaps. Do NOT create a duplicate — work with the existing file.

**Additional domain checklists** (optional): if the spec has distinct domains that warrant separate review (e.g., security, performance, accessibility), create additional files as `FEATURE_DIR/checklists/[domain].md`. These supplement `requirements.md`, not replace it.

**Item structure**: question format about requirement quality, with quality dimension tag and spec reference.

Correct: "Are visual hierarchy requirements defined with measurable criteria?" [Clarity, Spec SFR-1]
Wrong: "Verify the button clicks correctly" (this tests implementation)

**Categories**: Requirement Completeness, Clarity, Consistency, Acceptance Criteria Quality, Scenario Coverage, SC-XXX Test Coverage, Edge Case Coverage, Non-Functional Requirements, Dependencies & Assumptions.

**Traceability**: >=80% of items must reference spec sections or use markers: `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`.

See [checklist-examples.md](references/checklist-examples.md) for correct/wrong examples and required patterns.

Use [checklist-template.md](../iikit-core/templates/checklist-template.md) for format structure.

### 4. Gap Resolution (Interactive)

For each `[Gap]` item: follow the gap resolution pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). Present missing requirement, explain risk, offer options. On resolution: update spec.md and check item off. Skip if `--no-interactive` or no gaps.

### 5. Remaining Item Validation

After gap resolution, validate ALL unchecked `[ ]` items against spec/plan/constitution:
- If covered: check off with justification
- If genuine gap: convert to `[Gap]` and resolve or defer

Continue until all items are `[x]` or explicitly deferred.

**IMPORTANT**: Checklists are optional — not creating one is fine. But once created, they MUST reach 100% before the skill reports success.

### 6. Report

Output: checklist path, item counts (total/checked/deferred), gap resolution summary, completion percentage.

## Commit

```bash
git add specs/*/checklists/ .specify/context.json
git commit -m "checklist: <feature-short-name> requirements review"
```

## Record Phase Completion

Write a timestamp to `.specify/context.json` so the dashboard knows the checklist phase was run (not just that requirements.md exists from specify):

```bash
CONTEXT_FILE=".specify/context.json"
[[ -f "$CONTEXT_FILE" ]] || echo '{}' > "$CONTEXT_FILE"
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.checklist_reviewed_at = $ts' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
```

## Dashboard Refresh

Regenerate the dashboard so the pipeline reflects checklist completion:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```

Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 03 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 03 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

If deferred items remain, warn that downstream skills will flag incomplete checklists.

Format:
```
Checklist complete!
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

---

## Assumptions and Limits

| # | Assumption / Limit | Impact if Violated |
|---|---|---|
| 1 | spec.md exists with at least 1 FR-XXX requirement before checklist runs | Skill halts at prerequisites; user must run `/iikit-01-specify` first |
| 2 | Checklist items evaluate REQUIREMENTS quality, never implementation behavior | Items testing implementation pollute the quality gate and give false confidence |
| 3 | >= 80% of checklist items must reference spec sections (FR-XXX, SC-XXX) | Low traceability makes the checklist useless for downstream verification |
| 4 | Once created, checklists MUST reach 100% before skill reports success | Partial checklists block pipeline progression; deferred items emit warnings |
| 5 | requirements.md is created by `/iikit-01-specify` and extended here (not duplicated) | Duplicate checklists cause confusion and divergent quality tracking |

## Edge Cases

| # | Edge Case | Expected Behavior |
|---|---|---|
| 1 | Spec has only 1 FR (minimal checklist) | Generates minimal but complete checklist; warns about low coverage; suggests expanding spec |
| 2 | Plan references technologies not in constitution | Flags as `[Conflict]` item; recommends updating constitution or revising plan before proceeding |
| 3 | All checklist items pass immediately (no gaps) | Reports 100% and proceeds; no interactive gap resolution needed |
| 4 | Checklist reveals critical gaps requiring `/iikit-clarify` | Halts gap resolution; recommends `/iikit-clarify` for unresolvable gaps; defers those items |
| 5 | Checklist run on partial spec (some FRs marked "NEEDS CLARIFICATION") | Generates checklist for resolved FRs; marks unresolved FRs as `[Gap]` with explicit deferral |

## Good vs Bad Example

**Good Example** -- checklist with specific pass/fail items linked to FR/SC references:

```markdown
## Requirement Completeness
- [x] FR-001 defines measurable success criteria (response time < 200ms) [Clarity, Spec FR-001]
- [x] SC-001 covers happy path AND error scenarios [Coverage, Spec SC-001]
- [ ] FR-003 missing edge case for concurrent access [Gap, Spec FR-003]

## Acceptance Criteria Quality
- [x] Each user story has at least 2 acceptance scenarios [Coverage, Stories US-001..US-005]
- [ ] SC-004 uses vague language "should work correctly" — needs measurable criteria [Ambiguity, Spec SC-004]
```

**Bad Example** -- generic checklist with no traceability:

```markdown
## Quality Review
- [x] Looks good overall
- [x] Requirements seem complete
- [x] No obvious issues
- [x] Ready for development
```

Why it fails: No FR/SC references, no quality dimension tags, no specific items, no gap markers, impossible to trace which requirements were actually validated.

## Validation Gate

Before marking this skill complete, verify ALL of the following:

- [ ] requirements.md exists in `FEATURE_DIR/checklists/` (extended, not duplicated)
- [ ] >= 80% of checklist items reference specific spec sections (FR-XXX, SC-XXX)
- [ ] Every item has a quality dimension tag (Completeness, Clarity, Consistency, Coverage, etc.)
- [ ] All `[Gap]` items are either resolved (checked off) or explicitly deferred with justification
- [ ] Checklist completion is 100% (all items `[x]` or deferred)
- [ ] No implementation-testing items present (checklist evaluates requirements, not code)
- [ ] `checklist_reviewed_at` timestamp written to `.specify/context.json`
- [ ] Git commit created with checklist artifacts
