---
name: iikit-06-analyze
description: >-
  Performs cross-artifact validation ensuring specs, plans, tests, and tasks are internally consistent with full traceability. This is GATE G2.
  This skill should be used when the user asks to "validate cross-artifact consistency",
  "check spec-plan-test alignment", "run the analysis gate", "verify traceability",
  or "audit pipeline artifacts".
  It is invoked whenever the user mentions validation, consistency checking,
  or pipeline auditing, even if they do not explicitly ask for "analyze".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Analyze [EXPLICIT]

Non-destructive cross-artifact consistency analysis across spec.md, plan.md, and tasks.md.

## Operating Constraints

- **READ-ONLY** (exceptions: writes `analysis.md` and `.specify/score-history.json`). Never modify spec, plan, or task files.
- **Constitution is non-negotiable**: conflicts are automatically CRITICAL.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (basic mode — ERROR if missing). Extract principle names and normative statements.

## Prerequisites Check

1. Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase 06 --json`
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase 06 -Json`
2. Derive paths: SPEC, PLAN, TASKS from FEATURE_DIR. ERROR if any missing.
3. If JSON contains `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.
4. Checklist gate per [checklist-gate.md](../iikit-core/references/checklist-gate.md).

## Execution Steps

### 0. Pre-Analysis: Generate QA Plan

Before analysis, regenerate the QA Plan to ensure cross-feature quality data is current:
```bash
node "$CLAUDE_PLUGIN_ROOT/scripts/sdd-qa-plan.js" .
```
This updates `QA-PLAN.md` and `.specify/qa-plan.json` with latest DoD status, AC coverage, and gate state. The analysis then uses this data for cross-artifact validation.

### 1. Load Artifacts (Progressive)

From spec.md: overview, requirements, user stories, edge cases.
From plan.md: architecture, data model refs, phases, constraints.
From tasks.md: task IDs, descriptions, phases, [P] markers, file paths.
From qa/acceptance-criteria.md: SC-XXX checkable items (if exists).
From qa/test-coverage.md: FR→TS traceability matrix (if exists).

### 2. Build Semantic Models

- Requirements inventory (functional + non-functional)
- User story/action inventory with acceptance criteria
- Task coverage mapping (task -> requirements/stories)
- Plan coverage mapping (requirement ID → plan.md sections where referenced)
- Constitution rule set

### 3. Detection Passes (limit 50 findings)

**A. Duplication**: near-duplicate requirements -> consolidate
**B. Ambiguity**: vague terms (fast, scalable, secure) without measurable criteria; unresolved placeholders
**C. Underspecification**: requirements missing objects/outcomes; stories without acceptance criteria; tasks referencing undefined components
**D. Constitution Alignment**: conflicts with MUST principles; missing mandated sections. For each principle, report status using these exact values:
- `ALIGNED` — principle satisfied across all artifacts
- `VIOLATION` — principle violated (auto-CRITICAL severity)
**E. Phase Separation Violations**: per [phase-separation-rules.md](../iikit-core/references/phase-separation-rules.md) — tech in constitution, implementation in spec, governance in plan
**F. Coverage Gaps**: requirements with zero tasks; tasks with no mapped requirement; non-functional requirements not in tasks; requirements not referenced in plan.md

> **Plan coverage detection**: Scan plan.md for each requirement ID (FR-xxx, SC-xxx). A requirement is "covered by plan" if its ID appears anywhere in plan.md. Collect contextual refs (KDD-x, section headers) where found.

**G. Inconsistency**: terminology drift; entities in plan but not spec; conflicting requirements

**G2. Prose Range Detection**: Scan tasks.md for patterns like "TS-XXX through TS-XXX" or "TS-XXX to TS-XXX". Flag as MEDIUM finding: "Prose range detected — intermediate IDs not traceable. Use explicit comma-separated list."

**H. Feature File Traceability** (when `FEATURE_DIR/tests/features/` exists):
Parse all `.feature` files in `tests/features/` and extract Gherkin tags:
- `@FR-XXX` — functional requirement references
- `@SC-XXX` — success criteria references
- `@US-XXX` — user story references
- `@TS-XXX` — test specification IDs

**H1. Untested requirements**: For each FR-XXX and SC-XXX in spec.md, check if at least one `.feature` file has a corresponding `@FR-XXX` or `@SC-XXX` tag. Flag any FR-XXX or SC-XXX without a matching tag as "untested requirement" (severity: HIGH).

**H2. Orphaned tags**: For each `@FR-XXX` or `@SC-XXX` tag found in `.feature` files, verify the referenced ID exists in spec.md. Flag tags referencing non-existent IDs as "orphaned traceability tag" (severity: MEDIUM).

**H3. Step definition coverage** (optional): If `tests/step_definitions/` exists alongside `tests/features/`, run `verify-steps.sh` to check for undefined steps:
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/verify-steps.sh --json "FEATURE_DIR/tests/features" "FEATURE_DIR/plan.md"
```
If status is BLOCKED, report undefined steps as findings (severity: HIGH). If DEGRADED, note in report but do not flag as finding.

### 4. Severity

- **CRITICAL**: constitution MUST violations, phase separation, missing core artifact, zero-coverage blocking requirement
- **HIGH**: duplicates, conflicting requirements, ambiguous security/performance, untestable criteria
- **MEDIUM**: terminology drift, missing non-functional coverage, underspecified edge cases
- **LOW**: style/wording, minor redundancy

### 5. Analysis Report

Output to console AND write to `FEATURE_DIR/analysis.md`:

