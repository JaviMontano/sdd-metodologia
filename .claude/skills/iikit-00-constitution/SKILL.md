---
name: iikit-00-constitution
description: >-
  This skill should be used when the user asks to "define project governance",
  "create a constitution", "establish development principles", "set up project rules",
  or "configure phase 0 governance".
  It creates CONSTITUTION.md with governance principles, coding standards, and pipeline rules
  that all subsequent phases must respect.
  Use this skill whenever the user mentions governance, principles, or project setup rules,
  even if they don't explicitly ask for "constitution".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Constitution [EXPLICIT]

Create or update the project constitution at `CONSTITUTION.md` — the governing principles for specification-driven development.

## Scope

**MUST contain**: governance principles, non-negotiable development rules, quality standards, amendment procedures, compliance expectations, quality governance section referencing QA-PLAN.md.

**Quality Governance section** (MUST be included in every constitution):
```markdown
### Quality Governance
QA-PLAN.md is the authoritative quality artifact for this project. It aggregates:
- Global Definition of Done and acceptance criteria (derived from this constitution)
- Per-feature qa/ subdirectories (created emergently by /sdd:spec and /sdd:test)
- Quality gate status (updated by /sdd:analyze)
- Feature quality registry (AC coverage, test coverage, checklist completion)
Run /sdd:qa to generate or refresh. Auto-invoked by /sdd:analyze.
```

**MUST NOT contain**: technology stack, frameworks, databases, implementation details, specific tools or versions. These belong in `/iikit-02-plan`. See [phase-separation-rules.md](../iikit-core/references/phase-separation-rules.md).

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Prerequisites Check

1. **Check PREMISE.md exists**: `test -f PREMISE.md`. If missing: ERROR — "PREMISE.md not found. Run `/iikit-core init` first to create it." Do NOT proceed without PREMISE.md.
2. **Validate PREMISE.md**:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/validate-premise.sh --json
   ```
   If FAIL (missing sections or placeholders): ERROR — show details, suggest re-running init.
3. Check if constitution exists: `cat CONSTITUTION.md 2>/dev/null || echo "NO_CONSTITUTION"`
4. If missing, copy from [constitution-template.md](../iikit-core/templates/constitution-template.md)

## Execution Flow

1. **Load existing constitution** — identify placeholder tokens `[ALL_CAPS_IDENTIFIER]`. Adapt to user's needs (more or fewer principles than template).

2. **Collect values for placeholders**:
   - From user input, or infer from repo context
   - `RATIFICATION_DATE`: original adoption date
   - `LAST_AMENDED_DATE`: today if changes made
   - `CONSTITUTION_VERSION`: semver (MAJOR: principle removal/redefinition, MINOR: new principle, PATCH: clarifications)

3. **Draft content**: replace all placeholders, preserve heading hierarchy, ensure each principle has name + rules + rationale, governance section covers amendment/versioning/compliance.

4. **Consistency check**: validate against [plan-template.md](../iikit-core/templates/plan-template.md), [spec-template.md](../iikit-core/templates/spec-template.md), [tasks-template.md](../iikit-core/templates/tasks-template.md).

5. **Sync Impact Report** (HTML comment at top): version change, modified principles, added/removed sections, follow-up TODOs.

6. **Validate**: no remaining bracket tokens, version matches report, dates in ISO format, principles are declarative and testable. Constitution MUST have at least 3 principles — if fewer, add more based on the project context.

7. **Phase separation validation**: scan for technology-specific content per [phase-separation-rules.md](../iikit-core/references/phase-separation-rules.md). Auto-fix violations, re-validate until clean.

8. **Write** to `CONSTITUTION.md`

9. **Store TDD determination** in `.specify/context.json` so all skills read from here instead of re-parsing the constitution:
   ```bash
   TDD_DET=$(bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh get-tdd-determination "CONSTITUTION.md")
   ```
   Write to `.specify/context.json` using `jq` (merge, don't overwrite):
   ```bash
   jq --arg det "$TDD_DET" '. + {tdd_determination: $det}' .specify/context.json > .specify/context.json.tmp && mv .specify/context.json.tmp .specify/context.json
   ```
   If `.specify/context.json` doesn't exist, create it: `echo '{}' | jq --arg det "$TDD_DET" '{tdd_determination: $det}' > .specify/context.json`

10. **Git init** (if needed): `git init` to ensure project isolation

11. **Commit**: `git add CONSTITUTION.md .specify/context.json && git commit -m "Add project constitution"`

12. **Dashboard Refresh** (optional, never blocks):
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

13. **Report**: version, bump rationale, TDD determination, git status, suggested next steps

## Formatting

- Markdown headings per template, lines <100 chars, single blank line between sections, no trailing whitespace.

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 00 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 00 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

Format:
```
Constitution ready!
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

