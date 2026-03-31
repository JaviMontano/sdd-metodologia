---
name: sdd-tour
description: >-
  This skill should be used when the user asks to "start tour", "onboard me to SDD",
  "show me around", "walk me through the pipeline", "how does SDD work",
  or "give me a guided introduction". It runs an 8-step interactive walkthrough
  of the SDD pipeline covering constitution, specs, plan, checklist, testify, tasks,
  analyze, implement, and ship. Use this skill for onboarding, orientation, or learning SDD.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Tour — 8-Step Guided Onboarding Walkthrough [EXPLICIT]

Interactive 8-step tour of the SDD pipeline from Constitution to Ship.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). If a step number is provided, jump to that step.

## Tour Steps

Present each step interactively, waiting for user acknowledgment before proceeding.

### Step 1: Welcome & Philosophy
- SDD = Spec Driven Development
- Intent preservation from idea to implementation
- 9-phase pipeline with 3 quality gates
- Constitution-first governance

### Step 2: Constitution (Phase 0)
- `/sdd:00-constitution` — governance principles
- Principles trace through all artifacts
- Show: CONSTITUTION.md structure

### Step 3: Specify (Phase 1)
- `/sdd:01-specify` — user stories, FR, SC from natural language
- Show: spec.md structure with FR-NNN numbering

### Step 4: Plan (Phase 2) + Gate G1
- `/sdd:02-plan` — architecture, data model, API contracts
- **Gate G1**: Halts if spec incomplete
- Show: plan.md structure

### Step 5: Checklist + Testify (Phases 3-4)
- `/sdd:03-checklist` — quality analysis
- `/sdd:04-testify` — BDD scenarios with SHA-256 assertion hashing
- Show: .feature file with hash

### Step 6: Tasks + Analyze (Phases 5-6) + Gate G2
- `/sdd:05-tasks` — dependency-ordered task breakdown
- `/sdd:06-analyze` — cross-artifact consistency
- **Gate G2**: Halts on inconsistencies

### Step 7: Implement (Phase 7) + Gate G3
- `/sdd:07-implement` — iterative TDD implementation
- **Gate G3**: Halts if tests fail
- Show: implementation loop

### Step 8: Ship + Intelligence
- `/sdd:08-issues` — export to GitHub Issues
- `/sdd:sentinel` — ambient health monitoring
- `/sdd:dashboard` — ALM Command Center
- Show: dashboard URL

## Report (per step)

```
Tour Step N/8: <Title>

<Explanation with key concepts>

Commands: /sdd:<relevant-command>
Try it: <suggestion>

[Enter to continue, or type a step number to jump]
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Tour is interactive — one step at a time | Wait for user input between steps. [EXPLICIT] |
| 2 | No project modifications during tour | Tour is read-only and informational. [EXPLICIT] |
| 3 | User may jump to specific steps | Accept step number as argument. [EXPLICIT] |
| 4 | Tour works without initialized project | Explains concepts without requiring existing artifacts. [EXPLICIT] |
| 5 | Demo data enhances the tour | Suggest `/sdd:demo` first for hands-on exploration. [INFERRED] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| User wants specific step | Argument is a number (1-8) | Jump directly to that step. [EXPLICIT] |
| User wants to exit mid-tour | User says "stop", "exit", "done" | End tour gracefully with summary of remaining steps. [EXPLICIT] |
| User has existing project | specs/ has real features | Reference their actual project in explanations. [INFERRED] |
| User is experienced | User says "skip basics" | Offer condensed tour (key concepts only). [INFERRED] |
| No terminal interaction | Non-interactive context | Present all 8 steps sequentially without pause. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:tour` guides step by step
```
Tour Step 1/8: Welcome & Philosophy

SDD (Spec Driven Development) preserves your intent from idea to code.
Pipeline: Constitution → Specify → Plan → Check → Test → Tasks → Analyze → Implement → Ship
Gates: G1 (post-plan), G2 (post-analyze), G3 (post-implement)

Try: /sdd:demo to generate a sample project

[Enter for Step 2, or type a step number]
```

**Bad**: Tour dumps everything at once
```
x All 8 steps in one wall of text
x No interactivity
x No try-it suggestions
```

**Why**: Tour must be interactive, step-by-step, with actionable suggestions per step. [EXPLICIT]

## Validation Gate

Before marking tour as complete, verify: [EXPLICIT]

- [ ] V1: All 8 steps presented (or user exited early)
- [ ] V2: Each step includes relevant commands
- [ ] V3: Each step includes try-it suggestion
- [ ] V4: Pipeline flow explained with gates
- [ ] V5: Dashboard URL provided in final step
