---
name: iikit-clarify
description: >-
  This skill should be used when the user asks to "resolve ambiguities",
  "clarify requirements", "fix unclear specs", "disambiguate stories",
  or "refine vague acceptance criteria". It auto-detects the most recent artifact
  (spec, plan, checklist, testify, tasks, or constitution), asks targeted questions
  with option tables, and writes answers back into the artifact's Clarifications section.
  Use this skill whenever the user mentions unclear requirements, vague criteria,
  trade-off gaps, or needs to sharpen any pipeline artifact.
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Clarify (Generic Utility) [EXPLICIT]

Ask targeted clarification questions to reduce ambiguity in the detected (or user-specified) artifact, then encode answers back into it.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

If the user provides a target argument (e.g., `plan`, `spec`, `checklist`, `testify`, `tasks`, `constitution`), use that artifact instead of auto-detection.

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (soft mode — parse if exists, continue if not).

## Prerequisites Check

1. Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase clarify --json`
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase clarify -Json`
2. Parse JSON. If `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.
3. Determine the target artifact (see "Target Detection" below).

## Target Detection

If the user provided a target argument, map it:

| Argument | Artifact file |
|----------|--------------|
| `spec` | `{FEATURE_DIR}/spec.md` |
| `plan` | `{FEATURE_DIR}/plan.md` |
| `checklist` | `{FEATURE_DIR}/checklists/*.md` (all files) |
| `testify` | `{FEATURE_DIR}/tests/features/*.feature` (read for scanning), `{FEATURE_DIR}/tests/clarifications.md` (write Q&A) |
| `tasks` | `{FEATURE_DIR}/tasks.md` |
| `constitution` | `{REPO_ROOT}/CONSTITUTION.md` |

If no argument, auto-detect by checking artifacts in reverse phase order. Pick the first that exists:

1. `{FEATURE_DIR}/tasks.md`
2. `{FEATURE_DIR}/tests/features/*.feature`
3. `{FEATURE_DIR}/checklists/*.md`
4. `{FEATURE_DIR}/plan.md`
5. `{FEATURE_DIR}/spec.md`
6. `{REPO_ROOT}/CONSTITUTION.md`

If no clarifiable artifact exists: ERROR with `No artifacts to clarify. Run /iikit-01-specify first or /iikit-00-constitution.`

## Execution Steps

### 1. Scan for Ambiguities

Load the target artifact and perform a structured scan using the taxonomy for that artifact type from [ambiguity-taxonomies.md](../iikit-core/references/ambiguity-taxonomies.md). Mark each area: Clear / Partial / Missing.

### 2. Generate Question Queue

**Constraints**:
- Each answerable with multiple-choice (2-5 options) OR short phrase (<=5 words)
- Identify related artifact items for each question:
  - Spec: FR-xxx, US-x, SC-xxx
  - Plan: section headers or decision IDs
  - Checklist: check item IDs
  - Testify: scenario names
  - Tasks: task IDs (T-xxx)
  - Constitution: principle names or section headers
- Only include questions that materially impact downstream phases
- Balance category coverage, exclude already-answered, favor downstream rework reduction

### 3. Sequential Questioning

Present ONE question at a time.

**For multiple-choice**: follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). Analyze options, state recommendation with reasoning, render options table. User can reply with letter, "yes"/"recommended", or custom text.

**After answer**: validate against constraints, record, move to next.

**Stop when**: all critical ambiguities resolved or user signals done.

### 4. Integration After Each Answer

1. Ensure `## Clarifications` section exists in the target artifact with `### Session YYYY-MM-DD` subheading
2. Append: `- Q: <question> -> A: <answer> [<refs>]`
   - References MUST list every affected item in the artifact
   - If cross-cutting, reference all materially affected items
3. Apply clarification to the appropriate section of the artifact
4. **Save artifact after each integration** to minimize context loss

**Testify exception**: `.feature` files are Gherkin syntax — do NOT add markdown sections to them. Instead:
- **Scan** `.feature` files for ambiguities (step 1)
- **Write** Q&A to `{FEATURE_DIR}/tests/clarifications.md` (create if missing)
- **Apply** changes to the `.feature` files themselves (update scenarios, add/remove steps)

See [clarification-format.md](references/clarification-format.md) for format details.

### 5. Validation

After each write and final pass:
- One bullet per accepted answer, each ending with `[refs]`
- All referenced IDs exist in the artifact
- No vague placeholders or contradictions remain

### 6. Report

Output: questions asked/answered, target artifact and path, sections touched, traceability summary table (clarification -> referenced items), coverage summary (category -> status), suggested next command.

**Next command logic**: run `check-prerequisites.sh --json status` and use its `next_step` field. This returns the actual next phase based on feature state (which artifacts exist), not what was just clarified. Clarify can run at any point — the next step depends on where the feature is, not where clarify was invoked.

## Behavior Rules

- No meaningful ambiguities found: "No critical ambiguities detected." and suggest proceeding
- Continue until all critical ambiguities are resolved
- Avoid speculative tech stack questions unless absence blocks functional clarity
- Respect early termination signals ("stop", "done", "proceed")
- For non-spec artifacts, adapt reference format to the artifact's native ID scheme

## Commit

Commit the modified artifact(s):

```bash
git add -u
git commit -m "clarify: <target-artifact> Q&A"
```

## Dashboard Refresh

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase clarify --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase clarify -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding (always true for clarify — Q&A sessions consume significant context)
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

Format:
```
Clarification complete!
Next: /clear → <next_step>
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Target artifact must exist before clarifying | If artifact missing, suggest the appropriate `/iikit-*` command to create it first. [EXPLICIT] |
| 2 | Clarification does not modify original artifact content — only appends to Clarifications section | Preserves all existing content; answers are additive. [EXPLICIT] |
| 3 | User confirmation required before writing resolutions | Present options, wait for selection, then write. Never auto-resolve. [EXPLICIT] |
| 4 | Supports all artifact types: spec, plan, checklist, testify, tasks, constitution | Auto-detection prioritizes most recent artifact. User can override with explicit path. [EXPLICIT] |
| 5 | context.json tracks clarification status per feature | Updated after each clarification session. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No artifacts exist in project | specs/ empty, no CONSTITUTION.md | Suggest `/iikit-core init` or `/iikit-01-specify` to create first artifact. [EXPLICIT] |
| Circular ambiguities | Resolution of A depends on B which depends on A | Flag circular dependency, suggest resolving the most foundational ambiguity first. [INFERRED] |
| Conflicting stakeholder inputs | Multiple answers contradict each other | Present conflicts explicitly, ask user to choose or create synthesis. Never silently pick one. [EXPLICIT] |
| Already-clarified artifact re-clarification | Clarifications section already has entries | Append new clarifications without modifying existing ones. [EXPLICIT] |
| Ambiguity in constitution principles | CONSTITUTION.md has vague governance rules | Treat as highest-priority clarification — constitution ambiguity propagates to all downstream artifacts. [EXPLICIT] |

## Good vs Bad Example

**Good**: User runs `/iikit-clarify` and gets targeted questions
```
Detected: spec.md for 001-user-auth (most recent artifact)

Ambiguities found (3):
  1. FR-003: "fast response time" — what threshold? Options:
     A) < 200ms p95  B) < 500ms p95  C) < 1s p95
  2. SC-005: "appropriate error message" — what content?
     A) Technical details  B) User-friendly only  C) Both with toggle
  3. FR-007: "admin users" — who qualifies?
     A) Role-based (RBAC)  B) Email domain  C) Manual assignment

→ Select options to resolve (e.g., "1A 2B 3A")
```

**Bad**: Clarification with vague questions
```
✗ "The spec needs more detail" — no specific ambiguities identified
✗ No options presented for resolution
✗ No artifact auto-detection
```

**Why**: Clarify must identify specific ambiguities with evidence from the artifact, present concrete options for resolution, and write answers back. [EXPLICIT]

## Validation Gate

Before marking clarification as complete, verify: [EXPLICIT]

- [ ] V1: Target artifact detected or specified by user
- [ ] V2: Ambiguities identified with specific references (FR-NNN, SC-NNN)
- [ ] V3: Resolution options presented for each ambiguity
- [ ] V4: User confirmed selections before writing
- [ ] V5: Clarifications section updated in target artifact
- [ ] V6: context.json updated with clarification status
- [ ] V7: No new ambiguities introduced by resolutions
