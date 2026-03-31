---
name: iikit-01-specify
description: >-
  This skill should be used when the user asks to "create a feature specification",
  "write user stories", "define requirements", "capture acceptance criteria", or "document functional requirements".
  It transforms natural language into structured specs with FR-NNN identifiers, SC-NNN scenarios, and full traceability.
  Use this skill whenever the user describes a feature, even if they don't explicitly ask for "specify".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Specify [EXPLICIT]

Create or update a feature specification from a natural language description.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (soft mode — warn if missing, proceed without).

## Execution Flow

The text after `/iikit-01-specify` **is** the feature description.

### 0. Bug-Fix Intent Detection

Before proceeding with feature specification, analyze the user description for bug-fix intent using **contextual analysis** (not keyword-only):

**Bug-fix signals** (keywords in a fixing context): "fix", "crash", "broken", "bug", "doesn't work", "fails", "error" when used to describe existing broken behavior.

**NOT bug-fix** (keywords in a new-feature context): "Add error handling", "Implement crash recovery", "Create bug tracking" — these describe new capabilities, not fixes to existing behavior.

**Decision rule**: Is the primary intent to **fix existing broken behavior** or to **add new capability**? Keywords alone are insufficient — evaluate the full description.

If bug-fix intent is detected:
1. Display: "This sounds like a bug fix. Consider using `/iikit-bugfix` instead."
2. Show example: `/iikit-bugfix '<the user description>'`
3. Ask the user to confirm: proceed with specification (it's genuinely a new feature) or switch to `/iikit-bugfix`
4. If the user confirms it is a new feature: proceed to Step 1
5. If the user wants bugfix: stop and suggest they run `/iikit-bugfix`

### 1. Generate Branch Name

Create 2-4 word action-noun name from description:
- "I want to add user authentication" -> "user-auth"
- "Implement OAuth2 integration for the API" -> "oauth2-api-integration"

### 2. Create Feature Branch and Directory

Check current branch. If on main/master/develop, suggest creating feature branch (default). If already on feature branch, suggest skipping.

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/create-new-feature.sh --json "$ARGUMENTS" --short-name "your-short-name"
# Add --skip-branch if user declined branch creation
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS" -ShortName "your-short-name"
# Add -SkipBranch if user declined
```

Parse JSON for `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`. Only run ONCE per feature.

### 3. Generate Specification

1. Parse user description — if empty: ERROR with usage example
2. Extract key concepts: actors, actions, data, constraints
3. For unclear aspects: make informed guesses. Only use `[NEEDS CLARIFICATION: question]` (max 3) when choice significantly impacts scope and no reasonable default exists
4. Fill User Scenarios with independently testable stories (P1, P2, P3 priorities)
5. Generate Functional Requirements (testable, with reasonable defaults)
6. Define Success Criteria (measurable, technology-agnostic)
7. Identify Key Entities (if data involved)

Write to `SPEC_FILE` using [spec-template.md](../iikit-core/templates/spec-template.md) structure.

### 4. Phase Separation Validation

Scan for implementation details per [phase-separation-rules.md](../iikit-core/references/phase-separation-rules.md) (Specification section). Auto-fix violations, re-validate until clean.

### 5. Create Spec Quality Checklist

Generate `FEATURE_DIR/checklists/requirements.md` covering: content quality (no implementation details), requirement completeness, feature readiness.

### 5b. Generate QA Acceptance Criteria

Generate `FEATURE_DIR/qa/acceptance-criteria.md` from the spec's SC-XXX success criteria:

```markdown
# Acceptance Criteria — {Feature Name}
Generated from spec.md | {date}

## Success Criteria Checklist
- [ ] SC-001: {description} — Target: {measurable target}
- [ ] SC-002: {description} — Target: {measurable target}
...

## Traceability
| SC | Linked FR | Verifiable By |
|----|-----------|---------------|
| SC-001 | FR-001, FR-002 | Unit test / E2E |
```

Each SC-XXX from spec.md becomes a checkable acceptance criterion with a measurable target.

### 6. Handle Clarifications

If `[NEEDS CLARIFICATION]` markers remain, present each as a question with options table and wait for user response.

### 7. Report

Output: branch name, spec file path, checklist results, readiness for next phase.

## Guidelines

- Focus on **WHAT** users need and **WHY** — avoid HOW
- Written for business stakeholders, not developers
- Success criteria: measurable, technology-agnostic, user-focused, verifiable

## Semantic Diff on Re-run

If spec.md already exists: extract semantic elements (stories, requirements, criteria), compare with new content per [formatting-guide.md](../iikit-core/references/formatting-guide.md) (Semantic Diff section), show downstream impact warnings, ask confirmation before overwriting.

## Commit

```bash
git add specs/*/spec.md specs/*/checklists/requirements.md .specify/active-feature
git commit -m "spec: <feature-short-name> specification"
```

## Dashboard Refresh

Regenerate the dashboard so the pipeline reflects the new spec:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 01 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 01 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

Format:
```
Specification complete!
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | PREMISE.md and CONSTITUTION.md exist before specification begins | Prerequisite check warns if missing; soft constitution loading allows proceeding with warning. [EXPLICIT] |
| 2 | User input is in natural language (not structured format) | Parser extracts intent regardless of format; structured inputs are passed through. [EXPLICIT] |
| 3 | Each feature gets a unique NNN identifier (zero-padded, 3 digits) | Auto-incremented from existing specs/ directories. Collisions detected and rejected. [EXPLICIT] |
| 4 | Functional requirements use FR-NNN format; scenarios use SC-NNN | Strict format enforced in spec template. Non-conforming IDs are rejected during validation. [EXPLICIT] |
| 5 | Bash 3.2+ (macOS default) for all scripts | No Bash 4+ features used. PowerShell equivalents provided for Windows. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| User describes a bug fix, not a feature | Keywords: "bug", "fix", "broken", "regression", "error" in input | Redirect to `/iikit-bugfix` instead of creating a specification. [EXPLICIT] |
| Feature description is too vague (< 20 words) | Word count check on user input | Ask clarifying questions before proceeding. Suggest using `/iikit-clarify` for complex ambiguities. [EXPLICIT] |
| Feature with same name already exists in specs/ | Directory name collision detected | Warn user, offer to: (a) append version suffix, (b) overwrite, (c) choose different name. [EXPLICIT] |
| User provides requirements in non-English language | Language detection on input | Process in the detected language; spec template adapts to user's language. [INFERRED] |
| Constitution has been modified after specification | Timestamp comparison between CONSTITUTION.md and spec.md | Warn about potential governance drift; suggest re-running specify to realign. [INFERRED] |

## Good vs Bad Example

**Good**: Well-structured specification output
```
## FR-001: User Registration
As a new user, I want to register with email and password so that I can access the platform.

### Acceptance Criteria
- SC-001: Given valid email and password, when user submits form, then account is created
- SC-002: Given duplicate email, when user submits form, then error message is displayed
- SC-003: Given weak password, when user submits form, then strength requirements are shown
```

**Bad**: Vague, unstructured specification
```
## User Registration
Users should be able to register. It should work well and be secure.
```

**Why**: Good specs have unique FR-NNN identifiers, Given/When/Then scenarios with SC-NNN IDs, and testable acceptance criteria. Bad specs lack structure, traceability, and testable conditions. [EXPLICIT]

## Validation Gate

Before marking specification as complete, verify: [EXPLICIT]

- [ ] V1: All functional requirements have unique FR-NNN identifiers
- [ ] V2: All scenarios have unique SC-NNN identifiers with Given/When/Then structure
- [ ] V3: spec.md exists in `specs/{NNN}-{feature-name}/`
- [ ] V4: No bracket placeholders `[PLACEHOLDER]` remain in output
- [ ] V5: Constitution was loaded (soft mode) and no governance violations detected
- [ ] V6: Bug-fix detection check passed (not a bug report)
- [ ] V7: Next step recommendation displayed (/iikit-clarify or /iikit-02-plan)
