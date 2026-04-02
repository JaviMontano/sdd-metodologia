---
description: "SDD — Command palette with all available commands"
user-invocable: true
---

# /sdd:menu

Display the complete SDD command palette.

## Execution

First run `bash scripts/sdd-next-step.sh .` to show the recommended next action, then display the palette:

## Output Format

```
╔══════════════════════════════════════════════════════════════╗
║  SDD — Spec Driven Development · MetodologIA Edition   ║
╚══════════════════════════════════════════════════════════════╝

PIPELINE PHASES
  /sdd:core             Project init, status, feature selection
  /sdd:00-constitution  Define governance principles
  /sdd:01-specify       Feature specification from NL              [alias: /sdd:spec]
  /sdd:clarify          Resolve ambiguities in any artifact
  /sdd:02-plan          Technical design                           [alias: /sdd:plan]  [GATE]
  /sdd:03-checklist     Quality requirements checklists             [alias: /sdd:check]
  /sdd:04-testify       BDD Gherkin test specs                     [alias: /sdd:test]
  /sdd:05-tasks         Dependency-ordered task breakdown           [alias: /sdd:tasks]
  /sdd:06-analyze       Cross-artifact consistency                  [alias: /sdd:analyze] [GATE]
  /sdd:07-implement     Execute implementation                     [alias: /sdd:impl]  [GATE]
  /sdd:08-issues        Export tasks to GitHub Issues               [alias: /sdd:issues]

WORKFLOW (Friction Removers)
  /sdd:a                Auto-advance to next phase                 [alias: /sdd:advance]
  /sdd:resume           Restore context after absence
  /sdd:export           Export feature artifacts as Markdown/HTML

UTILITIES
  /sdd:bugfix           Bug report + fix tasks                     [alias: /sdd:fix]
  /sdd:feature          Create, select, or list features
  /sdd:sync             Sync upstream IIC/kit + reapply brand
  /sdd:dashboard        Generate Neo-Swiss branded dashboard
  /sdd:status           Pipeline overview + next step advisor
  /sdd:verify           Run verification suite (8 categories)
  /sdd:hooks            Install git hooks for assertion integrity
  /sdd:menu             This command palette

WORKSPACE
  /sdd:workspace        Manage per-task workspace sessions (create/list/select/archive)

KNOWLEDGE & MEMORY
  /sdd:capture          Capture session inputs to RAG memory files
  /sdd:memory           Browse and search RAG memory archive
  /sdd:graph            Build knowledge graph with orphan detection

INTELLIGENCE
  /sdd:sentinel         Autonomous heartbeat agent
  /sdd:insights         Health trends, risks, recommendations
  /sdd:qa               Generate QA plan with DoD

EXPERIENCE
  /sdd:tour             Guided onboarding (8 steps)
  /sdd:demo             Generate demo project + dashboard
  /sdd:seed             Seed demo data

[GATE] = Critical gate — halts pipeline on violations. Never skip.
Orchestrator: agents/sdd-orchestrator.md
Upstream: intent-integrity-chain/kit (MIT) · Brand: MetodologIA (GPL-3.0)
```