---

## Assumptions and Limits

| # | Assumption / Limit | Impact if Violated |
|---|---|---|
| 1 | PREMISE.md exists and has been validated before this skill runs | Skill halts with error; user must run `/iikit-core init` first |
| 2 | Constitution principles are declarative and testable (not vague aspirations) | Downstream phases cannot enforce governance; quality gates become meaningless |
| 3 | At least 3 principles are required for a valid constitution | Fewer than 3 triggers auto-generation of additional principles from project context |
| 4 | Constitution does NOT contain technology-specific content (frameworks, DBs) | Phase separation violation; auto-fix removes tech content and references plan instead |
| 5 | Amendment versioning follows semver (MAJOR/MINOR/PATCH) | Dashboard and traceability reports display incorrect version lineage |

## Edge Cases

| # | Edge Case | Expected Behavior |
|---|---|---|
| 1 | No PREMISE.md exists yet | ERROR with clear message: "Run `/iikit-core init` first" — skill does NOT proceed |
| 2 | Conflicting governance with existing constitution (re-run) | Semantic diff shown; breaking changes flagged; user confirms before overwrite |
| 3 | User wants to modify constitution after specs already exist | Sync Impact Report generated; downstream artifacts flagged for review |
| 4 | Empty or minimal user input (no arguments provided) | Skill infers principles from PREMISE.md and repo context; asks clarifying questions if ambiguous |
| 5 | Constitution principles conflict with each other (e.g., "no tests" + "TDD mandatory") | Validation step detects contradiction; halts with conflict report and asks user to resolve |

## Good vs Bad Example

**Good Example** -- structured constitution with numbered principles and clear enforcement:

```markdown
## Principle P-I: Test-Driven Development
**Rules**: All production code must have tests written BEFORE implementation.
Coverage threshold: 80% line coverage minimum.
**Rationale**: Ensures intent preservation from spec to code.
**Enforcement**: Gate G3 blocks implementation without passing tests.

## Principle P-II: Single Responsibility
**Rules**: Each module handles exactly one concern. Max 200 LOC per file.
**Rationale**: Reduces cognitive load and merge conflicts.
**Enforcement**: Code review checklist item; automated linter rule.
```

**Bad Example** -- vague principles with no enforcement mechanism:

```markdown
## Principles
- Be good
- Write clean code
- Test stuff
- Follow best practices
```

Why it fails: No principle IDs (P-I, P-II), no enforcement rules, no rationale, not testable or measurable, impossible for downstream gates to validate compliance.

## Validation Gate

Before marking this skill complete, verify ALL of the following:

- [ ] CONSTITUTION.md exists and contains at least 3 numbered principles (P-I, P-II, P-III)
- [ ] Each principle has: name, rules, rationale, and enforcement mechanism
- [ ] No remaining bracket tokens `[ALL_CAPS_IDENTIFIER]` in the output
- [ ] No technology-specific content (frameworks, databases, tools) — only governance
- [ ] Quality Governance section referencing QA-PLAN.md is present
- [ ] Version follows semver and matches Sync Impact Report
- [ ] Dates are in ISO 8601 format (YYYY-MM-DD)
- [ ] TDD determination stored in `.specify/context.json`
- [ ] Git commit created with constitution and context.json
