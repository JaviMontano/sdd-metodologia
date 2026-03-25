# SDD — Enhanced Fork of Intent Integrity Kit

## Upstream Relationship

| Property | Value |
|----------|-------|
| **Upstream** | [intent-integrity-chain/kit](https://github.com/intent-integrity-chain/kit) (MIT) |
| **Version tracked** | v2.7.16 (12 skills, 0 scripts, 0 dashboard pages) |
| **Fork** | [JaviMontano/sdd-metodologia](https://github.com/JaviMontano/sdd-metodologia) (GPL-3.0 brand layer) |
| **Sync** | `/sdd:sync` → fetch upstream → merge → brand overlay → verify → commit |
| **Protection** | `.gitattributes` with `merge=ours` for 14 brand-critical paths |

**Decision**: Major version bump (v2.x → v3.x) because the fork adds a complete ALM layer, ambient intelligence, and workspace sessions that fundamentally change the developer experience. Upstream features merge cleanly; SDD features are strictly additive.

## What SDD Adds (Quantified)

### Ambient Intelligence — zero-cost runtime awareness
| Feature | Upstream | SDD | Mechanism |
|---------|----------|-----|-----------|
| Health monitoring | None | Per-prompt heartbeat | `sdd-heartbeat-lite.sh` < 17ms, zero LLM tokens |
| Stale artifact detection | None | 7-day threshold scan | `find` with `-mtime`, no external deps |
| Workspace nudge | None | Suggests workspace if SDD project lacks one | `active-workspace` file check |
| Sentinel cycle | None | Perceive-decide-act with 30-min suppression | `sdd-sentinel.sh` |

**Limit**: Heartbeat relies on `date` and `find` — works on macOS/Linux Bash 3.2+, no Windows native support (use WSL).

### ALM Dashboard — 10-page visual lifecycle manager
Upstream provides zero visualization. SDD generates a multi-page HTML micro-frontend:
- **Command Center** (health gauge, nav, activity feed), **Pipeline** (kanban + phase dots)
- **Specs** (story map + checklist), **Quality** (Sankey + analyze + bugs)
- **Intelligence** (sparklines + force-directed graph), **Workspace** (sessions + file tree + RAG)
- **Governance** (constitution + principles radar), **Logs** (4-source timeline)
- **Backlog** (3-column board), **Search** (cross-artifact filter)

**Trade-off**: Dashboard is static HTML generated on-demand (not a live server). Stale data requires re-running `/sdd:dashboard`. This keeps zero runtime dependencies.

### Knowledge & Memory
| System | What it does | Key file |
|--------|-------------|----------|
| **RAG memory** | Auto-captures session inputs with MIME detection, LLM-ready abstracts | `sdd-rag-capture.sh` |
| **Knowledge graph** | Constitution → FR → TS → Tasks traceability, orphan detection | `sdd-knowledge-graph.js` → `.specify/knowledge-graph.json` |
| **QA Plan** | DoD, acceptance criteria, gate status per feature | `sdd-qa-plan.js` → `QA-PLAN.md` |
| **Health scoring** | Time-series history with trend analysis and critical threshold (< 40) | `sdd-insights.js` → `.specify/health-history.json` |

### Per-Task Workspace Sessions
Isolates each interaction/task into `workspace/yyyy-mm-dd-slug/` with inputs, RAG, logs, tasklog. Active workspace routes RAG capture and session logs automatically. Dashboard shows session cards.

**Assumption**: Users work on one task at a time (single active workspace). For parallel tasks, switch between sessions explicitly.

### Orchestration Scale

| Metric | Upstream (IIC/kit) | SDD (MetodologIA) | Delta |
|--------|-------------------|-------------------|-------|
| Skills | 12 | 12 (preserved) | 0 |
| Commands | 12 (via skills) | 39 (commands + aliases) | +27 |
| Scripts | 0 | 23 (bash + node) | +23 |
| Dashboard pages | 0 | 10 | +10 |
| Active hooks | 0 | 4 | +4 |
| Tessl steering rules | 0 | 5 | +5 |
| Design tokens | 0 | 33 colors + 4 fonts | +37 |

### Neo-Swiss Branding
- **Body**: `#020617` (ultra-dark). **Surfaces**: `#122562` (navy). **Accents**: `#FFD700` (gold).
- **Success/done**: `#137DC5` (blue) — **never green** (brand rule).
- **Fonts**: Poppins (headings), Montserrat (body), JetBrains Mono (code).
- **Cards**: Glassmorphism `blur(16px) saturate(180%)` + `rgba(255,255,255,0.03)`.
- **Grid**: Swiss 8px. **Shadows**: Navy-tinted `rgba(18,37,98,...)`.

## Fork Sustainability

| Concern | Mitigation |
|---------|------------|
| Upstream breaking changes | `.gitattributes` `merge=ours` on 14 brand paths |
| Brand drift after merge | `brand-overlay.sh` auto-reapplies tokens post-merge |
| Undetected regressions | `verify-brand.sh` checks 6 required tokens + prohibited green |
| Sync complexity | `sync-upstream.sh` automates full cycle in one command |

## Known Limits

1. **No Windows native** — All scripts require Bash 3.2+ (macOS/Linux or WSL)
2. **Static dashboard** — Requires manual regeneration (`/sdd:dashboard`); no live update
3. **Single active workspace** — No concurrent task isolation
4. **Python3 dependency** — `session-log.sh` and `sdd-workspace.sh` use python3 for safe JSON edits
5. **Slug collisions** — Same task name on same day reuses session (by design, not a bug)
6. **No workspace nesting** — Flat `workspace/` directory only
