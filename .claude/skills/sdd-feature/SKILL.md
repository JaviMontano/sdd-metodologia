---
name: sdd-feature
description: >-
  This skill should be used when the user asks to "create a feature", "select a feature",
  "list features", "switch feature", "add new feature to project",
  or "manage features". It creates, selects, and lists features in the specs/ directory
  with proper numbering and directory structure. Use this skill whenever the user
  mentions feature creation, feature selection, or feature management.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Feature — Create, Select, and List Features [EXPLICIT]

Manage features: create new ones, select active feature, or list all features with stages.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `create <name>` | Create new feature directory with next sequential number |
| `select <name-or-number>` | Set active feature |
| `list` | List all features with stages |

## Execution Flow

```bash
bash scripts/sdd-feature.sh <subcommand> [args]
```

### Create
1. Determine next feature number (NNN)
2. Create `specs/NNN-<name>/` directory
3. Set as active feature in `.specify/active-feature`

### Select
1. Find feature by name or number
2. Update `.specify/active-feature`
3. Report current stage

### List
1. Scan `specs/*/` directories
2. Determine stage per feature (from artifacts present)
3. Display table with number, name, stage

## Report

```
Feature: <action>

| # | Feature | Stage |
|---|---------|-------|
| 1 | 001-user-auth | implementing-50% |
| 2 | 002-api-gateway | specified |

Active: 001-user-auth
Next: /sdd:01-specify (for new features)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Features live in `specs/NNN-name/` | Sequential numbering enforced. [EXPLICIT] |
| 2 | Single active feature at a time | `.specify/active-feature` tracks it. [EXPLICIT] |
| 3 | Stage derived from artifact presence | spec.md → specified, plan.md → planned, etc. [EXPLICIT] |
| 4 | Feature names are kebab-case | Script normalizes input to kebab-case. [EXPLICIT] |
| 5 | Create does not run specify | Only creates directory; user runs `/sdd:01-specify` next. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No features exist | specs/ empty | For `list`: show empty table, suggest `create`. [EXPLICIT] |
| Duplicate feature name | Name already exists in specs/ | ERROR: suggest different name. [EXPLICIT] |
| Feature not found on select | Name/number doesn't match | ERROR: show available features. [EXPLICIT] |
| Very many features (20+) | Large specs/ directory | Paginate or group by stage. [INFERRED] |
| No subcommand | Empty arguments | Default to `list`. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:feature create payment-processing`
```
Feature created!
Directory: specs/003-payment-processing/
Active: 003-payment-processing
Next: /sdd:01-specify to create specification
```

**Bad**: Feature created without structure
```
x No sequential numbering
x No active feature update
x No next step suggestion
```

**Why**: Features must have sequential numbers, proper directory structure, and active tracking. [EXPLICIT]

## Validation Gate

Before marking feature action as complete, verify: [EXPLICIT]

- [ ] V1: Subcommand parsed and executed
- [ ] V2: Feature directory exists with proper NNN prefix (for create)
- [ ] V3: `.specify/active-feature` updated (for create/select)
- [ ] V4: Feature table displayed with stages (for list)
- [ ] V5: Next step suggested
