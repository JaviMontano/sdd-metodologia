---
name: sdd-qa
description: >-
  This skill should be used when the user asks to "generate QA plan", "refresh QA plan",
  "check definition of done", "review acceptance criteria", "audit gate status",
  or "validate quality gates". It generates QA-PLAN.md and qa-plan.json with
  Definition of Done, acceptance criteria per feature, and G1/G2/G3 gate status.
  Use this skill whenever the user mentions QA plan, quality gates, DoD, or acceptance criteria.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD QA — Quality Assurance Plan Generator [EXPLICIT]

Generate or refresh QA-PLAN.md with Definition of Done, acceptance criteria, and gate status for all features.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run QA Plan Generator

```bash
node scripts/sdd-qa-plan.js
```

Produces:
- `QA-PLAN.md` — Human-readable quality plan
- `.specify/qa-plan.json` — Machine-readable gate status

### 2. Parse and Present Results

Display:
- **Definition of Done**: Per-phase completion criteria
- **Gate Status**: G1 (post-plan), G2 (post-analyze), G3 (post-implement)
- **Acceptance Criteria**: Per-feature with pass/fail status
- **Coverage Summary**: Test coverage percentages

### 3. Report

```
QA Plan generated!

Gates:
  G1 (Plan): PASS/FAIL — <details>
  G2 (Analyze): PASS/FAIL — <details>
  G3 (Implement): PASS/FAIL — <details>

Features: N features assessed
Coverage: NN% aggregate test coverage

Files:
  - QA-PLAN.md (created/updated)
  - .specify/qa-plan.json (created/updated)

- Dashboard: file://$(pwd)/.specify/dashboard.html (Quality view)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Node.js available for QA plan generation | If Node unavailable, ERROR with install suggestion. [EXPLICIT] |
| 2 | At least one feature exists with artifacts | If no features, suggest `/sdd:01-specify` first. [EXPLICIT] |
| 3 | Gates are cumulative: G1 requires plan, G2 requires G1 + analyze, G3 requires G2 + implement | Gate status reflects cumulative requirements. [EXPLICIT] |
| 4 | QA plan covers all features in specs/ | Multi-feature projects get per-feature sections. [EXPLICIT] |
| 5 | qa-plan.json enables programmatic gate checking | Used by implement and analyze skills for gate validation. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No features exist | specs/ empty | ERROR: suggest `/sdd:01-specify` first. [EXPLICIT] |
| Feature at early stage (only spec) | No plan, tests, or tasks | Report G1/G2/G3 as NOT_REACHED, show what's needed. [EXPLICIT] |
| All gates passing | Complete pipeline with full coverage | Report "ready to ship", suggest `/sdd:08-issues`. [INFERRED] |
| Gate regression | Previously passing gate now fails | Flag as critical: "G2 regression — investigate changes since last pass". [EXPLICIT] |
| Mixed feature stages | Some features at spec, others at implement | Per-feature gate status, aggregate only what's applicable. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:qa` produces structured gate assessment
```
QA Plan generated!

Gates:
  G1 (Plan): PASS — plan.md complete, architecture decisions documented
  G2 (Analyze): FAIL — 2 cross-reference inconsistencies found
  G3 (Implement): NOT_REACHED — blocked by G2

Features:
  001-user-auth: G1 PASS, G2 FAIL (FR-003 untested)
  002-api-gateway: G1 PASS, G2 PASS, G3 in progress

Coverage: 67% aggregate
```

**Bad**: QA without gate assessment
```
x "Quality looks good" — no gate status
x No per-feature breakdown
x No specific failures identified
```

**Why**: QA plan must assess each gate (G1/G2/G3) per feature with specific pass/fail reasons and coverage metrics. [EXPLICIT]

## Validation Gate

Before marking QA plan as complete, verify: [EXPLICIT]

- [ ] V1: QA-PLAN.md generated with DoD and acceptance criteria
- [ ] V2: qa-plan.json generated with machine-readable gate status
- [ ] V3: G1/G2/G3 assessed per feature
- [ ] V4: Coverage percentages computed
- [ ] V5: Specific failures identified with remediation
- [ ] V6: Dashboard Quality view link provided
