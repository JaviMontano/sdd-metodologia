---
name: bmad-brainstorming
description: >-
  This skill should be used when the user asks to "brainstorm", "ideate", "generate ideas",
  "creative session", "explore possibilities", "divergent thinking", "what could we build",
  or "help me come up with ideas". It facilitates structured creative ideation using 60+
  techniques from BMAD's brainstorming toolkit. Use this skill BEFORE the specification
  pipeline — it is a pre-pipeline divergent-thinking phase.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Brainstorming — Creative Ideation Session [EXPLICIT]

Facilitate a structured brainstorming session using proven ideation techniques to generate, evaluate, and refine ideas before entering the specification pipeline.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the problem space or opportunity to brainstorm.

## Execution Flow

### 1. Frame the Problem Space [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Problem or opportunity**: What are we brainstorming about?
- **Constraints**: Time, budget, technical, regulatory limits
- **Audience**: Who benefits from the solution?
- **Scope**: Greenfield exploration vs improvement of existing system

If `$ARGUMENTS` is vague, ask 2-3 focusing questions before proceeding.

### 2. Select Ideation Technique [EXPLICIT]

Choose 1-2 techniques based on the problem type:

| Category | Techniques | Best For |
|----------|-----------|----------|
| **Divergent** | Crazy 8s, SCAMPER, Random Entry, Worst Possible Idea | Generating volume of ideas |
| **Convergent** | Affinity Mapping, Dot Voting, Impact/Effort Matrix | Narrowing down ideas |
| **Structured** | How Might We, 5 Whys, Jobs-to-Be-Done | Problem reframing |
| **Analogical** | Biomimicry, Cross-Industry Transfer, Metaphor Mapping | Novel connections |
| **Constraint-Based** | Reverse Brainstorm, Subtract to Add, Time Boxing | Breaking mental models |
| **User-Centered** | Empathy Map, Day-in-the-Life, Pain/Gain Map | User-focused innovation |

State which technique(s) you are using and why.

### 3. Generate Ideas [EXPLICIT]

Run the selected technique(s). For each idea, provide:

```markdown
### Idea {N}: {Title}
- **Description**: 1-2 sentences
- **Target User**: Who benefits
- **Key Differentiator**: Why this is interesting
- **Feasibility Signal**: 🟢 Straightforward | 🟡 Requires research | 🔴 High uncertainty
```

Generate **at minimum 5 ideas**, ideally 8-12. Quantity over quality in this phase — wild ideas are welcome.

### 4. Evaluate and Cluster [EXPLICIT]

Group ideas into themes, then score the top 3-5 using:

| Idea | User Value | Technical Feasibility | Novelty | Time to MVP | Score |
|------|-----------|----------------------|---------|-------------|-------|
| {title} | 1-5 | 1-5 | 1-5 | 1-5 | /20 |

### 5. Bridge to Pipeline [EXPLICIT]

Recommend next steps for the top-rated ideas:

- `/bmad-analyst` — Deep research on a specific idea
- `/bmad-prfaq` — Validate idea with Working Backwards
- `/sdd:spec` — Jump straight to specification if idea is clear
- `/bmad-party-mode` — Debate between top candidates

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User has a problem space in mind | Ask focusing questions if vague |
| 2 | 5-12 ideas is a productive range | Scale up or down based on problem complexity |
| 3 | Feasibility scores are rough estimates | Flag that scoring is directional, not definitive |
| 4 | Ideas may overlap or combine | Encourage merging during clustering phase |
| 5 | This is pre-pipeline — no commitment required | Make clear that brainstorming ≠ commitment |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | User already knows what to build | Suggest `/sdd:spec` or `/bmad-analyst` instead |
| 2 | Problem space is extremely broad | Narrow with constraints before brainstorming |
| 3 | User wants to brainstorm improvements, not new ideas | Use SCAMPER or Subtract to Add techniques |
| 4 | Only 1-2 ideas emerge | Switch technique and run a second round |
| 5 | Ideas are all similar | Apply Random Entry or Cross-Industry Transfer to force divergence |

## Good vs Bad Example

**Good**: User asks "What could we build for remote team wellness?" → Skill selects Empathy Map + Crazy 8s. Generates 10 ideas ranging from async mood check-ins to gamified break reminders. Clusters into 3 themes (awareness, engagement, accountability). Scores top 5. Recommends `/bmad-analyst` for the top-rated idea.

**Bad**: User asks "What could we build for remote team wellness?" → Skill lists 3 obvious ideas (Slack bot, dashboard, survey) with no structure, no evaluation, no technique attribution.

## Validation Gate [EXPLICIT]

- [ ] V1: Problem space was clearly framed
- [ ] V2: Ideation technique was explicitly selected and justified
- [ ] V3: At least 5 ideas were generated with structured descriptions
- [ ] V4: Ideas were clustered and scored
- [ ] V5: Top ideas include a recommended next pipeline step
