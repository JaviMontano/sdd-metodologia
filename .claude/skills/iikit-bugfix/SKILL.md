---
name: iikit-bugfix
description: >-
  This skill should be used when the user asks to "fix a bug", "report a bug",
  "debug an issue", "create a bugfix", or "handle a defect". It creates a structured
  bugs.md record, generates fix tasks in tasks.md, and optionally imports from or
  creates GitHub issues. Use this skill whenever the user mentions bugs, defects,
  errors, or quick fixes that don't require a full SDD feature specification cycle.
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Bugfix [EXPLICIT]

Report a bug against an existing feature, create a structured `bugs.md` record, and generate fix tasks in `tasks.md`.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (soft mode — warn if missing, proceed without).

## Execution Flow

The text after `/iikit-bugfix` is either a `#number` (GitHub issue) or a text bug description.

### 1. Parse Input

Determine the input type:

- **`#number` pattern** (e.g., `#42`): GitHub inbound flow (Step 2a)
- **Text description**: Text description flow (Step 2b)
- **Empty**: ERROR with usage example: `/iikit-bugfix 'Login fails when email contains plus sign'` or `/iikit-bugfix #42`

If input contains BOTH `#number` and text, prioritize the `#number` and warn that text is ignored.

### 2a. GitHub Inbound Flow

1. Fetch issue: use `gh issue view <number> --json title,body,labels` if available, otherwise `curl` the GitHub API (`GET /repos/{owner}/{repo}/issues/{number}`)
2. If fetch fails (issue not found, auth error, no GitHub remote): ERROR with clear message and suggest using text description instead.
4. If fetch fails (issue not found, auth error): ERROR with clear message and remediation.
5. Map fields:
   - `title` → bug description
   - `body` → reproduction steps
   - `labels` → severity mapping: labels containing "critical" → critical, "high"/"priority" → high, "bug" → medium (default), otherwise → medium
6. Store issue number for GitHub Issue field in bugs.md
7. Continue to Step 3

### 2b. Text Description Flow

1. Store the text as the bug description
2. Continue to Step 3

### 3. Select Target Feature

Run feature listing:

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/bugfix-helpers.sh --list-features
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/bugfix-helpers.ps1 --list-features
```

Parse the JSON array. If empty: ERROR with "No features found. Run `/iikit-01-specify` first to create a feature."

Present a numbered table of features:

| # | Feature | Stage |
|---|---------|-------|
| 1 | 001-user-auth | implementing-50% |
| 2 | 002-api-gateway | specified |

Prompt user to select a feature by number.

### 4. Validate Feature

After selection, validate:

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/bugfix-helpers.sh --validate-feature "<feature_dir>"
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/bugfix-helpers.ps1 --validate-feature "<feature_dir>"
```

If invalid: ERROR with the message from the JSON response.

### 5. Gather Bug Details

**For text input (2b):**
- Prompt user for **severity**: present options (critical, high, medium, low) with descriptions
- Prompt user for **reproduction steps**: numbered list of steps to reproduce

**For GitHub inbound (2a):**
- Severity is pre-filled from labels (confirm with user if mapping is ambiguous)
- Reproduction steps are pre-filled from issue body (confirm with user)

### 6. Generate Bug ID

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/bugfix-helpers.sh --next-bug-id "<feature_dir>"
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/bugfix-helpers.ps1 --next-bug-id "<feature_dir>"
```

### 7. Write bugs.md

Create or append to `<feature_dir>/bugs.md` using the template at [bugs-template.md](references/bugs-template.md).

Fill in:
- **BUG-ID**: from Step 6
- **Reported**: today's date (YYYY-MM-DD)
- **Severity**: from Step 5
- **Status**: `reported`
- **GitHub Issue**: `#number` if from GitHub inbound, `_(none)_` otherwise
- **Description**: bug description
- **Reproduction Steps**: from Step 5
- **Root Cause**: `_(empty until investigation)_`
- **Fix Reference**: `_(empty until implementation)_`

