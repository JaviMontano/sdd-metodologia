---
name: sdd-menu
description: >-
  This skill should be used when the user asks to "show menu", "list all commands",
  "what commands are available", "show command palette", "help with SDD commands",
  or "what can SDD do". It displays the interactive command palette organized by
  category (pipeline, intelligence, utility, experience) with descriptions and aliases.
  Use this skill whenever the user mentions menu, command list, help, or available commands.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Menu — Interactive Command Palette [EXPLICIT]

Display all SDD commands organized by category with descriptions and aliases.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). If a category is provided, filter to that category.

## Command Categories

### Pipeline Commands (9 phases)

| Phase | Command | Alias | Description |
|-------|---------|-------|-------------|
| Init | `/sdd:core` | `/sdd:init` | Project init, status, feature selection |
| 0 | `/sdd:00-constitution` | — | Governance principles |
| 1 | `/sdd:01-specify` | `/sdd:spec` | User stories, FR, SC |
| — | `/sdd:clarify` | — | Resolve ambiguities |
| 2 | `/sdd:02-plan` | `/sdd:plan` | Architecture, data model, API contracts **[G1]** |
| 3 | `/sdd:03-checklist` | `/sdd:check` | BDD quality checklists |
| 4 | `/sdd:04-testify` | `/sdd:test` | Gherkin BDD with assertion hashing |
| 5 | `/sdd:05-tasks` | `/sdd:tasks` | Dependency-ordered task breakdown |
| 6 | `/sdd:06-analyze` | `/sdd:analyze` | Cross-artifact consistency **[G2]** |
| 7 | `/sdd:07-implement` | `/sdd:impl` | Iterative TDD implementation **[G3]** |
| 8 | `/sdd:08-issues` | `/sdd:issues` | Export to GitHub Issues |
| Bug | `/sdd:bugfix` | `/sdd:fix` | Bug report + fix tasks |

### Intelligence Commands

| Command | Description |
|---------|-------------|
| `/sdd:sentinel` | Full perceive-decide-act health cycle |
| `/sdd:insights` | Health trends, risk indicators, recommendations |
| `/sdd:graph` | Knowledge graph (traceability) |
| `/sdd:qa` | QA plan with gate status |
| `/sdd:dashboard` | ALM Command Center (multi-HTML) |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/sdd:workspace` | Per-task session management |
| `/sdd:feature` | Create/select/list features |
| `/sdd:status` | Pipeline overview with phase dots |
| `/sdd:verify` | 8-check verification suite |
| `/sdd:hooks` | Git hook installation |
| `/sdd:capture` | RAG memory capture |
| `/sdd:memory` | Browse RAG memory archive |
| `/sdd:sync` | Upstream IIC/kit sync + brand |

### Experience Commands

| Command | Description |
|---------|-------------|
| `/sdd:tour` | Guided 8-step onboarding |
| `/sdd:demo` | Generate demo project + dashboard |
| `/sdd:seed` | Seed demo data (no dashboard) |
| `/sdd:menu` | This command palette |

## Report

```
SDD Command Palette

Pipeline (12 commands): /sdd:init → /sdd:issues
Intelligence (5 commands): /sdd:sentinel, insights, graph, qa, dashboard
Utility (8 commands): /sdd:workspace, feature, status, verify, hooks, capture, memory, sync
Experience (4 commands): /sdd:tour, demo, seed, menu

Total: 29 commands | [G1] [G2] [G3] = quality gates

Quick start:
  New project:   /sdd:init → /sdd:01-specify
  Explore demo:  /sdd:demo
  Learn SDD:     /sdd:tour
  Check health:  /sdd:sentinel
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Menu is read-only — displays information only | No project modifications. [EXPLICIT] |
| 2 | Categories match CLAUDE.md command sections | Pipeline, Intelligence, Utility, Experience. [EXPLICIT] |
| 3 | Aliases shown where available | e.g., `/sdd:spec` for `/sdd:01-specify`. [EXPLICIT] |
| 4 | Gate markers shown for gated phases | [G1], [G2], [G3] indicate quality gates. [EXPLICIT] |
| 5 | Quick start section guides new users | Context-sensitive suggestions based on project state. [INFERRED] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Category filter | Argument matches a category name | Show only that category's commands. [EXPLICIT] |
| Search for specific command | Argument is a command name or keyword | Highlight matching command with full description. [EXPLICIT] |
| No arguments | Empty input | Show full palette with all categories. [EXPLICIT] |
| Unknown category | Argument doesn't match any category | Show full palette with "category not found" note. [EXPLICIT] |
| User wants IIKit commands too | Asks about upstream commands | Include note about `/iikit-*` commands from upstream. [INFERRED] |

## Good vs Bad Example

**Good**: `/sdd:menu` shows organized palette
```
SDD Command Palette
Pipeline: 12 commands (Constitution → Ship)
Intelligence: 5 commands
Utility: 8 commands
Experience: 4 commands

Quick start: /sdd:tour (learn) or /sdd:demo (explore)
```

**Bad**: Unorganized command dump
```
x Flat list without categories
x No aliases shown
x No gate markers
x No quick start guidance
```

**Why**: Menu must organize commands by category with aliases, gates, and quick start guidance. [EXPLICIT]

## Validation Gate

Before marking menu as complete, verify: [EXPLICIT]

- [ ] V1: All 4 categories displayed
- [ ] V2: All commands listed with descriptions
- [ ] V3: Aliases shown where available
- [ ] V4: Gate markers ([G1], [G2], [G3]) included
- [ ] V5: Quick start section with context-sensitive suggestions
