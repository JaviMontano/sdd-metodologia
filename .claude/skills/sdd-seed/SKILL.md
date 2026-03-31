---
name: sdd-seed
description: >-
  This skill should be used when the user asks to "seed demo data", "generate sample data",
  "populate project with examples", "create test fixtures", "seed without dashboard",
  or "just create the demo files". It seeds demo data (3 features with pipeline artifacts)
  without opening the dashboard. Use this skill when the user wants demo data only,
  not the full demo experience with dashboard.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Seed — Seed Demo Data Without Dashboard [EXPLICIT]

Generate demo project data (3 features, specs, tests, tasks) without opening the dashboard.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Seed Demo Data

```bash
bash scripts/sdd-seed-demo.sh
```

### 2. Report

```
Demo data seeded!

Features:
  001-user-authentication — spec, plan, checklist, tests, tasks
  002-api-gateway — spec, plan, checklist, tests
  003-notification-service — spec

Files created: N files across specs/, CONSTITUTION.md, .specify/

To generate dashboard: /sdd:dashboard
To explore: /sdd:status
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Same data as `/sdd:demo` but no dashboard step | Seed script is identical; only dashboard generation is skipped. [EXPLICIT] |
| 2 | Overwrites existing data | Same warning as demo — existing specs/ overwritten. [EXPLICIT] |
| 3 | No Node.js required | Seed script is pure bash. [EXPLICIT] |
| 4 | Useful for CI/testing scenarios | Dashboard not needed for automated pipelines. [INFERRED] |
| 5 | Context.json updated with seeded features | `.specify/context.json` reflects seeded state. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Existing real data | specs/ non-empty | WARN before overwriting. [EXPLICIT] |
| Script not found | `scripts/sdd-seed-demo.sh` missing | ERROR: suggest `/sdd:sync` to restore scripts. [EXPLICIT] |
| Partial execution | Script interrupted | Report created vs missing features. [INFERRED] |
| Repeated seeding | Run twice | Idempotent — overwrites cleanly. [EXPLICIT] |
| Custom seed count | User wants more/fewer features | Not supported — always 3 features. Suggest `/sdd:01-specify` for custom. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:seed` creates data with clear inventory
```
Demo data seeded!
Features: 3 created
Files: 18 files across specs/, CONSTITUTION.md, .specify/
To generate dashboard: /sdd:dashboard
```

**Bad**: Seed without feedback
```
x "Done" — no file list
x No feature inventory
x No next step suggestion
```

**Why**: Seed must report what was created and suggest next actions. [EXPLICIT]

## Validation Gate

Before marking seed as complete, verify: [EXPLICIT]

- [ ] V1: `sdd-seed-demo.sh` executed successfully
- [ ] V2: 3 features exist in specs/
- [ ] V3: CONSTITUTION.md exists
- [ ] V4: `.specify/context.json` updated
- [ ] V5: File inventory reported to user