If `bugs.md` already exists, append with `---` separator before the new entry. Do NOT modify existing entries.

If `bugs.md` does not exist, create it with the header `# Bug Reports: <feature-name>` followed by the entry.

### 8. Outbound GitHub Issue (Text Input Only)

For text-input bugs only (NOT for GitHub inbound — issue already exists):

1. Create issue: use `gh issue create --title "<description>" --body "<bugs.md entry content>" --label "bug"` if `gh` available, otherwise `curl` the GitHub API (`POST /repos/{owner}/{repo}/issues`)
2. Store returned issue number in the bugs.md GitHub Issue field
3. If no GitHub remote configured: warn that GitHub issue creation was skipped, proceed with local workflow

### 9. Assess TDD Requirements

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh assess-tdd "CONSTITUTION.md"
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/testify-tdd.ps1 assess-tdd "CONSTITUTION.md"
```

Parse JSON response for `determination` field.

### 10. BDD/TDD Flow (If Mandatory)

If TDD is mandatory (`determination` = `mandatory`):

1. Create `<feature_dir>/tests/features/` if it doesn't exist
2. Create `<feature_dir>/tests/features/bugfix_<BUG-NNN>.feature`:
   ```gherkin
   @BUG-NNN
   Feature: Bug fix for BUG-NNN — <description>
     Scenario: <description>
       Given <conditions that trigger the bug>
       When <action that causes incorrect behavior>
       Then <expected correct behavior>
   ```
3. Re-hash the features directory:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh rehash "<feature_dir>/tests/features"
   ```
4. **Verify hash was stored** — if result is NOT `valid`, STOP and report error:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh verify-hash "<feature_dir>/tests/features"
   ```
5. Continue to Step 11 with TDD task variant

### 11. Generate Bug Fix Tasks

**Bug fix tasks use the `T-B` prefix** (e.g., T-B001, T-B002) to distinguish them from regular tasks (T001, T002). This is mandatory — the dashboard and parsers rely on the `T-B` prefix to identify bug fix tasks and calculate implementation progress correctly.

Get next task IDs:

**Unix/macOS/Linux:**
```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/bugfix-helpers.sh --next-task-ids "<feature_dir>" <count>
```
**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/bugfix-helpers.ps1 --next-task-ids "<feature_dir>" <count>
```

**Non-TDD task set** (count = 3):
```markdown
## Bug Fix Tasks

- [ ] T-BNNN [BUG-NNN] Investigate root cause for BUG-NNN: <description>
- [ ] T-BNNN+1 [BUG-NNN] Implement fix for BUG-NNN: <description>
- [ ] T-BNNN+2 [BUG-NNN] Write regression test for BUG-NNN: <description>
```

**TDD task set** (count = 2):
```markdown
## Bug Fix Tasks

- [ ] T-BNNN [BUG-NNN] Implement fix for BUG-NNN referencing test spec TS-NNN: <description>
- [ ] T-BNNN+1 [BUG-NNN] Verify fix passes test TS-NNN for BUG-NNN: <description>
```

If GitHub issue is linked, include reference in task descriptions (e.g., `(GitHub #42)`).

Append to existing `<feature_dir>/tasks.md`. If tasks.md does not exist, create it with:
```markdown
# Tasks: <feature-name>

## Bug Fix Tasks

[tasks here]
```

Do NOT modify existing entries or task IDs in tasks.md.

### 12. Commit

```bash
git add specs/*/bugs.md specs/*/tasks.md specs/*/tests/features/
git commit -m "bugfix: <BUG-ID> <short-description>"
```

### 13. Dashboard Refresh (optional, never blocks)

Regenerate the dashboard so the pipeline reflects the new bug and tasks:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

### 13. Report

Output a summary:

