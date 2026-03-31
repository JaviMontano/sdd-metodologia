---
name: iikit-core
description: >-
  This skill should be used when the user asks to "initialize a new SDD project",
  "check project status", "switch active feature", or "see available commands".
  It bootstraps IIKit projects (git, hooks, PREMISE.md), reports pipeline progress,
  manages multi-feature selection, and displays the workflow reference.
  Use this skill whenever the user mentions project setup, feature switching,
  or pipeline navigation, even if they don't explicitly ask for "iikit-core".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Core

Core skill providing project initialization, status checking, and workflow help. [EXPLICIT]

## User Input

```text
$ARGUMENTS
```

Parse the user input to determine which subcommand to execute.

## Subcommands

1. **init** - Initialize intent-integrity-kit in a new or existing project
2. **status** - Show current project and feature status
3. **use** - Select the active feature for multi-feature projects
4. **help** - Display workflow phases and command reference

If no subcommand is provided, show help.

## Subcommand: init

Initialize intent-integrity-kit in the current directory. Handles the full project bootstrap: git init, optional GitHub repo creation, or cloning an existing repo. Optionally seeds the project backlog from an existing PRD/SDD document.

### Argument Parsing

The `$ARGUMENTS` after `init` may include an optional path or URL to a PRD/SDD document (e.g., `/iikit-core init ./docs/prd.md` or `/iikit-core init https://example.com/prd.md`). If present, store it as `prd_source` for use in Step 6.

### Execution Flow

> **Working directory**: All script paths below are relative to the project root. Before running any script, verify you are in the project root directory (`pwd` should show the directory containing `tessl.json` or `.tessl/`). If the script path doesn't resolve, find it: `find . -path "*/iikit-core/scripts/bash/git-setup.sh" 2>/dev/null || find ~/.tessl -path "*/iikit-core/scripts/bash/git-setup.sh" 2>/dev/null`

#### Step 0 — Detect environment

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/git-setup.sh --json
# Windows: pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/git-setup.ps1 -Json
```

JSON fields: `git_available`, `is_git_repo`, `has_remote`, `remote_url`, `is_github_remote`, `gh_available`, `gh_authenticated`, `has_iikit_artifacts`.

If `gh_available` is false, suggest: "GitHub CLI (`gh`) is not installed. Install it from https://cli.github.com/ for the best experience. Proceeding with `curl` fallback for GitHub operations."

#### Step 1 — Git/GitHub setup

**Auto-skip**: If `is_git_repo` + `has_remote`, skip to Step 2.

| Option | Requires | Action |
|--------|----------|--------|
| A) Init here | `git_available` | `git init`, then offer GitHub repo create (`gh` or API). Ask public/private. |
| B) Clone | `git_available` | Ask for URL/`owner/name`. `gh repo clone` or `git clone`. |
| C) Skip | — | Proceed without git. Warn: no assertion integrity hooks. |

Hide options whose prerequisites aren't met. If `git_available` is false, only C is available.

#### Step 2 — Check if already initialized

`test -f "CONSTITUTION.md"`

#### Step 3 — Create directory structure

`mkdir -p .specify specs`

#### Step 4 — Initialize hooks

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/init-project.sh --json
# Windows: pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/init-project.ps1 -Json
```

Installs pre-commit (assertion validation) and post-commit (hash storage) hooks.

If `git_user_configured` is `false`: ask the user for their name and email, then run:
```bash
git config user.name "<name>"
git config user.email "<email>"
```
Do NOT guess from hostname or system username.

#### Step 5 — Create PREMISE.md

