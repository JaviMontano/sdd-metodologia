---
name: sdd-dashboard
description: >-
  This skill should be used when the user asks to "generate dashboard", "refresh dashboard",
  "build command center", "update ALM views", "regenerate pipeline visualization",
  or "open dashboard". It generates both the single-file dashboard and the multi-page
  ALM Command Center with all views (pipeline, specs, quality, intelligence, workspace,
  governance, logs, backlog, search). Use this skill whenever the user mentions
  dashboard, command center, ALM, or pipeline visualization.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Dashboard — ALM Command Center Generator [EXPLICIT]

Generate the multi-page ALM Command Center and single-file dashboard with all pipeline views.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Generate Dashboard Data

```bash
node scripts/generate-command-center-data.js
```

This produces `.specify/shared/data.js` (DASHBOARD_DATA) consumed by all ALM pages.

### 2. Generate Single-File Dashboard (Legacy)

```bash
node scripts/generate-dashboard.js
```

This produces `.specify/dashboard.html` for backward compatibility.

### 3. Verify Generation

Check that all expected files exist:
- `.specify/dashboard.html` (single-file)
- `.specify/dashboard/index.html` (Command Center)
- `.specify/shared/data.js` (data layer)

### 4. Report

```
Dashboard generated!

Command Center: file://$(pwd)/.specify/dashboard/index.html
Single-file:    file://$(pwd)/.specify/dashboard.html

Views: Pipeline | Specs | Quality | Intelligence | Workspace | Governance | Logs | Backlog | Search
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Node.js available for generation scripts | If Node unavailable, ERROR with install suggestion. [EXPLICIT] |
| 2 | `.specify/` directory exists (project initialized) | If missing, suggest `/sdd:init` first. [EXPLICIT] |
| 3 | Two generators produce complementary outputs | `generate-command-center-data.js` (primary ALM) + `generate-dashboard.js` (legacy). [EXPLICIT] |
| 4 | Dashboard reads from specs/, CONSTITUTION.md, context.json | Data freshness depends on artifact state. [EXPLICIT] |
| 5 | Brand tokens applied from `references/design-tokens.json` | Neo-Swiss palette: Navy, Gold, Blue, Charcoal, Lavender, Gray. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Empty project (no features) | specs/ empty | Generate dashboard with empty state views and init guidance. [EXPLICIT] |
| Missing Node.js | `node` not in PATH | ERROR with "Install Node.js 18+ to generate dashboard". [EXPLICIT] |
| Corrupted data.js | Generation script throws error | Report error details, suggest re-running after fixing source artifacts. [EXPLICIT] |
| Very large project | 10+ features with many artifacts | Generation may take longer; inform user of progress. [INFERRED] |
| Dashboard already exists | Previous generation in place | Overwrite with fresh data; no merge needed. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:dashboard` regenerates all views
```
Dashboard generated!

Command Center: file:///Users/dev/project/.specify/dashboard/index.html
Single-file:    file:///Users/dev/project/.specify/dashboard.html

Views: Pipeline | Specs | Quality | Intelligence | Workspace | Governance | Logs | Backlog | Search
Data: 3 features, 24 tasks, 12 test scenarios, health 78/100
```

**Bad**: Incomplete dashboard generation
```
x Only single-file generated, Command Center missing
x No verification of output files
x No resolved file:// path provided
```

**Why**: Dashboard must generate both outputs (ALM Command Center + legacy single-file), verify all files exist, and provide resolved file:// paths. [EXPLICIT]

## Validation Gate

Before marking dashboard generation as complete, verify: [EXPLICIT]

- [ ] V1: `generate-command-center-data.js` executed successfully
- [ ] V2: `generate-dashboard.js` executed successfully
- [ ] V3: `.specify/dashboard/index.html` exists
- [ ] V4: `.specify/shared/data.js` exists
- [ ] V5: `.specify/dashboard.html` exists
- [ ] V6: Resolved file:// paths provided to user
