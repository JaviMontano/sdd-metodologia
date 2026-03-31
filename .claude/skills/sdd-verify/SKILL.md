---
name: sdd-verify
description: >-
  This skill should be used when the user asks to "verify project", "run verification",
  "check integrity", "validate structure", "audit assertions", "verify brand compliance",
  or "run checks". It executes the 8-check verification suite covering structure,
  brand, tokens, assertions, and workspace integrity. Use this skill whenever the
  user mentions verify, validate, integrity check, or compliance audit.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Verify — 8-Check Verification Suite [EXPLICIT]

Run the full verification suite: structure, brand, tokens, assertions, workspace, hooks, context, and dashboard integrity.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run Verification Script

```bash
bash scripts/sdd-verify.sh
```

### 2. Eight Checks

| # | Check | What it validates |
|---|-------|------------------|
| 1 | Structure | Required directories and files exist |
| 2 | Brand | Neo-Swiss tokens, palette, typography |
| 3 | Tokens | `design-tokens.json` integrity |
| 4 | Assertions | `.feature` file SHA-256 hashes |
| 5 | Workspace | Active workspace validity |
| 6 | Hooks | Git hooks installed and functional |
| 7 | Context | `context.json` consistency |
| 8 | Dashboard | Dashboard files exist and are current |

### 3. Report

```
Verification complete!

| # | Check      | Status | Details |
|---|------------|--------|---------|
| 1 | Structure  | PASS   | All directories present |
| 2 | Brand      | PASS   | 6/6 palette colors valid |
| 3 | Tokens     | PASS   | design-tokens.json v2.0 |
| 4 | Assertions | WARN   | 2 unhashed .feature files |
| 5 | Workspace  | PASS   | Active: 2026-03-30-task |
| 6 | Hooks      | FAIL   | pre-commit not installed |
| 7 | Context    | PASS   | context.json consistent |
| 8 | Dashboard  | PASS   | Last generated: today |

Result: 6 PASS, 1 WARN, 1 FAIL
Action: Run /sdd:hooks to install missing git hooks
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Project initialized | If no `.specify/`, suggest `/sdd:init`. [EXPLICIT] |
| 2 | Verification is non-destructive | Only reads, never modifies. [EXPLICIT] |
| 3 | All 8 checks run regardless of failures | No short-circuit — full report always. [EXPLICIT] |
| 4 | PASS/WARN/FAIL classification | PASS = ok, WARN = non-blocking, FAIL = action required. [EXPLICIT] |
| 5 | Bash 3.2 compatible | macOS default shell support. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Brand new project | Most checks have nothing to verify | Report expected failures, suggest init flow. [EXPLICIT] |
| All checks pass | Perfect verification | Report "all clear", suggest proceeding with pipeline. [EXPLICIT] |
| Assertion hash missing | `.feature` files exist but no hash record | WARN with suggestion to run `/sdd:04-testify`. [EXPLICIT] |
| No git repository | Git checks fail | WARN for hooks check, other checks proceed. [EXPLICIT] |
| Corrupted design-tokens.json | JSON parse error | FAIL with "regenerate tokens" suggestion. [INFERRED] |

## Good vs Bad Example

**Good**: `/sdd:verify` runs all 8 checks with clear table
```
Result: 7 PASS, 0 WARN, 1 FAIL
Action: Run /sdd:hooks to install missing git hooks
```

**Bad**: Partial verification
```
x Only checked structure, skipped other 7 checks
x No table format
x No remediation actions
```

**Why**: Verify must run all 8 checks, present tabular results, and suggest specific remediation for failures. [EXPLICIT]

## Validation Gate

Before marking verification as complete, verify: [EXPLICIT]

- [ ] V1: All 8 checks executed
- [ ] V2: Results presented in table format
- [ ] V3: PASS/WARN/FAIL classification applied
- [ ] V4: Remediation actions suggested for failures
- [ ] V5: Summary counts reported
