---
name: sdd-status
description: >-
  This skill should be used when the user asks to "check status", "show pipeline status",
  "view progress", "what phase am I on", "show feature stages",
  or "display pipeline overview". It runs the status script to display a visual
  pipeline table with phase dots, feature stages, and next step recommendations.
  Use this skill whenever the user mentions status, progress, pipeline overview, or current phase.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Status — Pipeline Overview with Next Step Advisor [EXPLICIT]

Display visual pipeline status with phase dots, feature stages, and next step recommendations.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run Status Script

```bash
bash scripts/sdd-status.sh
```

### 2. Present Results

Display:
- Visual pipeline table with phase dots per feature
- Current feature stage and completion percentage
- Next step recommendation with model tier

## Report

```
SDD Pipeline Status

| Feature | Const | Spec | Plan | Check | Test | Tasks | Analyze | Impl | Issues |
|---------|-------|------|------|-------|------|-------|---------|------|--------|
| 001-auth | *   | *   | *   | *    | .   | .    | .      | .   | .     |

Active: 001-auth (implementing-50%)
Next: /sdd:04-testify (model: tier-2)

- Dashboard: file://$(pwd)/.specify/dashboard.html
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Project initialized with `/sdd:init` | If no `.specify/`, suggest init. [EXPLICIT] |
| 2 | At least one feature exists | If no features, suggest `/sdd:01-specify`. [EXPLICIT] |
| 3 | Status reads from context.json and artifact presence | No LLM cost — pure file inspection. [EXPLICIT] |
| 4 | Phase dots indicate completion: `*` = done, `.` = pending | Visual shorthand for pipeline progress. [EXPLICIT] |
| 5 | Next step considers active feature's current stage | Recommendation changes based on which artifacts exist. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No features | specs/ empty | Show empty pipeline, suggest `/sdd:01-specify`. [EXPLICIT] |
| Multiple features at different stages | Several features in specs/ | Show all in table, highlight active feature. [EXPLICIT] |
| All phases complete | Every phase has artifacts | Report "ready to ship", suggest `/sdd:08-issues`. [INFERRED] |
| No active feature set | `.specify/active-feature` missing | Auto-select if single feature, prompt if multiple. [EXPLICIT] |
| Corrupted context.json | File exists but malformed | Regenerate from artifact presence, warn user. [INFERRED] |

## Good vs Bad Example

**Good**: `/sdd:status` shows clear pipeline view
```
| Feature    | C | S | P | Ch | T | Tk | A | I | Is |
|------------|---|---|---|----|---|----|----|---|----|
| 001-auth   | * | * | * | *  | * | *  | .  | . | .  |
| 002-gateway| * | * | . | .  | . | .  | .  | . | .  |

Active: 001-auth (analyzed)
Next: /sdd:07-implement
```

**Bad**: Status without visual pipeline
```
x "You have 2 features" — no phase progress
x No next step recommendation
x No visual table
```

**Why**: Status must show visual pipeline with per-feature phase completion and actionable next step. [EXPLICIT]

## Validation Gate

Before marking status as complete, verify: [EXPLICIT]

- [ ] V1: Pipeline table displayed with phase dots
- [ ] V2: All features shown with current stages
- [ ] V3: Active feature highlighted
- [ ] V4: Next step recommendation provided
- [ ] V5: Dashboard link included
