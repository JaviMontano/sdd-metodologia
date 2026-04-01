---
name: bmad-prfaq
description: >-
  This skill should be used when the user asks to "write a PRFAQ", "working backwards",
  "Amazon-style product validation", "press release FAQ", "validate product idea with PRFAQ",
  or "challenge this product concept". It generates a Working Backwards document (Press Release
  + FAQ) that stress-tests a product idea by writing the future press release announcing it
  and answering skeptical questions. Use this for product validation before heavy investment.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD PRFAQ — Working Backwards Product Validation [EXPLICIT]

Generate a Working Backwards document (Press Release + FAQ) to validate a product idea by imagining its successful launch and stress-testing assumptions through skeptical questions.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines the product or feature idea to validate.

## Execution Flow

### 1. Understand the Product Vision [EXPLICIT]

Extract from `$ARGUMENTS`:
- **Product/feature**: What is being proposed
- **Target customer**: Who will use it
- **Problem solved**: What pain point it addresses
- **Desired outcome**: What success looks like

If context is insufficient, ask **at most 3 questions** to clarify the vision.

### 2. Write the Press Release [EXPLICIT]

Write as if the product has already launched successfully:

```markdown
## Press Release

**{City}, {Date}** — {Company/Team} today announced {Product Name}, a {brief description}
that {key benefit} for {target customer}.

### The Problem
{2-3 sentences describing the customer pain point in vivid, specific terms}

### The Solution
{2-3 sentences describing what the product does and why it's different}

### How It Works
{3-4 bullet points describing the key features and user experience}

### Customer Quote
> "{Fictional customer testimonial expressing how the product changed their workflow}"
> — {Persona Name}, {Role}

### Getting Started
{1-2 sentences on how customers can begin using the product}
```

### 3. Write the Internal FAQ [EXPLICIT]

Answer skeptical questions from stakeholders:

```markdown
## Internal FAQ

### Customer Questions
**Q: Why would customers choose this over {existing alternative}?**
A: {Honest answer with specific differentiators}

**Q: What happens if {common failure scenario}?**
A: {How the product handles it}

**Q: How much does it cost / what's the pricing model?**
A: {Pricing approach and justification}

### Stakeholder Questions
**Q: How big is the addressable market?**
A: {Market sizing with basis for estimate}

**Q: What's the technical feasibility risk?**
A: {Honest assessment of technical challenges}

**Q: What's the estimated time-to-market?**
A: {Rough timeline with key milestones}

**Q: What if we build it and nobody wants it?**
A: {Validation strategy: how to test demand before full build}

### Technical Questions
**Q: What's the high-level architecture?**
A: {1-2 sentence architecture overview}

**Q: What are the key technical dependencies?**
A: {Critical technical requirements}
```

### 4. Assess Confidence [EXPLICIT]

```markdown
## Confidence Assessment

| Dimension | Confidence | Evidence |
|-----------|-----------|---------|
| Customer need exists | 🟢/🟡/🔴 | {basis} |
| Solution is technically feasible | 🟢/🟡/🔴 | {basis} |
| Market is large enough | 🟢/🟡/🔴 | {basis} |
| Team can execute | 🟢/🟡/🔴 | {basis} |
| Timing is right | 🟢/🟡/🔴 | {basis} |

**Overall Verdict**: Proceed ✅ | Needs more validation ⚠️ | Reconsider ❌
**Biggest risk**: {the one thing most likely to derail this}
```

### 5. Bridge to Pipeline [EXPLICIT]

Based on the verdict:
- **Proceed** → `/bmad-create-prd` or `/sdd:spec` to formalize requirements
- **Needs validation** → `/bmad-analyst` for deeper research, `/bmad-party-mode` for debate
- **Reconsider** → `/bmad-brainstorming` to explore alternatives

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | User has a product idea to validate | If vague, suggest `/bmad-brainstorming` first |
| 2 | Press release is written as if product succeeded | Make clear this is a thought exercise, not announcement |
| 3 | FAQ questions are genuinely skeptical | Avoid softball questions that don't challenge assumptions |
| 4 | Confidence assessment is subjective | Base on available evidence, flag where evidence is thin |
| 5 | PRFAQ doesn't replace market research | Recommend `/bmad-analyst` for deeper validation |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Product is an internal tool (no press release audience) | Adapt press release to internal announcement format |
| 2 | User has already validated the idea | Focus FAQ on execution risks rather than market validation |
| 3 | Idea is very early stage (just a hunch) | Write aspirational press release, heavy on FAQ validation |
| 4 | Multiple competing ideas | Write mini-PRFAQs for each, compare confidence scores |
| 5 | User disagrees with confidence assessment | Present evidence transparently, defer to user judgment |

## Good vs Bad Example

**Good**: User asks "PRFAQ for a CLI tool that auto-generates API docs from code" → Skill writes compelling press release targeting developer audience, includes realistic customer quote, FAQ addresses "why not Swagger?" and "what about accuracy?", confidence assessment shows 🟢 for need and feasibility but 🟡 for market size, recommends proceeding with `/sdd:spec` after user validation interviews.

**Bad**: User asks "PRFAQ for an API docs tool" → Skill writes a marketing-style blurb with no FAQ, no skeptical questions, no confidence assessment.

## Validation Gate [EXPLICIT]

- [ ] V1: Press release follows the Working Backwards format
- [ ] V2: Customer pain point is vividly described
- [ ] V3: FAQ includes genuinely skeptical questions (not softballs)
- [ ] V4: FAQ covers customer, stakeholder, and technical categories
- [ ] V5: Confidence assessment with evidence per dimension
- [ ] V6: Clear verdict with recommended next step
