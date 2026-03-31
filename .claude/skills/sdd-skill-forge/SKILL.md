---
name: sdd-skill-forge
description: >-
  This skill should be used when the user asks to "create a new SDD skill",
  "scaffold a skill", "forge a skill", "build a new command", or mentions
  "skill creator". It manufactures production-grade SDD/IIKit skills with
  full scaffolding: SKILL.md, scripts, templates, references, hooks, evals,
  and knowledge graph registration. Use this skill whenever a new pipeline
  phase, utility command, or experience skill is needed — even if the user
  just says "I need a new /sdd command".
argument-hint: "<skill-description> [--tier utility|standard|orchestrator] [--phase 0-8|utility|experience] [--hooks] [--dry-run]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# SDD Skill Forge — MetodologIA Edition

> Manufacture production-grade SDD skills that pass the Gold Standard Anatomy,
> integrate with the SDD pipeline, and register in the knowledge graph.
> Every skill ships with scripts, hooks, templates, evals, and brand compliance. [EXPLICIT]

## When to Activate

| Trigger | Example |
|---------|---------|
| Create new skill | `/sdd:skill-forge "ambient code review with heartbeat integration"` |
| Scaffold from description | `/sdd:skill-forge "export specs to Notion" --tier standard` |
| Upgrade existing skill | `/sdd:skill-forge upgrade iikit-clarify` |
| Audit skill quality | `/sdd:skill-forge audit iikit-04-testify` |
| Dry run (plan only) | `/sdd:skill-forge "real-time drift detector" --dry-run` |

## User Input

```text
$ARGUMENTS
```

Parse arguments to determine mode: **create** (default), **upgrade**, **audit**, or **dry-run**.

## Before Forging

Load these references based on context — do not load all at once:

| File | Load When | Content |
|------|-----------|---------|
| [gold-standard-anatomy.md](references/gold-standard-anatomy.md) | Always on create/upgrade | The 10/10 skill specification: directory structure, frontmatter contract, body structure, MOAT requirements |
| [sdd-skill-taxonomy.md](references/sdd-skill-taxonomy.md) | Always on create | Skill classification: pipeline phases, utility commands, experience commands, intelligence commands |
| [hook-integration-guide.md](references/hook-integration-guide.md) | When `--hooks` flag or skill requires ambient behavior | Hook lifecycle, script patterns, sentinel integration |
| [brand-compliance.md](references/brand-compliance.md) | When skill generates visual output (dashboards, reports) | Neo-Swiss palette, typography, voice rules |
| [script-patterns.md](references/script-patterns.md) | When skill needs bash/powershell automation | Script conventions, common.sh integration, cross-platform patterns |

## Core Process

### Phase 0 — Intention Analysis

1. Parse `$ARGUMENTS` to extract:
   - **Description**: What the skill does (natural language)
   - **Tier**: utility (<150 lines), standard (150-400), orchestrator (400+) — infer if not specified [EXPLICIT]
   - **Phase**: Pipeline phase (0-8), utility, experience, or intelligence — infer from description [EXPLICIT]
   - **Hooks**: Whether the skill needs ambient hooks (heartbeat, post-tool, session) [INFERRED]

2. Check for conflicts with existing skills:
   ```bash
   ls .claude/skills/ | grep -i "<keyword>"
   grep -r "<core-concept>" .claude/skills/*/SKILL.md
   ```
   If overlap detected: warn user, suggest upgrade mode instead. [EXPLICIT]

3. Generate skill metadata:

   | Field | Derivation |
   |-------|-----------|
   | `name` | kebab-case from description, prefixed `sdd-` for SDD-specific or `iikit-` for pipeline phases |
   | `command` | `/sdd:<short-name>` or `/iikit-<phase>` |
   | `tier` | Complexity analysis of requirements |
   | `phase` | Pipeline position or category |

### Phase 1 — Architecture Design

Design the skill's file structure based on tier:

```
{skill-name}/
├── SKILL.md                    # Required — the skill definition
├── references/                 # Load-on-demand knowledge (if tier >= standard)
│   └── {domain-knowledge}.md   # Domain-specific protocols
├── scripts/
│   ├── bash/
│   │   ├── {skill-action}.sh   # Primary automation script
│   │   └── common-ext.sh       # Extensions to common.sh (if needed)
│   └── powershell/
│       └── {skill-action}.ps1  # Windows equivalent
├── templates/
│   └── {artifact}-template.md  # Output templates (if skill produces artifacts)
└── evals/
    └── evals.json              # Minimum 5 test prompts
```

For each directory, apply the warranted-when decision from Gold Standard:

