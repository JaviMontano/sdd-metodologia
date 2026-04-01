---
name: bmad-advanced-elicitation
description: >-
  This skill should be used when the user asks to "refine this output", "push deeper",
  "stress-test this decision", "use elicitation techniques", "apply Six Thinking Hats",
  "red team this", "challenge assumptions", or "brainstorm alternatives". It applies 50+
  iterative refinement methods to systematically improve content through multiple analytical
  passes. Use this skill when LLM output feels shallow or needs deeper critical thinking.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Advanced Elicitation — Iterative Refinement Methods [EXPLICIT]

Apply structured elicitation techniques to systematically deepen, challenge, and improve content through multiple analytical passes using proven frameworks.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input. Expected: content to refine OR a topic to explore, optionally with a preferred technique.

## Execution Flow

### 1. Analyze Input Content [EXPLICIT]

- Identify the content type: decision, spec, architecture, feature, strategy, or general text
- Assess current quality: surface-level, adequate, or already deep
- Determine which elicitation category fits best

### 2. Present Technique Menu [EXPLICIT]

Select 5 best-fit methods from the library and present as an interactive menu:

**Analytical Methods**:
- **Six Thinking Hats**: Facts (white), Feelings (red), Caution (black), Benefits (yellow), Creativity (green), Process (blue)
- **SWOT Analysis**: Strengths, Weaknesses, Opportunities, Threats
- **Five Whys**: Drill to root cause by asking "why?" iteratively
- **Pre-Mortem**: "Imagine this failed — what went wrong?"

**Adversarial Methods**:
- **Red Team vs Blue Team**: Attack the proposal, then defend it
- **Devil's Advocate**: Systematically argue against every point
- **Hindsight 20/20**: "If this launched and failed 6 months later, what would the 'if only...' statements be?"
- **Worst-Case Scenario**: Assume every risk materializes — what happens?

**Creative Methods**:
- **SCAMPER**: Substitute, Combine, Adapt, Modify, Put to other uses, Eliminate, Reverse
- **Reverse Brainstorming**: "How could we make this fail?"
- **Analogy Transfer**: Find a parallel in a different domain
- **Constraint Removal**: "If you had unlimited budget/time, what would you do differently?"

**Persona Methods**:
- **Role-Playing**: Critique from a specific user persona's perspective
- **Stakeholder Mapping**: Evaluate impact on each stakeholder group
- **Beginner's Mind**: Explain as if to someone with zero context
- **Angry Customer**: What would the most dissatisfied user say?

**Synthesis Methods**:
- **Forced Ranking**: Rank all options by a single criterion
- **Decision Matrix**: Score options across multiple weighted criteria
- **Tree of Thought**: Explore multiple reasoning paths, evaluate each
- **Dialectical Inquiry**: Thesis → Antithesis → Synthesis

### 3. Apply Selected Technique [EXPLICIT]

Execute the chosen method:
1. State the technique and its purpose
2. Apply it step-by-step to the content
3. Present findings and enhanced version
4. Offer to apply another technique or proceed

### 4. Iterate [EXPLICIT]

After each application:
- Present the improved content
- Offer: (1) Apply another technique, (2) Shuffle for new options, (3) Proceed with current version
- Track which techniques have been applied to avoid repetition

### 5. Present Final Output [EXPLICIT]

```markdown
## 🔍 Elicitation Complete

**Techniques Applied**: {list}
**Passes**: {count}
**Key Improvements**:
- {improvement 1}
- {improvement 2}

### Enhanced Content
{the refined output}

### Insights Discovered
{non-obvious findings from the elicitation process}
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User provides content or topic to refine | Ask for content if `$ARGUMENTS` is empty |
| 2 | 1-3 technique passes are sufficient | Allow unlimited iteration at user's discretion |
| 3 | Techniques are domain-agnostic | Select techniques appropriate to content type |
| 4 | User knows when they're satisfied | Present clear "proceed" option after each pass |
| 5 | This is a single LLM applying techniques | Be transparent about the methodology, not the execution |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Content is already highly refined | Acknowledge quality, suggest only adversarial/stress-test methods |
| 2 | User requests a specific technique by name | Skip the menu, apply that technique directly |
| 3 | No clear content provided, just a topic | Generate initial content first, then refine |
| 4 | User wants to apply ALL techniques | Warn about diminishing returns, suggest top 5 |
| 5 | Technique reveals fundamental flaw in content | Flag as critical finding, suggest rework |

## Good vs Bad Example

**Good**: User submits a PRD section on user authentication → Skill offers 5 relevant techniques → User picks "Pre-Mortem" → Analysis reveals missing account recovery flow and rate limiting → Enhanced PRD includes both. User then picks "Role-Playing as a new user" → Discovers onboarding flow is confusing → Fixed.

**Bad**: User submits the same PRD → Skill dumps a generic "SWOT analysis" without tailoring to the content, adds boilerplate strengths/weaknesses that could apply to any feature.

## Validation Gate [EXPLICIT]

- [ ] V1: Input content or topic was identified
- [ ] V2: 5 relevant techniques were selected and presented
- [ ] V3: At least one technique was applied with step-by-step execution
- [ ] V4: Enhanced content was presented after each pass
- [ ] V5: User had the option to iterate or proceed
- [ ] V6: Key improvements and insights were summarized
