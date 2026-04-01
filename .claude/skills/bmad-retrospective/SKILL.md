---
name: bmad-retrospective
description: >-
  This skill should be used when the user asks to "run a retrospective", "sprint retro",
  "what went well and what to improve", "iteration review", "continuous improvement session",
  or "lessons learned from the sprint". It facilitates a structured sprint retrospective
  producing actionable improvements with owners and deadlines. Distinct from /bmad-scrum-master
  (full ceremony agent) — this is the focused retrospective workflow.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Retrospective — Sprint Retrospective Ceremony [EXPLICIT]

Facilitate a structured sprint retrospective to reflect on what went well, what to improve, and generate actionable improvements with owners and deadlines.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the sprint or iteration to retrospect on.

## Execution Flow

### 1. Set Retrospective Context [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Sprint/iteration**: Which sprint just ended
- **Sprint goal**: Was it met? Partially? Not at all?
- **Team mood**: Any known frustrations or celebrations
- **Key events**: Incidents, blockers, wins during the sprint

Check for existing data:
- Sprint planning artifacts (goal, committed stories)
- Velocity data (planned vs delivered)
- Session logs or tasklog entries

### 2. Select Retrospective Format [EXPLICIT]

Choose the format based on team context:

| Format | Structure | Best For |
|--------|-----------|----------|
| **Start-Stop-Continue** | 3 columns: start doing, stop doing, continue doing | Quick retros, established teams |
| **4Ls** | Liked, Learned, Lacked, Longed For | Emotional reflection, new teams |
| **Sailboat** | Wind (helps), Anchor (slows), Rocks (risks), Island (goal) | Visual thinkers, stuck teams |
| **Mad-Sad-Glad** | Emotional categorization | After difficult sprints |
| **What Went Well / What to Improve** | Classic 2-column | Default, universal |

State which format you are using and why.

### 3. Gather Observations [EXPLICIT]

For the selected format, generate structured observations:

```markdown
## Retrospective: Sprint {N}

**Format**: {selected format}
**Sprint Goal**: {goal} — {Met ✅ | Partially ⚠️ | Missed ❌}
**Velocity**: {delivered} / {committed} points ({percentage}%)

### ✅ What Went Well
1. {observation with specific evidence}
2. {observation with specific evidence}
3. {observation with specific evidence}

### 🔧 What to Improve
1. {observation with specific evidence}
2. {observation with specific evidence}
3. {observation with specific evidence}

### 💡 Key Insights
- {pattern or lesson learned}
```

### 4. Generate Action Items [EXPLICIT]

Convert observations into concrete, actionable improvements:

```markdown
## Action Items

| # | Action | Owner | Deadline | Category |
|---|--------|-------|----------|----------|
| 1 | {specific, measurable action} | {person} | {date} | Process |
| 2 | {specific, measurable action} | {person} | {date} | Technical |
| 3 | {specific, measurable action} | {person} | {date} | Communication |

**Carryover from last retro**: {actions still pending from previous retrospective}
```

Limit to 3-5 action items. Too many = none get done.

### 5. Bridge to Next Sprint [EXPLICIT]

- `/bmad-sprint-planning` — Plan the next sprint incorporating retro actions
- `/bmad-scrum-master` — Full ceremony facilitation
- `/sdd:sentinel` — Check project health before next sprint
- `/sdd:insights` — Review trends across sprints

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Sprint data is available for reflection | Generate observations from user input if no data |
| 2 | 3-5 action items is the right range | More dilutes focus; fewer may miss important items |
| 3 | Each action has a clear owner | If team is solo, all actions are self-assigned |
| 4 | Retrospective is blameless | Focus on systems and processes, not individuals |
| 5 | Format choice affects quality of reflection | Suggest the format most suited to the context |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | First sprint — no prior retro to reference | Skip carryover section, focus on initial observations |
| 2 | Solo developer, no team | Adapt to personal reflection: "What did I learn?" |
| 3 | Sprint was a complete failure | Use Mad-Sad-Glad format, focus on systemic causes |
| 4 | Everything went perfectly | Celebrate, but still find 1-2 improvements (complacency risk) |
| 5 | User provides very little context | Ask 3 questions: biggest win, biggest frustration, one thing to change |

## Good vs Bad Example

**Good**: User asks "Run a retro for Sprint 2" → Skill checks sprint data, selects Start-Stop-Continue format for the established team, notes velocity was 85% of commitment, identifies 3 wins (clean deploys, good test coverage, clear stories), 3 improvements (late PR reviews, flaky CI, unclear priorities mid-sprint), generates 4 action items with owners and deadlines, checks for carryover from Sprint 1 retro.

**Bad**: User asks "Run a retro" → Skill says "What went well? What didn't?" with no structure, no data, no action items, no format selection.

## Validation Gate [EXPLICIT]

- [ ] V1: Sprint context (number, goal, velocity) was established
- [ ] V2: Retrospective format was selected and justified
- [ ] V3: Observations include specific evidence
- [ ] V4: 3-5 action items with owners and deadlines
- [ ] V5: Carryover from prior retro is addressed
- [ ] V6: Bridge to next sprint is suggested
