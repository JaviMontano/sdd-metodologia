# SDD v3.4 — Spec Driven Development · MetodologIA Edition

> **SDD by MetodologIA** — Spec Driven Development with Neo-Swiss branding.
> Specification-driven development with cryptographic BDD verification + ambient intelligence.
> 12 skills · 9 pipeline phases · 39 commands · 23 scripts · Per-prompt heartbeat · Knowledge graph · ALM Command Center · Per-task workspace sessions
> Upstream engine: [intent-integrity-chain/kit](https://github.com/intent-integrity-chain/kit) (MIT)
> Brand layer: GPL-3.0 · Javier Montano · MetodologIA

---

## Quick Start

```bash
/sdd:tour              # Guided onboarding tour (8 steps)
/sdd:demo              # Generate demo project + dashboard
/sdd:init              # Initialize a real project
/sdd:menu              # Command palette — all commands
```

## Ambient Intelligence

SDD runs a **per-prompt heartbeat** via `UserPromptSubmit` hook. On every user prompt:
1. `sdd-heartbeat-lite.sh` executes (< 100ms, zero LLM cost)
2. Checks: stale artifacts, missing files, health regression
3. If findings: injects 1-line context "⚡ SDD: N stale, M missing — /sdd:sentinel"
4. If healthy: silent (zero output, zero cost)
5. Suppression: 45-90 min of quiet after clean sentinel run

**Hooks active:**
- `UserPromptSubmit` → heartbeat-lite.sh (per-prompt)
- `PostToolUse (Write|Edit)` → session-log.sh (audit trail)
- `SessionStart` → heartbeat-lite.sh --init (context restore)
- `PreCompact` → session-log.sh pre-compact (state snapshot)

## SDD Pipeline Commands

| Phase | Command | Alias | Description |
|-------|---------|-------|-------------|
| Init | `/sdd:core` | `/sdd:init` | Project init, status, feature selection, help |
| 0 | `/sdd:00-constitution` | — | Governance principles — base of the system + user Phase 0 requests + derived from user specs analysis |
| 1 | `/sdd:01-specify` | `/sdd:spec` | **User Specs** — user stories, FR, SC from natural language |
| — | `/sdd:clarify` | — | Resolve ambiguities in any artifact |
| 2 | `/sdd:02-plan` | `/sdd:plan` | **Technical Specs** — architecture, data model, API contracts **[GATE G1]** |
| 3 | `/sdd:03-checklist` | `/sdd:check` | **BDD Analysis** — requirements quality checklists |
| 4 | `/sdd:04-testify` | `/sdd:test` | **Test** — Gherkin BDD scenarios with assertion hashing |
| 5 | `/sdd:05-tasks` | `/sdd:tasks` | **Task** — dependency-ordered task breakdown |
| 6 | `/sdd:06-analyze` | `/sdd:analyze` | **Organize Plan** — cross-artifact consistency **[GATE G2]** |
| 7 | `/sdd:07-implement` | `/sdd:impl` | **Deliver** — iterative TDD implementation **[GATE G3]** |
| 8 | `/sdd:08-issues` | `/sdd:issues` | **Ship** — export to GitHub Issues, deploy, close loop |
| Bug | `/sdd:bugfix` | `/sdd:fix` | Bug report + fix tasks |

**Pipeline flow**: Constitution (WHY) → User Specs (WHAT) → Technical Specs (HOW) → BDD Analysis (QUALITY) → Test (PROOF) → Task (WORK) → Organize Plan (VALIDATE) → Deliver (BUILD) → Ship (RELEASE)
**[GATE]** = Critical gate — halts on violations. Never skip phases.
**Constitution** = Base system principles + Phase 0 user requests + principles derived from user specs analysis.

## Intelligence Commands

| Command | Description |
|---------|-------------|
| `/sdd:sentinel` | Full sentinel cycle (perceive-decide-act, zero LLM cost) |
| `/sdd:insights` | Health trends, risk indicators, smart recommendations |
| `/sdd:graph` | Build knowledge graph (Constitution→FR→TS→Tasks traceability) |
| `/sdd:qa` | Generate/refresh QA-PLAN.md (DoD, acceptance criteria, gate status) |
| `/sdd:dashboard` | Generate Command Center (multi-HTML micro-frontend) |

## Utility Commands

| Command | Description |
|---------|-------------|
| `/sdd:workspace` | Manage per-task workspace sessions (create/list/select/archive) |
| `/sdd:feature` | Create, select, or list features |
| `/sdd:sync` | Sync upstream IIC/kit + reapply MetodologIA brand |
| `/sdd:status` | Pipeline overview with visual table + next step advisor |
| `/sdd:verify` | Run verification suite (structure, brand, tokens, assertions, workspace) |
| `/sdd:hooks` | Install git hooks for assertion integrity |
| `/sdd:capture` | Capture session inputs into RAG memory files |
| `/sdd:memory` | Browse and search RAG memory archive |
| `/sdd:menu` | Interactive command palette |

## Experience Commands

| Command | Description |
|---------|-------------|
| `/sdd:tour` | Guided onboarding tour (8-step interactive walkthrough) |
| `/sdd:demo` | Generate demo project + open dashboard |
| `/sdd:seed` | Seed demo data without opening dashboard |

## Knowledge Graph

SDD maintains a **knowledge graph** (`.specify/knowledge-graph.json`) tracing:
- **Principles** (P-I, P-II...) from CONSTITUTION.md
- **Requirements** (FR-NNN) from spec.md
- **Tests** (TS-NNN) from .feature files
- **Tasks** (T-NNN) from tasks.md
- **Edges**: governs, verified_by, implemented_by, validates

Orphans are detected automatically: untested requirements, untraced principles, unlinked tasks.
Run `/sdd:graph` to rebuild. Dashboard Intelligence view renders it as force-directed SVG.

## ALM — Application Lifecycle Manager

SDD includes a visual ALM (Application Lifecycle Manager) as a micro-frontend dashboard.
It visualizes the full SDD pipeline for **any project** — not tied to any specific domain.
The ALM tracks specs, plans, tests, tasks, health, traceability, and governance.

Multi-HTML system in `.specify/dashboard/`:

| Page | Views |
|------|-------|
| `index.html` | Command Center — health gauge, nav cards, activity feed |
| `pipeline.html` | Board (kanban) + Pipeline (phase dots) |
| `specs.html` | Story Map + Checklist progress |
| `quality.html` | Testify (Sankey) + Analyze + Bugs |
| `intelligence.html` | Insights (sparklines) + Graph (force-directed) + Timeline |
| `workspace.html` | Filesystem explorer + RAG memory preview |
| `governance.html` | Constitution + Principles radar + Operational logs timeline |
| `logs.html` | Unified 4-source log viewer (session, changelog, tasklog, decisions/ADRs) |
| `backlog.html` | Feature backlog board (3-column: Backlog/In Progress/Done) |
| `search.html` | Global cross-artifact search with category filters |

Shared: `nav.js` (12-tab navbar), `tokens.css` (design tokens), `search.js` (search+filter), `footer.js`, `data.js` (DASHBOARD_DATA).

**Two generators:**
- `generate-dashboard.js` — Single-file dashboard (`.specify/dashboard.html`). Legacy compat.
- `generate-command-center-data.js` — Multi-page ALM data (`.specify/shared/data.js`). Primary.

`/sdd:init` runs both. `/sdd:dashboard` refreshes both. The Command Center (multi-page) is the primary ALM; the single-file dashboard is kept for backward compatibility.

## RAG Memory System

Session inputs are captured as `rag-memory-of-{slug}.md` with:
- Frontmatter: source, type, size, tags, captured timestamp
- Abstract + Key Takeaways + Relevant Insights (LLM-generated)
- Full Content: verbatim (text), structure summary (HTML), description (image), transcription (audio)

Indexed in `.specify/rag-index.json`. Visible in Workspace view.
Capture with: `/sdd:capture <file>` or `bash scripts/sdd-rag-capture.sh <file>`

When a workspace session is active, RAG captures route to the workspace's `rag/` folder instead of `.specify/rag-memory/`. Use `--global` flag to force global routing.

## Workspace Sessions

SDD supports **per-task workspace sessions** — dated folders that isolate inputs, RAG files, logs, and tasklog per interaction/task.

**Structure:**
```
workspace/
  yyyy-mm-dd-task-name/
    inputs/          # Raw inputs dropped during conversation
    rag/             # RAG files auto-captured from inputs
    logs/            # Task-specific session logs
    tasklog.md       # Task progress table
    session.json     # {taskName, created, status, inputCount, ragCount, lastActivity}
```

**Commands:**
- `/sdd:workspace create <name>` — Create a new session and set as active
- `/sdd:workspace list` — List all sessions with stats
- `/sdd:workspace select <name>` — Set active session
- `/sdd:workspace current` — Show active session
- `/sdd:workspace archive <name>` — Archive a session

**Behavior:**
- Active workspace tracked in `.specify/active-workspace`
- RAG capture routes to active workspace's `rag/` folder
- Session logs dual-write to both global and workspace logs
- Heartbeat nudges if no workspace is active on SDD projects
- Dashboard Workspace page shows session cards with status and stats

## Scripts (27)

| Script | Purpose |
|--------|---------|
| `sdd-heartbeat-lite.sh` | **Per-prompt ambient heartbeat** (< 100ms, zero LLM) |
| `sdd-sentinel.sh` | Full sentinel perceive-decide-act cycle |
| `sdd-gate-check.sh` | **Mandatory quality gate enforcement** (G1/G2/G3 — hard stops) |
| `sdd-phase-complete.sh` | Pipeline state updater (context.json completedPhases) |
| `sdd-validate-artifact.sh` | Schema + content validation (JSON + markdown artifacts) |
| `sdd-assertion-hash.sh` | **Cryptographic SHA-256 hashing** for .feature files |
| `sdd-insights.js` | Health scores, traceability, risk analysis engine |
| `sdd-knowledge-graph.js` | Knowledge graph builder (Constitution→FR→TS→Tasks) |
| `sdd-seed-demo.sh` | Generate realistic demo project (3 features) |
| `sdd-workspace.sh` | Per-task workspace session management (create/list/select/archive) |
| `sdd-rag-capture.sh` | RAG memory capture with safety guards (10MB limit, binary detect) |
| `sdd-session-log.sh` | Session event logging with flock concurrency (PostToolUse + PreCompact) |
| `sdd-init.sh` | Project initialization with post-validation + GitHub sync |
| `sdd-status.sh` | Visual pipeline table with phase dots |
| `sdd-next-step.sh` | Next command advisor |
| `sdd-prereqs.sh` | Phase prerequisite validation (content checks + fail-fast) |
| `sdd-feature.sh` | Create/select/list features |
| `sdd-verify.sh` | Full verification suite (8 checks) |
| `sdd-hooks-install.sh` | Git hook installation |
| `generate-dashboard.js` | Single-file dashboard HTML generator (legacy) |
| `generate-command-center-data.js` | Multi-page ALM data generator (`shared/data.js`) |
| `sdd-qa-plan.js` | QA Plan generator (QA-PLAN.md + qa-plan.json) |
| `sdd-demo-serve.sh` | Serve demo data with npx serve for local preview |
| `brand-overlay.sh` | MetodologIA branding overlay |
| `brand-html-patch.js` | HTML structural patches |
| `sync-upstream.sh` | Upstream IIC/kit sync |
| `verify-brand.sh` | Brand integrity verification (palette + fonts + tokens) |

## Brand Rules

**Aesthetic**: Neo-Swiss Clean and Soft Explainer (Corporate Clean and Premium)

**Palette** (6 exclusive colors):
- **Navy** `#122562` — Surfaces, primary background
- **Gold** `#FFD700` — Accents, CTAs, focus, progress
- **Blue** `#137DC5` — Success, done, verified — **NUNCA verde**
- **Charcoal** `#1F2833` — Body background
- **Lavender** `#BBA0CC` — Secondary text, medium severity
- **Gray** `#808080` — Muted text, disabled states

**Typography**:
- **Poppins** — Titulares (headings, hero, section titles)
- **Trebuchet MS** — Cuerpo (body text, descriptions, cards)
- **Futura** — Notas, footnotes, popups, callouts
- **JetBrains Mono** — Código (code blocks, commands, monospace)

**Visual rules**:
- Swiss 8px grid · Navy-tinted soft shadows · Discrete micro-gradients
- Cards: glassmorphism `blur(16px) saturate(180%)` + `rgba(255,255,255,0.03)`
- Flat vector illustrations: faceless figures, soft geometric shapes, UI elements
- High legibility: large text, high contrast, never on noisy backgrounds
- Column composition (text + visual), generous white space

**Voice**: MetodologIA Brand Voice v3.0 (Minto-First OS)
- Structure: Minto (Conclusión → Soportes MECE → Evidencia → CTA)
- Language: Español latino neutro, tú por defecto
- Pillars: P1 (R)Evolución · P2 Intención antes que intensidad · P3 Tecnología como aliada
- Red list: hack, truco, secreto, resultados instantáneos, arquitecto, arquitectura, transformación
- Green list: método, diseñar, sistemas, gobernanza, capacidades, (R)Evolución, Success as a Service
- Rubric: 10 criteria × 0-2 scale = /20. Approval: 20/20 or correct and revalidate

> Canonical tokens: `references/design-tokens.json` (v2.0 — 6 palette colors, 4 fonts, aesthetic spec, voice config)
> Sequence diagrams: `references/sequence-diagrams.md` (7 Mermaid diagrams)

## Operational Vision

SDD is not just a specification framework — it's an **operational platform**. It can:
1. **Develop software**: Full pipeline from constitution to implementation
2. **Vitaminar el proceso**: Search for skills, create new ones, deploy them
3. **Execute tasks**: Via tool use and context-specific skill activation
4. **Self-monitor**: Ambient heartbeat detects drift and recommends actions
5. **Learn**: RAG memory captures session inputs for cross-session knowledge

---

## Upstream Sync

This plugin tracks `upstream/main` (IIC/kit). Only HTML/CSS branding diverges.
- Sync: `bash scripts/sync-upstream.sh`
- `.gitattributes` protects brand files during merges

---

# Intent Integrity Kit (Upstream Documentation)

**Closing the intent-to-code chasm**

## Overview

Intent Integrity Kit (IIKit) preserves your intent from idea to implementation through specification-driven development with cryptographic verification. Compatible with Claude Code, Codex, Gemini, and OpenCode.

## Skills Available

| Skill | Command | Description |
|-------|---------|-------------|
| Core | `/iikit-core` | Initialize project, check status, select feature, show help |
| Clarify | `/iikit-clarify` | Resolve ambiguities in any artifact |
| Bugfix | `/iikit-bugfix` | Report and fix bugs without full specification workflow |
| Constitution | `/iikit-00-constitution` | Create project governance principles |
| Specify | `/iikit-01-specify` | Create feature spec from description |
| Plan | `/iikit-02-plan` | Create technical implementation plan |
| Checklist | `/iikit-03-checklist` | Generate quality checklists |
| Testify | `/iikit-04-testify` | Generate test specs (TDD support) |
| Tasks | `/iikit-05-tasks` | Generate task breakdown |
| Analyze | `/iikit-06-analyze` | Validate cross-artifact consistency |
| Implement | `/iikit-07-implement` | Execute implementation |
| Tasks to Issues | `/iikit-08-taskstoissues` | Export tasks to GitHub Issues |

## Key Concepts

### Self-Validating Skills
Each skill checks its own prerequisites. Users invoke the skill they want, get feedback if prerequisites are missing.

### File-Based State
`.specify/context.json` persists state between skill invocations: current feature, available artifacts, clarification status, checklist completion.

### Multi-Feature Support
When multiple features exist in `specs/`, IIKit detects the active feature using: `.specify/active-feature` file → `SPECIFY_FEATURE` env var → Git branch → single feature auto-select.

### Cross-Agent Support
Skills stored in `.claude/skills/` with symlinks: `.codex/skills/`, `.gemini/skills/`, `.opencode/skills/`.

# Tessl Rules <!-- tessl-managed -->

@.tessl/RULES.md follow the [instructions](.tessl/RULES.md)
