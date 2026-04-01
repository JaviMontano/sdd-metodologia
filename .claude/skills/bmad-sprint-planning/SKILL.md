---
name: bmad-sprint-planning
description: >-
  This skill should be used when the user asks to "plan the sprint", "sprint planning ceremony",
  "select stories for the sprint", "plan next iteration", or "capacity planning for sprint".
  It facilitates the sprint planning ceremony: defining the sprint goal, estimating team capacity,
  selecting stories within velocity, and identifying risks. Distinct from /bmad-scrum-master
  (full ceremony facilitation agent) — this is the focused sprint planning workflow.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Sprint Planning — Sprint Planning Ceremony [EXPLICIT]

Facilitate a structured sprint planning session: define the sprint goal, estimate capacity, select and commit to stories, and identify risks.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the sprint number, goals, or backlog items to plan.

## Execution Flow

### 1. Establish Sprint Context [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Sprint number**: Which sprint is being planned
- **Sprint duration**: Length in weeks (default: 2 weeks)
- **Team composition**: Number and roles of team members
- **Previous velocity**: Points completed in prior sprints (if available)

Check for existing artifacts:
- `.specify/tasks.md` — Task breakdown for story candidates
- `.specify/spec.md` — Requirements backlog
- Prior sprint data if available

### 2. Define Sprint Goal [EXPLICIT]

```markdown
## Sprint {N} Goal
**Goal**: {One clear, measurable objective for this sprint}
**Theme**: {Optional thematic grouping}
**Success Criteria**: {How we know the sprint succeeded}
```

The goal must be achievable within the sprint and align with the product roadmap.

### 3. Estimate Team Capacity [EXPLICIT]

```markdown
## Team Capacity

| Member | Role | Available Days | Capacity Factor | Story Points |
|--------|------|---------------|----------------|-------------|
| {name} | {role} | {days} | {0.6-0.8} | {points} |
| **Total** | | | | **{total}** |

**Capacity Factor**: 0.6 (new team) | 0.7 (established) | 0.8 (mature team)
**Velocity Reference**: {avg of last 3 sprints, or "No history — using conservative estimate"}
```

### 4. Select Stories [EXPLICIT]

Select stories from the backlog that fit within capacity:

```markdown
## Sprint Backlog

| # | Story | Points | Priority | Dependencies | Assignee |
|---|-------|--------|----------|-------------|----------|
| S-001 | {story title} | {pts} | Must | {deps or "None"} | {name} |
| S-002 | {story title} | {pts} | Should | {deps} | {name} |

**Committed**: {total points} / {capacity} points ({percentage}% commitment)
**Commitment Ratio**: {70-85% recommended for healthy sprints}
```

### 5. Identify Risks and Dependencies [EXPLICIT]

```markdown
## Sprint Risks

| # | Risk | Probability | Impact | Mitigation |
|---|------|------------|--------|------------|
| 1 | {risk} | High/Med/Low | High/Med/Low | {action} |

## External Dependencies
- {dependency}: {owner} — {status}
```

### 6. Bridge to Pipeline [EXPLICIT]

- `/bmad-dev-story` — Break selected stories into implementable tasks
- `/sdd:tasks` — Generate task breakdown for committed stories
- `/sdd:impl` — Begin implementation of top-priority story
- `/bmad-scrum-master` — Full ceremony facilitation including standup setup

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Team has a defined backlog | If no backlog, suggest `/bmad-create-prd` or `/sdd:spec` first |
| 2 | Story points are the estimation unit | Support time-based estimates if user prefers |
| 3 | 70-85% commitment ratio is healthy | Flag over-commitment (>90%) as a risk |
| 4 | Sprint is 1-4 weeks | Adapt ceremony depth to sprint length |
| 5 | Previous velocity may not exist | Use conservative defaults for first sprint |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | First sprint ever — no velocity data | Use conservative estimate (60% of theoretical capacity) |
| 2 | Solo developer, no team | Simplify to personal sprint with 1 capacity row |
| 3 | Backlog is empty or undefined | Redirect to `/bmad-create-prd` or `/sdd:spec` |
| 4 | Stories exceed capacity | Help user prioritize and defer lower-priority items |
| 5 | Mid-sprint re-planning | Acknowledge remaining capacity and adjust scope |

## Good vs Bad Example

**Good**: User asks "Plan Sprint 3 for our 4-person team" → Skill checks existing backlog, asks about velocity history, defines sprint goal, calculates capacity (4 members × 8 days × 0.7 = 22.4 pts), selects 6 stories totaling 20 pts (89% commitment — flags slightly high), identifies 2 risks, suggests `/bmad-dev-story` for the top story.

**Bad**: User asks "Plan Sprint 3" → Skill lists all backlog items without capacity analysis, no sprint goal, no commitment ratio, no risk identification.

## Validation Gate [EXPLICIT]

- [ ] V1: Sprint goal is defined and measurable
- [ ] V2: Team capacity is calculated with factors
- [ ] V3: Stories are selected within velocity/capacity
- [ ] V4: Commitment ratio is stated and in healthy range
- [ ] V5: Risks and dependencies are identified
- [ ] V6: Bridge to next step is suggested
