---
name: iikit-08-taskstoissues
description: >-
  This skill should be used when the user asks to "export tasks to GitHub Issues",
  "create issues from tasks", "ship tasks to GitHub", "publish task breakdown",
  or "set up project board from tasks". It converts SDD task breakdowns into
  tracked GitHub Issues with labels, milestones, and dependency references.
  Use this skill whenever the user mentions issue creation, task export,
  GitHub integration, or shipping work items from the SDD pipeline.
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Tasks to Issues [EXPLICIT]

Convert existing tasks into dependency-ordered GitHub issues for project tracking.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Prerequisites Check

1. Run prerequisites check:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase 08 --json
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase 08 -Json`

2. Parse JSON for `FEATURE_DIR` and `AVAILABLE_DOCS`. Extract path to **tasks.md**.
3. If JSON contains `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.

## GitHub Remote Validation

```bash
git config --get remote.origin.url
```

**CRITICAL**: Only proceed if remote is a GitHub URL (`git@github.com:` or `https://github.com/`). Otherwise ERROR.

## Execution Flow

### 1. Parse tasks.md

Extract: Task IDs, descriptions, phase groupings, parallel markers [P], user story labels [USn], dependencies.

### 2. Create GitHub Issues

**Title format**: `[FeatureID/TaskID] [Story] Description` — feature-id extracted from `FEATURE_DIR` (e.g. `001-user-auth`).

**Body**: use template from [issue-body-template.md](references/issue-body-template.md). **Labels** (create if needed): `iikit`, `phase-N`, `us-N`, `parallel`.

### 3. Create Issues (parallel)

Use the `Task` tool to dispatch issue creation in parallel — one subagent per chunk of tasks (split by phase or user story). Each subagent receives:
- The chunk of tasks to create issues for
- The feature-id, repo owner/name, and label set
- Instructions to use `gh issue create` if available, otherwise `curl` the GitHub API

```bash
# Preferred:
gh issue create --title "[001-user-auth/T012] [US1] Create User model" --body "..." --label "iikit,phase-3,us-1"
```

**CRITICAL**: Never create issues in repositories that don't match the remote URL. Verify before dispatching.

Collect all created issue numbers from subagents. Verify all returned successfully before proceeding. If some failed: report failures, continue with successful issues only.

### 4. Link Dependencies

After all issues exist, edit bodies to add cross-references using `#NNN` syntax. Skip dependency links for any issues that failed to create.

## Report

Output: issues created (count + numbers), failures (count + details), link to repo issues list.

## Error Handling

| Condition | Response |
|-----------|----------|
| Not a GitHub remote | STOP with error |
| Issue creation fails | Report, continue with remaining issues |
| Partial failure | Link dependencies for successful issues only |

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 08 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 08 -Json`

Parse the JSON and present:
1. `next_step` will be null (workflow complete)
2. If `alt_steps` non-empty: list as alternatives
3. Append dashboard link

If on a feature branch, offer to merge:
- **A) Merge locally**: `git checkout main && git merge <branch>`
- **B) Create PR**: `gh pr create`
- **C) Skip**: user will handle it

Format:
```
Issues exported! Review in GitHub, assign team members, add to project boards.
- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | GitHub remote configured (`git@github.com:` or `https://github.com/`) | If not a GitHub remote, STOP with error. Non-GitHub remotes are not supported. [EXPLICIT] |
| 2 | `gh` CLI available or `curl` + GitHub token for API access | Prefer `gh issue create`; fall back to `curl` with GitHub API. Warn if neither available. [EXPLICIT] |
| 3 | tasks.md exists with T-NNN formatted task IDs | If tasks.md missing, suggest `/iikit-05-tasks` first. Non-standard IDs may be skipped. [EXPLICIT] |
| 4 | Labels may not exist in the GitHub repository | Create labels (`iikit`, `phase-N`, `us-N`, `parallel`) if they don't exist. [EXPLICIT] |
| 5 | GitHub API rate limits may throttle bulk issue creation | Batch issues in parallel chunks but respect rate limits. Report partial failures. [INFERRED] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No GitHub remote configured | `git config --get remote.origin.url` returns empty or non-GitHub URL | STOP with error message, suggest configuring remote first. [EXPLICIT] |
| Tasks already exported (duplicate issues) | Issue titles already exist in the repository | Warn user about potential duplicates, offer to skip existing or create new. Never auto-create duplicates. [EXPLICIT] |
| Partial failure during bulk creation | Some `gh issue create` calls fail (network, permissions) | Report successful and failed issues separately. Link dependencies only for successful ones. [EXPLICIT] |
| Empty task list | tasks.md exists but contains no T-NNN entries | Report "no tasks found", suggest `/iikit-05-tasks` to generate tasks. [EXPLICIT] |
| Very large task list (50+ tasks) | Task count exceeds typical project size | Chunk into parallel batches (5-10 per batch), show progress indicator. [INFERRED] |

## Good vs Bad Example

**Good**: User runs `/iikit-08-taskstoissues` and gets tracked issues
```
✓ Parsed 12 tasks from tasks.md (3 phases, 2 user stories)
✓ Created 12 GitHub Issues (#45-#56)
✓ Labels applied: iikit, phase-3, phase-4, us-1, us-2
✓ Dependencies linked via #NNN cross-references
→ View: https://github.com/owner/repo/issues
→ Workflow complete — assign team members and add to project boards
```

**Bad**: Issues created without structure
```
✗ 12 issues created with no labels
✗ No dependency cross-references
✗ No link to repository issues page
✗ Duplicate issues created for already-exported tasks
```

**Why**: Issue export must apply labels, link dependencies, prevent duplicates, and provide a direct link to the repository issues page. [EXPLICIT]

## Validation Gate

Before marking issue export as complete, verify: [EXPLICIT]

- [ ] V1: tasks.md exists and contains T-NNN formatted tasks
- [ ] V2: GitHub remote is configured and accessible
- [ ] V3: All issues created with correct title format `[FeatureID/TaskID] [Story] Description`
- [ ] V4: Labels applied (iikit, phase-N, us-N) — created if missing
- [ ] V5: Dependency cross-references linked via `#NNN` syntax
- [ ] V6: No duplicate issues created for previously exported tasks
- [ ] V7: Summary report displayed with issue count, numbers, and repo link
