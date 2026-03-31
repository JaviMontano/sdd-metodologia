---
name: sdd-demo
description: >-
  This skill should be used when the user asks to "run a demo", "show me how SDD works",
  "generate a demo project", "create a sample project", "demonstrate the pipeline",
  or "try SDD with example data". It generates a complete demo project with realistic
  features, specs, tests, tasks, and opens the dashboard for exploration.
  Use this skill whenever the user mentions demo, demonstration, sample project, or try SDD.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Demo — Generate Demo Project + Dashboard [EXPLICIT]

Generate a complete demo project with 3 realistic features and open the ALM Command Center for exploration.

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

This creates:
- `CONSTITUTION.md` with governance principles
- 3 features in `specs/` with full pipeline artifacts (spec, plan, checklist, tests, tasks)
- `.specify/context.json` with feature state
- Assertion hashes for .feature files

### 2. Generate Dashboard

```bash
node scripts/generate-command-center-data.js
node scripts/generate-dashboard.js
```

### 3. Open Dashboard

Provide the file:// URL for the Command Center:

```
file://$(pwd)/.specify/dashboard/index.html
```

### 4. Report

```
Demo project generated!

Features:
  001-user-authentication (implementing-75%)
  002-api-gateway (tested)
  003-notification-service (specified)

Artifacts: 3 specs, 2 plans, 2 checklists, 2 test suites, 1 task breakdown
Health: NN/100

Dashboard: file://$(pwd)/.specify/dashboard/index.html

Try:
  /sdd:status   — See pipeline overview
  /sdd:sentinel — Run health check
  /sdd:insights — View intelligence
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Demo overwrites existing `.specify/` and `specs/` | Warns before overwriting; use on fresh projects. [EXPLICIT] |
| 2 | Node.js required for dashboard generation | If Node unavailable, seed data but skip dashboard. [EXPLICIT] |
| 3 | Demo creates 3 features at different pipeline stages | Showcases multiple phases simultaneously. [EXPLICIT] |
| 4 | Demo data is realistic but fictional | Uses generic auth/API/notification domains. [EXPLICIT] |
| 5 | Dashboard opens via file:// URL | User must open manually in browser. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Existing project with real data | specs/ or CONSTITUTION.md exist | WARN: "Demo will overwrite existing data. Proceed?" [EXPLICIT] |
| No Node.js | `node` not in PATH | Seed data only, skip dashboard, suggest installing Node. [EXPLICIT] |
| No git repo | `.git/` missing | Demo works without git; hooks installation skipped. [EXPLICIT] |
| Partial seed failure | Script exits non-zero | Report which features were created, suggest re-running. [INFERRED] |
| User wants specific domain | Arguments specify a domain | Use default 3 features; custom domains require `/sdd:01-specify`. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:demo` creates explorable project
```
Demo project generated!
Features: 3 (auth, api-gateway, notifications)
Health: 62/100
Dashboard: file:///Users/dev/project/.specify/dashboard/index.html
```

**Bad**: Demo without exploration guidance
```
x "Demo created" — no feature list
x No dashboard URL
x No suggested next commands
```

**Why**: Demo must create complete explorable project with dashboard and guided next steps. [EXPLICIT]

## Validation Gate

Before marking demo as complete, verify: [EXPLICIT]

- [ ] V1: `sdd-seed-demo.sh` executed successfully
- [ ] V2: 3 features created in specs/
- [ ] V3: CONSTITUTION.md created
- [ ] V4: Dashboard generated (both Command Center and single-file)
- [ ] V5: Dashboard file:// URL provided
- [ ] V6: Suggested next commands listed