```
Bug reported successfully!

  Bug ID:      BUG-NNN
  Feature:     <feature-name>
  Severity:    <severity>
  GitHub Issue: #number (or N/A)
  Tasks:       T-BNNN through T-BNNN+N

Files modified:
  - <feature_dir>/bugs.md (created/appended)
  - <feature_dir>/tasks.md (appended)
  - <feature_dir>/tests/features/bugfix_BUG-NNN.feature (created, TDD only)

Next step:
  Run: bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase bugfix --json
  Parse `next_step` (will be /iikit-07-implement) and `model_tier`.
  Include `model_tier` for next_step and any alt_steps so user knows best model per option.
  - <next_step> — runs in bugfix mode (relaxed gates: no checklist or plan required, traces to bugs.md instead of spec)
  
  - Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

## Error Handling

| Condition | Response |
|-----------|----------|
| Empty input | ERROR with usage example |
| No features found | ERROR: "Run `/iikit-01-specify` first" |
| Feature validation failed | ERROR with specific message |
| GitHub API unreachable | Fall back: `gh` → `curl` GitHub API → skip with WARN |
| GitHub issue not found | ERROR with "verify issue number" |
| TDD required, no test artifacts | ERROR: "Run `/iikit-04-testify` first" |
| Existing bugs.md | Append without modifying existing entries |
| Existing tasks.md | Append without modifying existing entries |

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Bug is in an existing feature's codebase | If no feature exists, suggest `/iikit-01-specify` first. [EXPLICIT] |
| 2 | Doesn't require full specification cycle | Bugfix is a lightweight path: report → tasks → fix. [EXPLICIT] |
| 3 | May generate tasks without full pipeline validation | Fix tasks skip G1/G2 gates; still validated at G3 during implementation. [EXPLICIT] |
| 4 | Git available for branch creation | If git unavailable, skip branch operations with warning. [EXPLICIT] |
| 5 | Bug report follows structured format (severity, repro steps, expected/actual) | Template enforces structure; missing fields are prompted. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Bug is actually a feature request | User describes new functionality, not a defect | Detect enhancement language, suggest `/iikit-01-specify` instead. [EXPLICIT] |
| Bug affects multiple features | User references components in different features | Create bug record in the most affected feature, cross-reference others. [INFERRED] |
| No reproduction steps provided | User gives only "it's broken" | Prompt for: steps to reproduce, expected behavior, actual behavior, environment. [EXPLICIT] |
| Bug in constitution/governance artifacts | Defect in CONSTITUTION.md or governance rules | Route to `/iikit-00-constitution` for governance corrections. [EXPLICIT] |
| Critical production bug requiring immediate fix | User marks as critical/P0 | Skip non-essential steps, generate minimal fix task, suggest hotfix branch. [EXPLICIT] |

## Good vs Bad Example

**Good**: User runs `/iikit-bugfix` and gets structured report
```
Bug Report: BUG-003 — Login fails with special characters in password
  Severity: High | Feature: 001-user-auth
  Repro: 1) Enter password with '&' 2) Click login 3) 500 error
  Expected: Login succeeds | Actual: Server error 500
  Root cause: Unescaped SQL parameter in auth query

Fix Tasks:
  T-FIX-001: Parameterize SQL query in auth.service.ts
  T-FIX-002: Add input sanitization test for special characters
  T-FIX-003: Regression test for BUG-003

→ bugs.md updated | tasks.md updated | Branch: fix/bug-003
```

**Bad**: Bug report without structure
```
✗ "Fixed the login bug" — no reproduction steps
✗ No root cause analysis
✗ No regression test task generated
✗ No bugs.md record created
```

**Why**: Bugfix must create a structured record with repro steps, generate fix tasks with regression tests, and update bugs.md for traceability. [EXPLICIT]

## Validation Gate

Before marking bugfix as complete, verify: [EXPLICIT]

- [ ] V1: Bug report created in bugs.md with structured fields
- [ ] V2: Reproduction steps documented
- [ ] V3: Root cause identified (or marked as [OPEN] for investigation)
- [ ] V4: Fix tasks generated in tasks.md
- [ ] V5: Regression test task included
- [ ] V6: Affected artifacts identified (which FRs, SCs impacted)
- [ ] V7: No side effects introduced to existing functionality
