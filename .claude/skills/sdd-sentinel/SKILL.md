---
name: sdd-sentinel
description: >-
  This skill should be used when the user asks to "run sentinel", "check project health",
  "scan for drift", "detect stale artifacts", "run perceive-decide-act cycle",
  or "audit pipeline state". It executes a full sentinel cycle (perceive-decide-act)
  with zero LLM cost to detect stale artifacts, missing files, health regression,
  and drift from constitution principles. Use this skill whenever the user mentions
  sentinel, health check, drift detection, or pipeline audit.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Sentinel — Full Perceive-Decide-Act Cycle [EXPLICIT]

Run a comprehensive sentinel cycle that perceives project state, decides on findings, and acts with recommendations — all at zero LLM cost.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (soft mode — warn if missing, proceed without).

## Execution Flow

### 1. Run Sentinel Script

```bash
bash scripts/sdd-sentinel.sh
```

The script executes three phases:

**Perceive (P1-P5)**:
- P1: Scan artifact freshness (stale if >7 days without update)
- P2: Check for missing required files per phase
- P3: Validate assertion hashes (.feature file integrity)
- P4: Cross-reference spec→test→task traceability
- P5: Constitution alignment check

**Decide (D1-D6)**:
- D1: Classify findings by severity (critical/warning/info)
- D2: Prioritize by downstream impact
- D3: Filter false positives (new projects, expected gaps)
- D4: Group related findings
- D5: Map findings to remediation commands
- D6: Calculate health delta since last run

**Act**:
- Generate findings report with severity classification
- Suggest specific `/sdd:*` commands for each finding
- Update `.specify/sentinel-last-run.json` timestamp
- Output health score (0-100) based on 4-factor model

### 2. Parse and Present Results

Display findings grouped by severity:
- **Critical**: Broken assertions, missing required files, constitution violations
- **Warning**: Stale artifacts, incomplete traceability, low coverage
- **Info**: Optimization opportunities, suggested improvements

### 3. Health Score

Present the 4-factor health model:
- specCoverage (25 pts): Requirements with test coverage
- testCoverage (25 pts): Test scenarios with passing assertions
- taskCompletion (25 pts): Completed vs total tasks
- constitutionAlignment (25 pts): Principles with traced requirements

## Report

```
Sentinel cycle complete!

Health: NN/100 (delta: +/-N since last run)
Findings: N critical, N warnings, N info

[Critical findings with remediation commands]
[Warning findings with suggested actions]

Next: <recommended command based on most critical finding>
- Dashboard: file://$(pwd)/.specify/dashboard.html
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Project has been initialized with `/sdd:init` | If no `.specify/` directory, suggest init first. [EXPLICIT] |
| 2 | Sentinel runs at zero LLM cost (pure bash) | No AI inference during perceive/decide — only script execution. [EXPLICIT] |
| 3 | Health score uses 4-factor model (25 pts each) | specCoverage + testCoverage + taskCompletion + constitutionAlignment = 100. [EXPLICIT] |
| 4 | Findings are severity-classified (critical/warning/info) | Critical blocks progress; warnings suggest action; info is optional. [EXPLICIT] |
| 5 | Sentinel state persists in `.specify/sentinel-last-run.json` | Enables health delta tracking between runs. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Brand new project (no artifacts) | All perceive checks return empty | Report health 0/100 with "new project" context, suggest `/sdd:01-specify`. [EXPLICIT] |
| Assertion hash mismatch | P3 detects SHA-256 divergence in .feature files | Critical finding: someone modified tests without re-hashing. Suggest `/sdd:04-testify`. [EXPLICIT] |
| No constitution exists | P5 finds no CONSTITUTION.md | Warning: governance principles missing. Suggest `/sdd:00-constitution`. [EXPLICIT] |
| Stale artifacts (>30 days) | P1 detects very old modification dates | Escalate to critical if artifacts are in active feature. [INFERRED] |
| Sentinel run during active implementation | Tasks in progress, partial coverage | Filter false positives for in-progress work, only flag completed phases. [EXPLICIT] |

## Good vs Bad Example

**Good**: User runs `/sdd:sentinel` and gets actionable findings
```
Sentinel cycle complete!

Health: 72/100 (delta: -3 since last run)
Findings: 1 critical, 2 warnings, 1 info

CRITICAL:
  - Assertion hash mismatch in 001-user-auth/tests/features/login.feature
    → Run: /sdd:04-testify to re-hash

WARNING:
  - spec.md stale (12 days since last update) in 002-api-gateway
  - FR-005 has no linked test scenario
    → Run: /sdd:04-testify

INFO:
  - 3 tasks completed since last sentinel run

Next: /sdd:04-testify (fix assertion integrity first)
```

**Bad**: Health check without structure
```
x "Project looks fine" — no specific findings
x No health score or delta
x No remediation commands suggested
x No severity classification
```

**Why**: Sentinel must provide quantified health, severity-classified findings, and specific remediation commands for each issue. [EXPLICIT]

## Validation Gate

Before marking sentinel as complete, verify: [EXPLICIT]

- [ ] V1: All 5 perceive checks (P1-P5) executed
- [ ] V2: Findings classified by severity (critical/warning/info)
- [ ] V3: Health score calculated using 4-factor model
- [ ] V4: Health delta computed against last run
- [ ] V5: Remediation commands mapped to each finding
- [ ] V6: sentinel-last-run.json updated
- [ ] V7: Dashboard link provided