| Directory | Create When | Skip When |
|-----------|------------|-----------|
| references/ | SKILL.md > 300 lines or domain knowledge needed 20% of time | Simple utility < 150 lines |
| scripts/ | Repeatable deterministic task (validation, generation, scanning) | All operations need LLM judgment |
| templates/ | Skill produces structured markdown artifacts | Output is conversational |
| evals/ | Always — no exceptions for SDD skills | Never skip |

### Phase 2 — SKILL.md Generation

Generate the SKILL.md following Template A structure exactly:

**Section 1 — Frontmatter:**
```yaml
---
name: {kebab-case-name}
description: >-
  This skill should be used when the user asks to "{trigger-1}",
  "{trigger-2}", "{trigger-3}", or mentions {keyword}.
  {One sentence: what it does.}
  Use this skill whenever {broader-context},
  even if they don't explicitly ask for "{skill-name}".
license: MIT
metadata:
  version: "1.0.0"
---
```

Frontmatter rules — every field must pass:

| Field | Rule | Failure = |
|-------|------|----------|
| name | kebab-case, 1-64 chars, no uppercase | Routing failure (BLOCKER) |
| description | Third person, 3-5 trigger phrases in quotes, pushy broader context | Under-triggering (BLOCKER) |
| version | Semantic versioning starting at 1.0.0 | Tracking failure |

**Section 2 — Title + Value Proposition:**
One heading + 1-2 sentence blockquote explaining WHY the skill exists. Include evidence tag. [EXPLICIT]

**Section 3 — When to Activate / Usage:**
Table with 2+ invocation examples. Include scaling guidance if complexity varies. [EXPLICIT]

**Section 4 — User Input:**
Always include the `$ARGUMENTS` block for argument parsing. [EXPLICIT]

**Section 5 — Before {Action} (Progressive Disclosure):**
Table mapping reference files to loading conditions. Only if references/ exists. [EXPLICIT]

**Section 6 — Core Process:**
The actual instructions. Apply these rules:
- Tables over bullet lists for structured data [EXPLICIT]
- Code blocks for templates and commands [EXPLICIT]
- One concern per subsection [EXPLICIT]
- Evidence tags on factual claims ([EXPLICIT], [INFERRED], [OPEN]) [EXPLICIT]

**Section 7 — Assumptions and Limits:**
3+ specific limits with handling strategies. Not vague "may have limitations". [EXPLICIT]

**Section 8 — Edge Cases:**
3+ non-obvious scenarios with: scenario, detection, handling. [EXPLICIT]

**Section 9 — Good vs Bad Example:**
Side-by-side comparison with reasoning. Calibrates the model. [EXPLICIT]

**Section 10 — Validation Gate:**
5+ testable checkboxes. Each criterion must be verifiable, not subjective. [EXPLICIT]

**Section 11 — Reference Files:**
Table of files with content summary and load-when condition. Only if references/ exists. [EXPLICIT]

### Phase 3 — Script Generation

For each script the skill needs, generate using SDD conventions:

```bash
#!/usr/bin/env bash
# sdd-{action}.sh — {one-line description}
# Part of SDD Skill Forge | MIT License
# Usage: bash scripts/sdd-{action}.sh [--json] [args...]
set -euo pipefail

# --- Constants ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/../.."

# --- Functions ---
output_json() { ... }
output_human() { ... }

# --- Main ---
main() {
    local json_mode=false
    [[ "${1:-}" == "--json" ]] && { json_mode=true; shift; }
    # ... implementation
    if $json_mode; then output_json; else output_human; fi
}
main "$@"
```

Script rules:
- Bash 3.2 compatible (macOS default) — no associative arrays [EXPLICIT]
- Dual output: `--json` for machine consumption, human-readable by default [EXPLICIT]
- Always `set -euo pipefail` [EXPLICIT]
- Cross-platform: generate PowerShell equivalent for Windows [INFERRED]
- Performance: hook scripts must complete < 100ms [EXPLICIT]

### Phase 4 — Template Generation

For skills that produce artifacts, create markdown templates with:
- Bracket placeholders: `[PLACEHOLDER]` for required fields [EXPLICIT]
- Evidence tags in the template structure [EXPLICIT]
- Traceability links to Constitution principles (P-I, P-II...) [INFERRED]
- SDD metadata header (feature, phase, date, author) [EXPLICIT]

### Phase 5 — Hook Integration

If the skill requires hooks (ambient behavior, post-write triggers, etc.):

1. Determine hook type:

   | Hook Point | Use When |
   |-----------|----------|
   | UserPromptSubmit | Skill needs per-prompt monitoring (heartbeat-style) |
   | PostToolUse | Skill reacts to file writes/edits (audit, validation) |
   | SessionStart | Skill needs context restoration |
   | PreCompact | Skill needs state snapshot before compression |

2. Generate hook script following heartbeat-lite pattern:
   - Always exit 0 (never block) [EXPLICIT]
   - Complete < 100ms for UserPromptSubmit [EXPLICIT]
   - Use grep over jq in hot paths [EXPLICIT]
   - Atomic writes via temp file + rename [EXPLICIT]

