---
name: bmad-create-prd
description: >-
  This skill should be used when the user asks to "create a PRD", "write a product requirements
  document", "document product requirements", "business requirements document", or "product
  specification with personas and metrics". It generates a business-facing PRD with personas,
  success metrics, MoSCoW prioritization, and Definition of Done. Distinct from /sdd:spec
  (dev-facing) and /bmad-pm (interactive PM agent).
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Create PRD — Product Requirements Document [EXPLICIT]

Generate a comprehensive, business-facing Product Requirements Document with personas, epics, success metrics, and Definition of Done.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the product or feature to document.

## Execution Flow

### 1. Gather Context [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Product/feature name**: What is being built
- **Business objective**: Why it matters to the organization
- **Target users**: Who will use it
- **Existing context**: Check for `.specify/spec.md`, product briefs, or prior brainstorming

If critical context is missing, ask **at most 3 focused questions** before generating.

### 2. Define Personas [EXPLICIT]

Create 2-4 user personas:

```markdown
### Persona: {Name} — {Role}
- **Demographics**: {relevant context}
- **Goals**: {what they want to achieve}
- **Pain Points**: {current frustrations}
- **Tech Proficiency**: Low | Medium | High
- **Usage Frequency**: Daily | Weekly | Monthly
```

### 3. Write the PRD [EXPLICIT]

Generate the full PRD with these sections:

```markdown
# PRD: {Product/Feature Name}

## 1. Overview
- **Vision**: One-sentence product vision
- **Business Objective**: Measurable business goal
- **Success Metrics**: 2-4 KPIs with targets (e.g., "Reduce onboarding time by 40%")

## 2. Personas
{Personas from Step 2}

## 3. Epics & Requirements

### Epic 1: {Name}
| ID | Requirement | Priority | Persona | Acceptance Criteria |
|----|------------|----------|---------|-------------------|
| R-001 | {requirement} | Must | {persona} | {AC} |
| R-002 | {requirement} | Should | {persona} | {AC} |

### Epic 2: {Name}
...

## 4. Out of Scope
- {What is explicitly NOT included in this version}

## 5. Dependencies & Risks
| # | Dependency/Risk | Impact | Mitigation |
|---|----------------|--------|------------|
| 1 | {item} | High/Med/Low | {action} |

## 6. Definition of Done
- [ ] All "Must" requirements implemented and tested
- [ ] Acceptance criteria verified for each requirement
- [ ] {additional DoD items}

## 7. Timeline
| Milestone | Target Date | Deliverable |
|-----------|-------------|-------------|
| {milestone} | {date} | {what is delivered} |
```

### 4. Bridge to Pipeline [EXPLICIT]

- `/sdd:spec` — Convert PRD requirements to dev-facing specification
- `/bmad-architect` — Design system architecture from PRD
- `/bmad-sprint-planning` — Plan first sprint from epics
- `/bmad-ux-designer` — Design user flows for key epics

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User has a clear product vision | Gather context via questions if vision is unclear |
| 2 | 2-4 personas cover the user base | Ask if additional personas are needed |
| 3 | MoSCoW prioritization is appropriate | Offer RICE or value/effort as alternatives |
| 4 | PRD is a living document, not final | Note that iteration is expected |
| 5 | This generates the PRD directly (not interactive) | For interactive PM guidance, use `/bmad-pm` |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Existing spec.md already covers requirements | Acknowledge it, generate PRD as business-facing complement |
| 2 | User provides only a one-line description | Ask 3 clarifying questions before generating |
| 3 | Product is internal tooling (no external users) | Adapt personas to internal roles and workflows |
| 4 | User wants to update an existing PRD | Read existing PRD, generate diff-style updates |
| 5 | Requirements span multiple products | Split into separate PRDs or flag cross-product dependencies |

## Good vs Bad Example

**Good**: User asks "Create a PRD for a team notification system" → Skill gathers context, defines 3 personas (Team Lead, Individual Contributor, Admin), writes PRD with 3 epics (notification delivery, preferences, analytics), MoSCoW-prioritized requirements with acceptance criteria, success metrics ("reduce missed notifications by 60%"), and DoD checklist.

**Bad**: User asks "Create a PRD for a team notification system" → Skill writes a vague description with bullet points and no personas, no metrics, no prioritization, no acceptance criteria.

## Validation Gate [EXPLICIT]

- [ ] V1: Business objective and success metrics are defined
- [ ] V2: At least 2 personas with goals and pain points
- [ ] V3: Requirements are MoSCoW-prioritized with acceptance criteria
- [ ] V4: Out of scope is explicitly stated
- [ ] V5: Dependencies, risks, and DoD are included
- [ ] V6: Bridge to next pipeline step is suggested
