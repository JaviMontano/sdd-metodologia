---
name: bmad-tea-test-design
description: >-
  This skill should be used when the user asks to "design a test strategy", "create test plan",
  "ATDD approach", "acceptance test design", "enterprise testing strategy", or "test architecture".
  It generates a comprehensive test strategy with ATDD patterns, test pyramid design, environment
  strategy, and automation recommendations. Part of the BMAD TEA (Test Enterprise Architecture)
  suite. Distinct from /sdd:test (BDD scenario generation) — this is strategic test design.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD TEA: Test Design — Enterprise Test Strategy [EXPLICIT]

Design a comprehensive test strategy with ATDD patterns, test pyramid allocation, environment strategy, and automation framework recommendations.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the system or feature to create a test strategy for.

## Execution Flow

### 1. Understand Testing Context [EXPLICIT]

Extract from `$ARGUMENTS`:
- **System under test**: What application/service/feature needs testing
- **Architecture style**: Monolith, microservices, serverless, etc.
- **Current test maturity**: None, basic, intermediate, enterprise
- **Quality goals**: Reliability targets, compliance requirements

Check for existing artifacts:
- `.specify/spec.md` — Requirements to test against
- `.specify/plan.md` — Architecture informing test approach
- `.specify/tests/` — Existing test scenarios

### 2. Design Test Pyramid [EXPLICIT]

```markdown
## Test Pyramid

| Layer | Type | Target Coverage | Tools | Run Frequency |
|-------|------|----------------|-------|---------------|
| Base | Unit Tests | 70-80% of tests | {framework} | Every commit |
| Middle | Integration Tests | 15-20% of tests | {framework} | Every PR |
| Middle | Contract Tests | API boundaries | {tool} | Every PR |
| Top | E2E Tests | Critical paths only | {framework} | Nightly/Pre-release |
| Top | Performance Tests | SLA validation | {tool} | Weekly/Pre-release |

**Anti-patterns to avoid**:
- Ice cream cone (too many E2E, too few unit)
- Testing implementation details instead of behavior
- Flaky tests without quarantine strategy
```

### 3. Define ATDD Workflow [EXPLICIT]

```markdown
## Acceptance Test-Driven Development

### Workflow
1. **Discover**: Collaborative session — PM, Dev, QA define acceptance criteria
2. **Formalize**: Write executable specifications (Given-When-Then)
3. **Automate**: Implement acceptance tests before production code
4. **Develop**: Write code to make acceptance tests pass
5. **Verify**: Run full test suite, validate coverage

### Acceptance Criteria Template
- **Given** {precondition with specific data}
- **When** {user action or system event}
- **Then** {observable, verifiable outcome}

### Criteria for Good Acceptance Tests
- Business-readable language
- One behavior per scenario
- Independent and idempotent
- Deterministic (no flakiness)
```

### 4. Environment Strategy [EXPLICIT]

```markdown
## Test Environments

| Environment | Purpose | Data Strategy | Refresh Cadence |
|-------------|---------|---------------|-----------------|
| Local | Unit + integration | Fixtures/mocks | Per session |
| CI | Full pyramid | Seeded test data | Per commit |
| Staging | E2E + performance | Production-like | Weekly |
| Pre-prod | Smoke + canary | Anonymized prod | Pre-release |

**Data Management**:
- Test data factories for reproducibility
- Database seeding scripts for environment setup
- Data masking for production-like data
```

### 5. Automation Recommendations [EXPLICIT]

```markdown
## Automation Strategy

| Category | Automate | Manual |
|----------|----------|--------|
| Regression | ✅ Always | |
| Smoke tests | ✅ Always | |
| Happy path E2E | ✅ | |
| Exploratory | | ✅ Always |
| Usability | | ✅ Always |
| Edge cases | ✅ After discovery | ✅ First time |

**CI/CD Integration**:
- {pipeline stage} → {test suite} → {gate criteria}
```

### 6. Bridge to Pipeline [EXPLICIT]

- `/sdd:test` — Generate BDD test scenarios from spec
- `/bmad-tea-nfr-assess` — Assess non-functional requirement testing
- `/bmad-tea-trace` — Build traceability matrix for test coverage
- `/bmad-code-review` — Review test implementation quality

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User has requirements to test against | Check for spec.md; ask for requirements if missing |
| 2 | Standard test pyramid applies | Adapt for architecture (e.g., microservices need more contract tests) |
| 3 | CI/CD pipeline exists or is planned | Include manual testing alternatives if no CI/CD |
| 4 | Tool recommendations are framework-agnostic | Suggest specific tools only when language/framework is known |
| 5 | This is strategy, not test implementation | For writing actual tests, use `/sdd:test` |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | No existing tests at all | Start with unit test foundations, build up gradually |
| 2 | Legacy system with no test infrastructure | Recommend characterization tests as first step |
| 3 | Microservices architecture | Emphasize contract testing and service virtualization |
| 4 | Real-time or streaming system | Include chaos engineering and load testing emphasis |
| 5 | Regulated industry (healthcare, finance) | Include compliance testing requirements and audit trail |

## Good vs Bad Example

**Good**: User asks "Design a test strategy for our Node.js microservices" → Skill produces test pyramid (Jest unit, Supertest integration, Pact contracts, Playwright E2E), ATDD workflow with GWT templates, 4-environment strategy, automation matrix with CI/CD gates, and recommends `/sdd:test` for BDD scenario generation.

**Bad**: User asks "Design a test strategy" → Skill says "write unit tests and integration tests" with no pyramid, no ATDD workflow, no environment plan, no tooling recommendations.

## Validation Gate [EXPLICIT]

- [ ] V1: Test pyramid is defined with layer allocation
- [ ] V2: ATDD workflow is documented
- [ ] V3: Environment strategy with data management
- [ ] V4: Automation vs manual matrix
- [ ] V5: Tool recommendations aligned with project stack
- [ ] V6: Bridge to next pipeline step
