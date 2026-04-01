---
name: bmad-party-mode
description: >-
  This skill should be used when the user asks to "start party mode", "multi-agent discussion",
  "get multiple perspectives", "debate this decision", "agent collaboration session",
  or "bring in different experts". It orchestrates a multi-agent collaboration session where
  specialized BMAD agent personas (Analyst, PM, Architect, UX, SM, Dev, QA) debate a topic
  from their unique expertise. Use this skill for complex decisions requiring diverse viewpoints.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Party Mode — Multi-Agent Collaboration Session [EXPLICIT]

Orchestrate a structured debate between BMAD agent personas, each contributing from their specialized expertise to reach a well-rounded decision.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the topic or decision to debate.

## Execution Flow

### 1. Define the Topic [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Decision to make**: What specific question needs multiple perspectives
- **Context**: Any constraints, deadlines, or preferences
- **Scope**: Which agents are most relevant

### 2. Select Participating Agents [EXPLICIT]

Choose 3-5 agents most relevant to the topic from:

| Agent | Persona | Expertise | When to Include |
|-------|---------|-----------|-----------------|
| Mary | Analyst | Market research, feasibility, constraints | Business decisions, new features |
| John | PM | Requirements, priorities, user value | Scope decisions, feature trade-offs |
| Sally | UX Designer | User flows, accessibility, experience | UI decisions, user-facing changes |
| Winston | Architect | System design, tech stack, scalability | Technical decisions, infrastructure |
| Bob | Scrum Master | Sprint capacity, velocity, ceremonies | Process decisions, timeline questions |
| Amelia | Developer | Implementation feasibility, code quality | Build-vs-buy, complexity assessment |
| Quinn | QA | Test strategy, risk assessment, quality | Quality trade-offs, release readiness |

### 3. Run Debate Rounds [EXPLICIT]

Execute 2-3 structured rounds:

**Round 1 — Opening Positions**: Each agent states their perspective on the topic in 2-3 sentences, staying in character with their persona's communication style and priorities.

**Round 2 — Cross-Examination**: Agents challenge each other's positions. The Architect may question the PM's timeline. The QA may flag risks the Developer overlooked. The UX Designer may advocate for the user when others focus on technical concerns.

**Round 3 — Synthesis**: Agents converge toward a recommendation. Areas of agreement are highlighted. Remaining disagreements are noted with the rationale from each side.

### 4. Present Consensus Report [EXPLICIT]

```markdown
## 🎉 Party Mode — Multi-Agent Discussion

**Topic**: {the decision}
**Participants**: {agent names and roles}

### Round 1: Opening Positions
- **Mary (Analyst)**: {position}
- **Winston (Architect)**: {position}
...

### Round 2: Key Debates
- {Agent A} vs {Agent B}: {point of contention and resolution}
...

### Recommendation
{Synthesized recommendation with rationale}

### Dissenting Views
{Any unresolved disagreements}

### Next Action
`/bmad-{command}` — {suggested next step based on the decision}
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User provides a clear topic to debate | Ask for clarification if `$ARGUMENTS` is vague |
| 2 | 3-5 agents are sufficient for most decisions | Allow user to request specific agents |
| 3 | Each agent stays in character throughout | Use distinct communication styles per persona |
| 4 | Debates converge in 2-3 rounds | Add a 4th round if positions remain irreconcilable |
| 5 | This is a single LLM simulating multiple agents | Be transparent — this is persona simulation, not separate LLMs |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | User specifies only 1-2 agents | Include at minimum 3 for meaningful debate |
| 2 | Topic is trivial (e.g., naming a variable) | Suggest using a direct skill instead of party mode |
| 3 | Agents cannot reach consensus | Present majority vs minority positions clearly |
| 4 | User asks to include a non-BMAD perspective | Add a "Guest Expert" persona for the specific domain |
| 5 | Topic spans both technical and business domains | Include agents from both domains (min: PM + Architect) |

## Good vs Bad Example

**Good**: User asks "Should we use a monolith or microservices?" → Skill selects Winston (Architect), John (PM), Amelia (Dev), Quinn (QA). Each argues from their perspective. Winston prefers microservices for scalability. Amelia argues monolith for faster delivery. John evaluates user impact. Quinn flags testing complexity. Synthesis: start monolith, plan microservice extraction for v2.

**Bad**: User asks "Should we use a monolith or microservices?" → Skill just lists pros and cons without agent personas, no debate structure, no synthesis.

## Validation Gate [EXPLICIT]

- [ ] V1: Topic was clearly identified from user input
- [ ] V2: 3-5 relevant agents were selected with justification
- [ ] V3: Each agent maintained distinct persona voice and expertise
- [ ] V4: At least 2 rounds of structured debate occurred
- [ ] V5: A synthesized recommendation was provided
- [ ] V6: A specific next action command was suggested