3. Generate hook configuration entry for `hooks/hooks.json`:
   ```json
   {
     "matcher": "{tool-pattern-if-PostToolUse}",
     "hooks": [{
       "type": "command",
       "command": "bash .claude/skills/{skill-name}/scripts/bash/{hook-script}.sh",
       "timeout": 5
     }]
   }
   ```

4. Output instructions for manual hook registration (hooks.json is not auto-modified). [EXPLICIT]

### Phase 6 — Evals Generation

Generate `evals/evals.json` with minimum 5 test prompts:

```json
{
  "skill_name": "{skill-name}",
  "description": "Eval suite for {skill-name}",
  "evals": [
    {
      "id": 1,
      "name": "happy-path-basic",
      "prompt": "{typical invocation}",
      "expected_output": "{what success looks like}",
      "expectations": ["{specific assertion 1}", "{specific assertion 2}"]
    },
    {
      "id": 2,
      "name": "edge-case-empty-input",
      "prompt": "/sdd:{command}",
      "expected_output": "Error message with usage example",
      "expectations": ["Shows usage hint", "Does not crash"]
    },
    {
      "id": 3,
      "name": "false-positive-unrelated",
      "prompt": "{input that should NOT trigger deep behavior}",
      "expected_output": "Minimal or redirected response",
      "expectations": ["Does not execute full pipeline"]
    }
  ]
}
```

Eval rules:
- Minimum 5 distinct evals [EXPLICIT]
- At least 1 false-positive test [EXPLICIT]
- At least 1 edge-case test [EXPLICIT]
- Named evals (descriptive kebab-case) [EXPLICIT]
- Discriminating assertions (fail if skill degrades) [EXPLICIT]

### Phase 7 — Knowledge Graph Registration

Register the new skill in the SDD knowledge graph:

1. Read `.specify/knowledge-graph.json` (if exists)
2. Add a new node:
   ```json
   {
     "id": "SK-{NNN}",
     "type": "Skill",
     "name": "{skill-name}",
     "phase": "{pipeline-phase}",
     "tier": "{complexity-tier}",
     "command": "/sdd:{command}"
   }
   ```
3. Add edges:
   - `governs`: from Constitution principles that apply
   - `depends_on`: prerequisite skills/artifacts
   - `produces`: artifacts the skill generates
   - `validates`: artifacts the skill checks
4. If knowledge graph doesn't exist, output the node/edge data for manual addition. [EXPLICIT]

### Phase 8 — Self-Validation (Quality Gate)

Run the full validation suite against the generated skill:

**Structural Checks (S1-S9):**
- [ ] S1: SKILL.md exists in top-level directory
- [ ] S2: Valid frontmatter (name kebab-case, description 3rd person with 3-5 triggers)
- [ ] S3: Under 500 lines (progressive disclosure enforced)
- [ ] S4: 1+ Good vs Bad example
- [ ] S5: Validation gate with 5+ testable criteria
- [ ] S6: Assumptions and Limits present (3+)
- [ ] S7: Edge Cases present (3+)
- [ ] S8: All referenced files exist (cross-reference integrity)
- [ ] S9: Evidence tags on 80%+ factual claims

**MOAT Checks (M1-M5):**
- [ ] M1: evals/evals.json with >= 5 distinct test prompts
- [ ] M2: >= 1 false-positive eval + >= 1 edge-case eval
- [ ] M3: All references/ files >= 20 lines
- [ ] M4: Template A structure (all 10 sections present or consciously omitted)
- [ ] M5: Evidence tags [EXPLICIT]/[INFERRED]/[OPEN] on >= 80% factual claims

**SDD-Specific Checks (D1-D5):**
- [ ] D1: Scripts are Bash 3.2 compatible (no associative arrays, no `mapfile`)
- [ ] D2: Scripts support `--json` output mode
- [ ] D3: Hook scripts exit 0 always and complete < 100ms (if applicable)
- [ ] D4: Templates use bracket placeholders and include evidence tags
- [ ] D5: Skill command registered or documented for registration

