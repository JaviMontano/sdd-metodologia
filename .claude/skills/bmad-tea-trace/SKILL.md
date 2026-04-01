---
name: bmad-tea-trace
description: >-
  This skill should be used when the user asks to "build a traceability matrix", "trace
  requirements to tests", "coverage analysis", "requirement coverage", "test traceability",
  or "what requirements lack tests". It generates a requirements-to-tests traceability matrix
  and performs coverage gap analysis. Part of the BMAD TEA suite. Complements the SDD
  knowledge graph with test-specific tracing.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD TEA: Trace — Traceability Matrix & Coverage Analysis [EXPLICIT]

Build a requirements-to-tests traceability matrix, identify coverage gaps, and generate a coverage report with risk assessment.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the scope of traceability analysis.

## Execution Flow

### 1. Gather Artifacts [EXPLICIT]

Locate and read the source artifacts:
- `.specify/spec.md` — Requirements (FR-NNN identifiers)
- `.specify/tests/*.feature` — BDD test scenarios (TS-NNN identifiers)
- `.specify/tasks.md` — Task breakdown (T-NNN identifiers)
- `.specify/knowledge-graph.json` — Existing traceability graph
- `.specify/plan.md` — Technical specs for architectural requirements

If artifacts are missing, report which are available and which are needed.

### 2. Build Traceability Matrix [EXPLICIT]

```markdown
## Traceability Matrix

| Requirement | Description | Test Scenarios | Implementation | Status |
|-------------|------------|----------------|---------------|--------|
| FR-001 | {desc} | TS-001, TS-002 | T-001 | ✅ Covered |
| FR-002 | {desc} | TS-003 | T-002, T-003 | ✅ Covered |
| FR-003 | {desc} | — | T-004 | ❌ No tests |
| FR-004 | {desc} | TS-005 | — | ⚠️ Not implemented |
| NFR-001 | {desc} | — | — | ❌ No coverage |

**Legend**: ✅ Fully covered | ⚠️ Partially covered | ❌ Gap identified
```

### 3. Coverage Analysis [EXPLICIT]

```markdown
## Coverage Report

### Summary
| Metric | Count | Percentage |
|--------|-------|-----------|
| Total requirements | {N} | 100% |
| Requirements with tests | {N} | {%} |
| Requirements with implementation | {N} | {%} |
| Fully traced (req → test → impl) | {N} | {%} |
| **Coverage gaps** | **{N}** | **{%}** |

### Gap Analysis
| Gap Type | Count | Items | Risk |
|----------|-------|-------|------|
| Requirements without tests | {N} | FR-003, NFR-001 | High |
| Tests without requirements | {N} | TS-010 | Low (orphan test) |
| Requirements without implementation | {N} | FR-004 | Medium |
| Tests without passing status | {N} | TS-007 | High |
```

### 4. Risk Assessment [EXPLICIT]

```markdown
## Risk Assessment

### High-Risk Gaps (must address before release)
1. **FR-003**: {requirement} — No test coverage, high business impact
2. **NFR-001**: {NFR} — No verification approach defined

### Medium-Risk Gaps (address in next sprint)
1. **FR-004**: {requirement} — Tests exist but no implementation

### Orphans (investigate)
1. **TS-010**: Test scenario with no matching requirement — validate or remove

### Coverage Trend
- Current: {%} covered
- Target: {%} (recommended: 100% for Must requirements, 80% for Should)
- Gap to close: {N} requirements
```

### 5. Bridge to Pipeline [EXPLICIT]

- `/sdd:test` — Generate missing test scenarios for uncovered requirements
- `/sdd:graph` — Rebuild knowledge graph with updated traceability
- `/bmad-tea-test-design` — Design test strategy for gap areas
- `/sdd:analyze` — Cross-artifact consistency check

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Requirements use FR-NNN/NFR-NNN identifiers | Adapt pattern matching to project's naming convention |
| 2 | Tests use TS-NNN identifiers | Match by content if no standard IDs |
| 3 | Traceability is bidirectional (req ↔ test ↔ impl) | Build forward and backward links |
| 4 | Coverage gaps are prioritized by business impact | Assess risk based on requirement priority |
| 5 | This is analysis, not test generation | For test generation, bridge to `/sdd:test` |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | No spec.md exists | Cannot build matrix — redirect to `/sdd:spec` |
| 2 | Spec exists but no tests | Report 0% coverage, recommend `/sdd:test` |
| 3 | Tests exist but no formal spec | Reverse-trace: infer requirements from tests |
| 4 | Knowledge graph already exists | Use as input, enrich with test tracing |
| 5 | Hundreds of requirements | Group by epic/feature for manageable output |

## Good vs Bad Example

**Good**: User asks "Build a traceability matrix for our project" → Skill reads spec.md (15 FRs, 3 NFRs), reads .feature files (12 test scenarios), builds full matrix showing 10/15 FRs covered (67%), identifies 5 gaps with risk levels, finds 2 orphan tests, reports coverage trend, and recommends `/sdd:test` for the 5 uncovered requirements.

**Bad**: User asks "Trace requirements to tests" → Skill says "you should trace your requirements" without reading any files, no matrix, no coverage numbers, no gap analysis.

## Validation Gate [EXPLICIT]

- [ ] V1: Source artifacts were read (not assumed)
- [ ] V2: Traceability matrix links requirements → tests → implementation
- [ ] V3: Coverage percentage is calculated
- [ ] V4: Gaps are identified with specific IDs
- [ ] V5: Risk assessment prioritizes gaps by business impact
- [ ] V6: Bridge to next step for closing gaps