If `PREMISE.md` does not exist, create it from the user's input using [premise-template.md](templates/premise-template.md). Extract from the user's init description:
- **What**: project description (from the user's input text)
- **Who**: target users (infer from context, or ask)
- **Why**: problem being solved (infer from context, or ask)
- **Domain**: business/technical domain
- **Scope**: system boundaries

Replace ALL bracket placeholders `[PLACEHOLDER]` with actual content. This is MANDATORY — init is not complete without PREMISE.md.

After writing PREMISE.md, validate:
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/validate-premise.sh --json "$PROJECT_PATH"
```
If validation fails (remaining placeholders or missing sections), fix and re-validate.

#### Step 6 — Report

Directories created, hook status, PREMISE.md status. Suggest `/iikit-00-constitution`.

#### Step 7 — Seed backlog from PRD (optional)

**Gate**: Requires `is_github_remote` AND user provided a PRD/SDD document. If not met, skip silently.

Follow the detailed procedure in [prd-seeding.md](references/prd-seeding.md): resolve input → read document → extract and order features → present for user confirmation → create GitHub issues.

### If Already Initialized

Show constitution status, feature count, and suggest `/iikit-core status`.

## Subcommand: status

### Execution Flow

1. Run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase status --json
   # Windows: pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase status -Json
   ```

2. **Present results** (all logic is in script output — just display):
   - Project name, `feature_stage`, artifact status (`artifacts` object), checklist progress (`checklist_checked`/`checklist_total`), `ready_for` phase, `next_step`
   - If `clear_before` is true, prepend `/clear` suggestion. If `next_step` is null, report feature as complete.

## Subcommand: use

Select the active feature when multiple features exist in `specs/`.

### User Input

The `$ARGUMENTS` after `use` is the feature selector: a number (`1`, `001`), partial name (`user-auth`), or full directory name (`001-user-auth`).

### Execution Flow

1. Run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selector>
   # Windows: pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selector>
   ```
   Parse JSON for `active_feature` and `stage`.

2. **Report** active feature, stage, and suggest next command: `specified` → `/iikit-clarify` or `/iikit-02-plan` | `planned` → `/iikit-03-checklist` or `/iikit-05-tasks` | `testified` → `/iikit-05-tasks` | `tasks-ready` → `/iikit-07-implement` | `implementing-NN%` → `/iikit-07-implement` (resume) | `complete` → done. Suggest `/clear` before next skill when appropriate.

If no selector, no match, or ambiguous match: show available features with stages and ask user to pick.

## Subcommand: help (also default when no subcommand)

Display the workflow reference from [help-reference.md](references/help-reference.md) verbatim.

## Resources

- [spec-template.md](templates/spec-template.md), [plan-template.md](templates/plan-template.md), [agent-file-template.md](templates/agent-file-template.md) — feature scaffolding
- [prd-issue-template.md](templates/prd-issue-template.md) — PRD backlog seeding
- [help-reference.md](references/help-reference.md) — workflow command reference

## Error Handling

Unknown subcommand → show help. Not in a project → suggest `init`. Git unavailable → warn but continue. [EXPLICIT]

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Git 2.0+ is available on the system | If missing, skip git operations and warn user. Option C (skip git) is always available. [EXPLICIT] |
| 2 | Bash 3.2+ (macOS default) or PowerShell 5.1+ (Windows) | Scripts use no Bash 4+ features (no associative arrays, no mapfile). PowerShell equivalents provided. [EXPLICIT] |
| 3 | GitHub CLI (`gh`) is optional but recommended | Falls back to `curl` for GitHub API operations when `gh` is not installed. [EXPLICIT] |
| 4 | Only one feature can be active at a time | `.specify/active-feature` stores a single feature slug. Multi-feature parallel work requires manual switching. [INFERRED] |
| 5 | PREMISE.md must have zero bracket placeholders before init is considered complete | Validation script rejects `[PLACEHOLDER]` patterns. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Already-initialized project | `test -f "CONSTITUTION.md"` returns true in Step 2 | Skip directory creation, show status summary, suggest `/iikit-core status` instead. [EXPLICIT] |
| No features exist in `specs/` | `set-active-feature.sh` returns empty feature list | Show message: "No features found. Run `/iikit-01-specify` to create your first feature." [EXPLICIT] |
| Ambiguous feature selector | Partial name matches multiple features (e.g., "auth" matches "user-auth" and "api-auth") | List all matches with indices and ask user to be more specific. Never auto-select. [EXPLICIT] |
| PRD document is a URL but network is unavailable | `curl`/`wget` fails during Step 7 | Log warning, skip PRD seeding, suggest user retry with a local file copy. [INFERRED] |
| Git user not configured | `git_user_configured` is false in init-project.sh output | Ask user explicitly for name and email. Never guess from hostname or system username. [EXPLICIT] |

## Good vs Bad Example

**Good**: User runs `/iikit-core init` in an empty directory
```
✓ Git initialized
✓ Directory structure created (.specify/, specs/)
✓ Pre-commit and post-commit hooks installed
✓ PREMISE.md created with actual project description
→ Next: /iikit-00-constitution
```

**Bad**: User runs `/iikit-core init` and skill leaves bracket placeholders
```
✗ PREMISE.md contains [PLACEHOLDER] — not validated
✗ Hooks installed but no git repo exists
✗ No next step suggested
```

**Why**: Init must produce a fully-resolved PREMISE.md with zero placeholders. Hooks require a git repo. Always suggest the next pipeline step. [EXPLICIT]

## Validation Gate

Before marking init as complete, verify: [EXPLICIT]

- [ ] V1: `.specify/` directory exists
- [ ] V2: `specs/` directory exists
- [ ] V3: PREMISE.md exists and contains zero `[PLACEHOLDER]` patterns
- [ ] V4: Git hooks installed (or git explicitly skipped with user acknowledgment)
- [ ] V5: `check-prerequisites.sh --phase status --json` returns valid JSON
- [ ] V6: Next step recommendation displayed to user
- [ ] V7: If PRD provided, backlog seeding completed or explicitly skipped