**Brand Checks (B1-B3) — only for skills with visual output:**
- [ ] B1: Uses Neo-Swiss palette exclusively (Navy #122562, Gold #FFD700, Blue #137DC5)
- [ ] B2: Typography follows Poppins/Trebuchet/Futura/JetBrains Mono hierarchy
- [ ] B3: No red-list terms (hack, truco, secreto, arquitectura, transformacion)

Score: All checks must pass. If any fail, fix before shipping. [EXPLICIT]

### Phase 9 — Delivery

1. Write all files to `.claude/skills/{skill-name}/`
2. Create symlinks for multi-agent compatibility:
   ```bash
   # Codex
   mkdir -p .codex/skills && ln -sf ../../.claude/skills/{skill-name} .codex/skills/{skill-name}
   # Gemini
   mkdir -p .gemini/skills && ln -sf ../../.claude/skills/{skill-name} .gemini/skills/{skill-name}
   ```
3. Output summary:
   - Skill name and command
   - Files created (tree view)
   - Hook registration instructions (if applicable)
   - Next steps: "Run `/sdd:{command} --help` to test"
4. Suggest git commit: `feat(skill): add {skill-name} — {one-line description}`

## Mode: Upgrade

When `$ARGUMENTS` starts with "upgrade":

1. Read the existing skill's SKILL.md
2. Run the full Phase 8 validation suite
3. Identify gaps (missing sections, structural violations, missing evals)
4. Generate a diff-based upgrade plan
5. Apply fixes while preserving existing logic
6. Re-validate and report score improvement

## Mode: Audit

When `$ARGUMENTS` starts with "audit":

1. Read the target skill
2. Run Phase 8 validation suite only (no modifications)
3. Output scorecard:
   ```
   Skill: {name} | Tier: {tier} | Phase: {phase}
   ─────────────────────────────────────────────
   Structural (S1-S9):  {pass}/{total}
   MOAT (M1-M5):        {pass}/{total}
   SDD (D1-D5):         {pass}/{total}
   Brand (B1-B3):       {pass}/{total} (if applicable)
   ─────────────────────────────────────────────
   Overall: {score}/22 ({percentage}%)
   ```
4. List specific failures with fix recommendations

## Assumptions and Limits

| Assumption | Impact if Wrong | Handling |
|-----------|----------------|----------|
| Bash 3.2 available on macOS | Scripts fail on older systems | Check `bash --version` in generated scripts; warn if < 3.2 |
| `.claude/skills/` directory exists | Cannot write skill files | Create directory if missing |
| Git repository initialized | Cannot create symlinks or commit | Warn and skip git operations |
| User has Claude Code with hooks support | Hook integration unavailable | Generate hook config but note it requires hooks-capable Claude Code |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|---------|
| Skill name conflicts with existing | `ls .claude/skills/` shows match | Warn user, suggest upgrade mode or alternate name |
| Description too vague ("make something cool") | < 10 words, no actionable verb | Request clarification with 3 example descriptions |
| Orchestrator tier with no sub-skills | Tier = orchestrator but no delegation targets | Downgrade to standard tier with warning |
| Hook script exceeds 100ms | Benchmark with `time bash script.sh` | Optimize: remove jq, use grep, reduce file I/O |
| Windows-only user | No bash available | Generate PowerShell-only scripts, skip bash |

## Good vs Bad Example

**Good — Skill with proper progressive disclosure:**
```yaml
---
name: sdd-drift-detector
description: >-
  This skill should be used when the user asks to "detect architectural drift",
  "check spec compliance", "verify implementation matches plan", or mentions
  "drift". It compares runtime behavior against declared specifications.
  Use this skill after implementation to catch divergence early.
---
```
Reasoning: Third person, 4 trigger phrases, broader context, actionable. [EXPLICIT]

**Bad — Skill with poor metadata:**
```yaml
---
name: DriftDetector
description: Detects drift in the codebase.
---
```
Reasoning: CamelCase name breaks routing. Description lacks triggers, is first person implicit, and too short for accurate activation. [EXPLICIT]

## Validation Gate

- [ ] Generated SKILL.md passes all S1-S9 structural checks
- [ ] Generated evals.json has >= 5 distinct tests with 1+ false-positive
- [ ] All referenced files in SKILL.md exist on disk
- [ ] Scripts are executable and pass `bash -n` syntax check
- [ ] Skill name is unique (no conflicts in `.claude/skills/`)
- [ ] Frontmatter description has 3-5 trigger phrases in quotes
- [ ] Evidence tags present on >= 80% of factual claims
- [ ] Templates use bracket placeholders (no hardcoded values)
- [ ] Hook configurations (if any) follow the sentinel pattern

## Reference Files

| File | Content | Load When |
|------|---------|-----------|
| [gold-standard-anatomy.md](references/gold-standard-anatomy.md) | Complete specification of a 10/10 skill | Create or upgrade mode |
| [sdd-skill-taxonomy.md](references/sdd-skill-taxonomy.md) | Classification of SDD skill types and phases | Create mode |
| [hook-integration-guide.md](references/hook-integration-guide.md) | Hook lifecycle, script patterns, performance requirements | Skill needs hooks |
| [brand-compliance.md](references/brand-compliance.md) | Neo-Swiss palette, typography, voice rules | Visual output skills |
| [script-patterns.md](references/script-patterns.md) | Bash/PowerShell conventions, common.sh patterns | Script generation |
