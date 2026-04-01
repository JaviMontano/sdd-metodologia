---
name: bmad-tea-nfr-assess
description: >-
  This skill should be used when the user asks to "assess non-functional requirements",
  "NFR testing", "performance requirements assessment", "security testing plan",
  "scalability assessment", or "quality attribute testing". It evaluates and designs test
  approaches for non-functional requirements including performance, security, scalability,
  availability, and accessibility. Part of the BMAD TEA suite.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD TEA: NFR Assessment — Non-Functional Requirements Testing [EXPLICIT]

Assess and design test approaches for non-functional requirements: performance, security, scalability, availability, accessibility, and maintainability.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the system or NFR categories to assess.

## Execution Flow

### 1. Identify NFR Scope [EXPLICIT]

Extract from `$ARGUMENTS`:
- **System**: What application or service
- **NFR focus**: Specific categories or "full assessment"
- **SLA targets**: Any existing performance/availability targets
- **Regulatory**: Compliance requirements (GDPR, HIPAA, SOC2, WCAG, etc.)

Check for existing artifacts:
- `.specify/spec.md` — Non-functional requirements section
- `.specify/plan.md` — Architecture quality attributes

### 2. Assess Each NFR Category [EXPLICIT]

For each applicable category, produce:

```markdown
## NFR Assessment

### Performance
| Metric | Target | Test Approach | Tool |
|--------|--------|--------------|------|
| Response time (P95) | < {target}ms | Load test | {tool} |
| Throughput | {N} req/s | Stress test | {tool} |
| Resource usage | CPU < {N}%, Mem < {N}GB | Soak test | {tool} |

**Test Scenarios**: {specific load profiles to test}
**Risks**: {performance bottleneck risks}

### Security
| Check | Standard | Test Approach | Tool |
|-------|----------|--------------|------|
| OWASP Top 10 | OWASP ASVS | DAST scan | {tool} |
| Dependency vulnerabilities | CVE database | SCA scan | {tool} |
| Authentication/Authorization | {standard} | Penetration test | {tool} |
| Data protection | {regulation} | Privacy audit | Manual |

**Test Scenarios**: {specific security test cases}
**Risks**: {security vulnerability risks}

### Scalability
| Dimension | Current | Target | Test Approach |
|-----------|---------|--------|--------------|
| Concurrent users | {N} | {target} | Load ramp test |
| Data volume | {size} | {target} | Data growth simulation |
| Geographic distribution | {regions} | {target} | Latency testing |

### Availability
| Metric | Target | Test Approach |
|--------|--------|--------------|
| Uptime SLA | {99.X%} | Chaos engineering |
| Recovery time (RTO) | < {N} min | Failover drill |
| Recovery point (RPO) | < {N} min | Backup restore test |
| Graceful degradation | {behavior} | Fault injection |

### Accessibility
| Standard | Level | Test Approach | Tool |
|----------|-------|--------------|------|
| WCAG | {2.1 AA} | Automated + manual audit | {tool} |
| Screen reader | {readers} | Manual testing | {reader} |
| Keyboard navigation | Full support | Manual testing | — |
```

### 3. Priority Matrix [EXPLICIT]

```markdown
## NFR Priority Matrix

| NFR Category | Business Impact | Current Gap | Test Effort | Priority |
|-------------|----------------|-------------|-------------|----------|
| Performance | High/Med/Low | {gap} | {effort} | P1/P2/P3 |
| Security | High/Med/Low | {gap} | {effort} | P1/P2/P3 |
| Scalability | High/Med/Low | {gap} | {effort} | P1/P2/P3 |
| Availability | High/Med/Low | {gap} | {effort} | P1/P2/P3 |
| Accessibility | High/Med/Low | {gap} | {effort} | P1/P2/P3 |
```

### 4. Recommendations [EXPLICIT]

```markdown
## Recommendations

**Immediate** (this sprint):
1. {action}

**Short-term** (next 2-4 sprints):
1. {action}

**Long-term** (quarter+):
1. {action}

**Investment needed**: {tools, infrastructure, expertise}
```

### 5. Bridge to Pipeline [EXPLICIT]

- `/bmad-tea-test-design` — Full test strategy incorporating NFR tests
- `/bmad-tea-trace` — Trace NFR requirements to test coverage
- `/bmad-architect` — Review architecture for NFR support
- `/sdd:test` — Generate specific test scenarios for NFR criteria

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User has or can define SLA targets | Suggest industry defaults if no targets exist |
| 2 | All 5 NFR categories are relevant | Assess only categories the user specifies |
| 3 | Tool suggestions are indicative | Confirm tool availability with user |
| 4 | Assessment is gap analysis, not execution | For execution, bridge to specific test skills |
| 5 | Regulatory requirements are known | Ask about compliance requirements if not stated |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | User only cares about one NFR (e.g., performance) | Deep-dive on that category only |
| 2 | No SLA targets defined | Suggest industry-standard targets as starting point |
| 3 | Early-stage project with no infrastructure | Focus on architectural NFR decisions, defer testing |
| 4 | Regulated industry | Emphasize compliance-related NFRs and audit requirements |
| 5 | Existing performance issues in production | Prioritize immediate diagnostic testing |

## Good vs Bad Example

**Good**: User asks "Assess NFRs for our e-commerce platform" → Skill produces assessment across all 5 categories with specific metrics (P95 < 200ms, 99.9% uptime, WCAG 2.1 AA), identifies gaps (no load testing, no DAST), priority matrix (security P1, performance P1, accessibility P2), and actionable recommendations by timeframe.

**Bad**: User asks "Assess NFRs" → Skill says "you should test performance and security" with no metrics, no tools, no priority matrix.

## Validation Gate [EXPLICIT]

- [ ] V1: NFR categories are identified and scoped
- [ ] V2: Each category has metrics, targets, and test approaches
- [ ] V3: Tools are recommended per category
- [ ] V4: Priority matrix ranks NFRs by business impact and gap
- [ ] V5: Recommendations are timeboxed (immediate/short/long)
- [ ] V6: Bridge to next pipeline step