```markdown
## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|

**Constitution Alignment**: principle name -> status (ALIGNED | VIOLATION) -> notes
**Coverage Summary**: requirement key -> has task? -> task IDs -> has plan? -> plan refs
**Phase Separation Violations**: artifact, line, violation, severity
**Metrics**: total requirements, total tasks, coverage %, ambiguity count, critical issues

**Health Score**: <score>/100 (<trend>)

## Score History

| Run | Score | Coverage | Critical | High | Medium | Low | Total |
|-----|-------|----------|----------|------|--------|-----|-------|
| <timestamp> | <score> | <coverage>% | <critical> | <high> | <medium> | <low> | <total_findings> |
```

### 5b. Score History

After computing **Metrics** in step 5, persist the health score:

1. **Compute health score**: `score = 100 - (critical*20 + high*5 + medium*2 + low*0.5)`, floored at 0, rounded to nearest integer.
2. **Read** `.specify/score-history.json`. If the file does not exist, initialize with `{}`.
3. **Append** a new entry for the current feature (keyed by feature directory name, e.g. `001-user-auth`):
   ```json
   { "timestamp": "<ISO-8601 UTC>", "score": <n>, "coverage_pct": <n>, "critical": <n>, "high": <n>, "medium": <n>, "low": <n>, "total_findings": <n> }
   ```
4. **Write** the updated object back to `.specify/score-history.json`.
5. **Determine trend** by comparing the new score to the previous entry (if any):
   - Score increased → `↑ improving`
   - Score decreased → `↓ declining`
   - Score unchanged or no previous entry → `→ stable`
6. **Display** in console output: `Health Score: <score>/100 (<trend>)`
7. **Include** the full `score_history` array for the current feature in `analysis.md` under the **Health Score** line and **Score History** table added in step 5.

### 6. Next Actions

- CRITICAL issues: recommend resolving before `/iikit-07-implement`
- LOW/MEDIUM only: may proceed with improvement suggestions

### 7. Offer Remediation

Ask: "Suggest concrete remediation edits for the top N issues?" Do NOT apply automatically.

## Operating Principles

- Minimal high-signal tokens, progressive disclosure, limit to 50 findings
- Never modify files, never hallucinate missing sections
- Prioritize constitution violations, use specific examples over exhaustive rules
- Report zero issues gracefully with coverage statistics

## Commit

```bash
git add specs/*/analysis.md .specify/score-history.json
git commit -m "analyze: <feature-short-name> consistency report"
```

## Dashboard Refresh

Regenerate the dashboard so the pipeline reflects the analysis results:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```

Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 06 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 06 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. If CRITICAL issues were found: suggest resolving them, then re-run `/iikit-06-analyze`
3. If no CRITICAL: present `next_step` as the primary recommendation
4. If `alt_steps` non-empty: list as alternatives
5. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
6. Append dashboard link

Format:
```
Analysis complete!
[- CRITICAL issues found: resolve, then re-run /iikit-06-analyze]
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

---

## Assumptions and Limits

| # | Assumption / Limit | Rationale |
|---|---|---|
| 1 | All source artifacts (spec.md, plan.md, tasks.md) exist before invocation | Prerequisites script enforces this; skill is read-only and cannot create missing artifacts |
| 2 | Constitution is non-negotiable — violations are always CRITICAL severity | Governance principles override all other artifact content |
| 3 | Maximum 50 findings per analysis run to avoid information overload | Findings beyond 50 are suppressed; user can re-run after fixing top issues |
| 4 | Health score formula is deterministic: `100 - (critical*20 + high*5 + medium*2 + low*0.5)` | Consistent scoring enables trend tracking across runs |
| 5 | Skill writes only `analysis.md` and `.specify/score-history.json` — never modifies source artifacts | Read-only principle ensures analysis never introduces new inconsistencies |

## Edge Cases

| # | Edge Case | Expected Behavior |
|---|---|---|
| 1 | Orphan requirements — FR-NNN in spec.md with no corresponding task in tasks.md | Flagged as HIGH severity coverage gap; listed in Coverage Summary |
| 2 | Orphan tasks — T-NNN in tasks.md referencing a non-existent FR-NNN | Flagged as MEDIUM severity; recommend removing or re-linking the task |
| 3 | Partial pipeline — some phases missing (e.g., no test specs yet) | Analyze available artifacts only; note missing phases as informational findings |
| 4 | All checks pass — zero findings (healthy fast path) | Report zero issues gracefully with full coverage statistics and score 100/100 |
| 5 | Constitution violations detected in plan.md | Auto-CRITICAL severity; recommend resolving before `/iikit-07-implement`; halt gate |

## Good vs Bad Example

**Good output** (structured, actionable, traceable):
```markdown
## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| F-001 | Coverage Gap | HIGH | spec.md:FR-003 | FR-003 has no task in tasks.md | Add task for FR-003 in Phase 3 |
| F-002 | Ambiguity | MEDIUM | spec.md:L42 | "fast response" lacks measurable criteria | Define SLA: < 200ms p95 |

**Health Score**: 85/100 (-> stable)
```

**Bad output** (vague, no IDs, no actionable recommendations):
```
The spec looks mostly fine. There might be some issues with coverage.
Some requirements may not have tasks. The plan seems aligned.
Score: good.
```
Problems: no finding IDs, no severity, no specific locations, no measurable score, no traceability.

## Validation Gate

Before marking this skill invocation as complete, verify ALL of the following:

- [ ] All seven detection passes (A through H) were executed
- [ ] Every finding has an ID, category, severity, location, summary, and recommendation
- [ ] Constitution alignment status reported for every principle (ALIGNED or VIOLATION)
- [ ] Coverage summary table includes every FR-NNN and SC-NNN from spec.md
- [ ] Health score computed and persisted to `.specify/score-history.json`
- [ ] Trend indicator displayed (improving / declining / stable)
- [ ] `analysis.md` written to the correct `FEATURE_DIR` path
