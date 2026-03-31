---
name: sdd-insights
description: >-
  This skill should be used when the user asks to "show insights", "analyze health trends",
  "view risk indicators", "get smart recommendations", "show traceability analysis",
  or "review pipeline intelligence". It runs the insights engine to produce health scores,
  traceability analysis, risk indicators, and AI-powered recommendations.
  Use this skill whenever the user mentions insights, trends, risk analysis, or recommendations.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Insights — Health Trends & Smart Recommendations [EXPLICIT]

Analyze project health trends, traceability coverage, risk indicators, and generate smart recommendations.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run Insights Engine

```bash
node scripts/sdd-insights.js
```

The engine analyzes:
- **Health scores**: Per-feature and aggregate health using 4-factor model
- **Traceability**: Constitution→FR→TS→Task edge coverage and orphan detection
- **Risk indicators**: Velocity trends, blocker patterns, coverage gaps
- **Recommendations**: Prioritized actions based on current state

### 2. Present Results

Display in sections:
1. **Health Overview**: Aggregate score with per-feature breakdown
2. **Traceability Matrix**: Coverage percentages and orphan nodes
3. **Risk Indicators**: Flagged patterns with severity
4. **Recommendations**: Ordered by impact, linked to `/sdd:*` commands

## Report

```
Insights generated!

Health: NN/100 aggregate
  - feature-1: NN/100
  - feature-2: NN/100

Traceability: NN% edges covered, N orphans
Risk: N indicators flagged
Recommendations: N actions suggested

- Dashboard: file://$(pwd)/.specify/dashboard.html (Intelligence view)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Knowledge graph exists (`.specify/knowledge-graph.json`) | If missing, suggest `/sdd:graph` first. [EXPLICIT] |
| 2 | At least one feature with spec exists | If no features, suggest `/sdd:01-specify`. [EXPLICIT] |
| 3 | Insights engine requires Node.js | If Node unavailable, ERROR with install suggestion. [EXPLICIT] |
| 4 | Historical data improves trend accuracy | First run has no trend baseline — reports current state only. [EXPLICIT] |
| 5 | Recommendations are prioritized by downstream impact | Critical gaps in early phases rank higher than late-phase gaps. [INFERRED] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No knowledge graph built | `.specify/knowledge-graph.json` missing | Run `/sdd:graph` automatically before insights, or warn. [EXPLICIT] |
| Single feature, early stage | Only spec exists, no tests/tasks | Report partial health, skip unavailable factors. [EXPLICIT] |
| All scores at 100% | Perfect health across all factors | Report "no actions needed", suggest `/sdd:08-issues` to ship. [INFERRED] |
| Conflicting indicators | High coverage but low task completion | Flag as "coverage without execution" pattern. [INFERRED] |
| Very large project (10+ features) | Many features in different stages | Aggregate with per-feature drill-down, highlight worst performers. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:insights` produces actionable intelligence
```
Health: 68/100 aggregate
  - 001-user-auth: 85/100 (strong)
  - 002-api-gateway: 45/100 (at risk)

Traceability: 73% edges covered, 4 orphans
  - FR-012: no test scenario (orphan requirement)
  - T-045: no spec reference (orphan task)

Risk: 2 indicators
  - 002-api-gateway: 0% test coverage in implementing phase
  - Velocity declining: 3 tasks/week → 1 task/week

Recommendations:
  1. /sdd:04-testify on 002-api-gateway (high impact)
  2. /sdd:graph to resolve 4 orphan nodes
```

**Bad**: Generic health report
```
x "Project health is moderate" — no specific scores
x No traceability analysis
x No risk indicators
x No actionable recommendations
```

**Why**: Insights must provide quantified health, traceability analysis with orphan detection, risk indicators, and specific remediation recommendations. [EXPLICIT]

## Validation Gate

Before marking insights as complete, verify: [EXPLICIT]

- [ ] V1: Health scores calculated per feature and aggregate
- [ ] V2: Traceability coverage percentage computed
- [ ] V3: Orphan nodes identified (untested FRs, unlinked tasks)
- [ ] V4: Risk indicators flagged with severity
- [ ] V5: Recommendations mapped to `/sdd:*` commands
- [ ] V6: Dashboard Intelligence view link provided
