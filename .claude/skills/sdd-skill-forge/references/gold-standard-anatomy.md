# Gold Standard Skill Anatomy — SDD Edition

What a 10/10 SDD skill looks like. Based on the Anthropic skill-creator plugin, the creator-moat-skill quality framework, and SDD pipeline conventions. [EXPLICIT]

## Directory Structure

```
skill-name/
├── SKILL.md              (required — under 500 lines)
├── references/            (deep supporting content loaded on demand)
├── scripts/
│   ├── bash/             (Unix/macOS/Linux — Bash 3.2 compatible)
│   └── powershell/       (Windows equivalents)
├── templates/            (markdown templates for artifacts)
├── evals/
│   └── evals.json        (test prompts + expectations + assertions)
└── assets/               (static files, viewers, HTML templates)
```

## Frontmatter Contract

```yaml
---
name: "{kebab-case, max 64 chars}"
description: >-
  This skill should be used when the user asks to "{trigger-1}",
  "{trigger-2}", "{trigger-3}", or mentions {keyword}.
  {What it does — one sentence.}
  Use this skill whenever {broader-context},
  even if they don't explicitly ask for "{name}".
license: MIT
metadata:
  version: "1.0.0"
---
```

| Field | Rule | Severity |
|-------|------|----------|
| name | kebab-case, 1-64 chars, no uppercase | BLOCKER |
| description | 3rd person, 3-5 triggers in quotes, pushy context, <= 1024 chars | BLOCKER |
| version | Semantic versioning | WARNING |

## Body Structure (Template A — required)

1. Title + Value Proposition (1-2 sentences with evidence tag)
2. When to Activate / Usage (2+ invocation examples)
3. User Input (`$ARGUMENTS` block)
4. Before {Action} (progressive disclosure table — if references/ exists)
5. Core Process (tables > bullets, code blocks for templates, one concern per section)
6. Assumptions and Limits (3+ specific with handling)
7. Edge Cases (3+ with scenario/detection/handling)
8. Good vs Bad Example (1+ side-by-side with reasoning)
9. Validation Gate (5+ testable checkboxes)
10. Reference Files table (if references/ exists)

## SDD-Specific Requirements

| Requirement | Standard | SDD Addition |
|-------------|----------|-------------|
| Scripts | chmod +x, dual output | Bash 3.2, --json mode, < 100ms for hooks |
| Templates | Bracket placeholders | Evidence tags + traceability links (P-I, FR-NNN) |
| Hooks | N/A | Sentinel pattern: exit 0 always, grep over jq |
| Brand | N/A | Neo-Swiss palette, Poppins/Trebuchet typography |
| Knowledge Graph | N/A | Register nodes and edges in EKG |

## MOAT Formula

```
MOAT = S1-S9 structural checks pass
     + M1: evals.json >= 5 distinct tests
     + M2: >= 1 false-positive + >= 1 edge-case eval
     + M3: references/ files >= 20 lines each
     + M4: Template A structure
     + M5: Evidence tags on >= 80% factual claims
     + D1-D5: SDD-specific checks
```

## Complexity Tiers

| Tier | Lines | Required | Recommended |
|------|-------|----------|-------------|
| Utility | < 150 | SKILL.md + evals/ | references/ |
| Standard | 150-400 | SKILL.md + evals/ + references/ | scripts/, templates/ |
| Orchestrator | 400+ | SKILL.md + evals/ + references/ + scripts/ | agents/, templates/ |

## Evidence Tags

- `[EXPLICIT]` — Direct fact or specification
- `[INFERRED]` — Derived conclusion from evidence
- `[OPEN]` — Unknown, to be determined

Coverage target: >= 80% for Standard/Orchestrator, >= 50% for Utility.

## Writing Style

| Rule | Correct | Incorrect |
|------|---------|-----------|
| Imperative form | "Read the file" | "You should read the file" |
| Third person description | "This skill should be used when..." | "I analyze inputs when..." |
| Explain WHY | "Keep under 500 lines because progressive disclosure reduces cognitive load" | "MUST be under 500 lines" |
| Tables for structured data | Table of gap types | Bullet list of gap types |
| No CAPS emphasis | "preserve intent" | "ALWAYS preserve intent" |
