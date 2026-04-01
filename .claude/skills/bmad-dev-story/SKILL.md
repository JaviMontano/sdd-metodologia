---
name: bmad-dev-story
description: >-
  This skill should be used when the user asks to "write a dev story", "create an implementable
  story", "break down a user story for development", "story with acceptance criteria", or
  "developer-ready story". It generates a fully implementable development story with detailed
  acceptance criteria, technical notes, test scenarios, and subtasks. Distinct from /sdd:tasks
  (task breakdown) — this produces story-level detail ready for a developer to pick up.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Dev Story — Implementable Development Story [EXPLICIT]

Generate a developer-ready story with detailed acceptance criteria, technical implementation notes, test scenarios, and subtask breakdown.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the feature or requirement to convert into a dev story.

## Execution Flow

### 1. Understand the Requirement [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Feature/requirement**: What needs to be built
- **User persona**: Who benefits (from PRD or spec if available)
- **Context**: Related stories, dependencies, constraints

Check for existing artifacts:
- `.specify/spec.md` — Source requirements
- `.specify/plan.md` — Technical plan and architecture
- `.specify/tasks.md` — Existing task breakdown

### 2. Write the User Story [EXPLICIT]

```markdown
## Story: {Title}

**As a** {persona/role}
**I want to** {capability/action}
**So that** {business value/outcome}

**Priority**: Must | Should | Could | Won't
**Points**: {estimate}
**Sprint**: {sprint number if known}
```

### 3. Define Acceptance Criteria [EXPLICIT]

Write acceptance criteria in Given-When-Then format:

```markdown
## Acceptance Criteria

### AC-1: {Scenario name}
- **Given** {precondition}
- **When** {action}
- **Then** {expected result}

### AC-2: {Scenario name}
- **Given** {precondition}
- **When** {action}
- **Then** {expected result}

### AC-3: {Error/edge scenario}
- **Given** {precondition}
- **When** {error condition}
- **Then** {graceful handling}
```

Include at least: 1 happy path, 1 error path, 1 edge case.

### 4. Technical Implementation Notes [EXPLICIT]

```markdown
## Technical Notes

**Approach**: {High-level implementation strategy}
**Files to modify**: {key files or modules}
**Data changes**: {schema/model changes if any}
**API changes**: {endpoint additions/modifications if any}
**Dependencies**: {libraries, services, or other stories}

### Subtasks
- [ ] {Subtask 1}: {description} ({estimate})
- [ ] {Subtask 2}: {description} ({estimate})
- [ ] {Subtask 3}: {description} ({estimate})
```

### 5. Test Scenarios [EXPLICIT]

```markdown
## Test Scenarios

| # | Scenario | Type | Expected Result |
|---|----------|------|----------------|
| 1 | {happy path} | Unit | {result} |
| 2 | {validation} | Unit | {result} |
| 3 | {integration} | Integration | {result} |
| 4 | {edge case} | Unit | {result} |
```

### 6. Definition of Done [EXPLICIT]

```markdown
## Definition of Done
- [ ] All acceptance criteria verified
- [ ] Unit tests passing
- [ ] Code review completed
- [ ] No regression in existing tests
- [ ] Documentation updated (if applicable)
```

### 7. Bridge to Pipeline [EXPLICIT]

- `/sdd:impl` — Begin implementing this story
- `/sdd:test` — Generate BDD scenarios from acceptance criteria
- `/bmad-code-review` — Review after implementation
- `/bmad-sprint-planning` — Return to sprint planning for next story

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User provides sufficient context for the requirement | Ask clarifying questions if input is too vague |
| 2 | Story is small enough for a single sprint | Flag if story seems too large and suggest splitting |
| 3 | Given-When-Then format suits the acceptance criteria | Offer alternative formats if user prefers |
| 4 | Technical notes are guidance, not prescriptive | Developer may choose different approach |
| 5 | Test scenarios are representative, not exhaustive | Full test suite comes from `/sdd:test` |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Requirement is too large for one story | Split into 2-3 smaller stories and note dependencies |
| 2 | No existing spec or plan artifacts | Generate story from `$ARGUMENTS` alone, flag missing context |
| 3 | Purely technical story (no user-facing value) | Use "As a developer" format, focus on technical AC |
| 4 | Bug fix, not new feature | Adapt format: add "Current Behavior" vs "Expected Behavior" |
| 5 | User provides acceptance criteria already | Validate and enhance rather than overwrite |

## Good vs Bad Example

**Good**: User asks "Write a dev story for user password reset" → Skill generates story with 3 personas (end user, admin, system), 5 acceptance criteria (happy path, invalid email, expired token, rate limiting, audit log), technical notes mentioning auth module and email service, 4 subtasks with estimates, 6 test scenarios, and a DoD checklist.

**Bad**: User asks "Write a dev story for user password reset" → Skill writes "As a user I want to reset my password" with 1 vague acceptance criterion and no technical notes.

## Validation Gate [EXPLICIT]

- [ ] V1: Story follows As-a/I-want/So-that format
- [ ] V2: At least 3 acceptance criteria in Given-When-Then
- [ ] V3: Happy path, error path, and edge case are covered
- [ ] V4: Technical notes include approach and subtasks
- [ ] V5: Test scenarios are defined
- [ ] V6: Definition of Done checklist is present
