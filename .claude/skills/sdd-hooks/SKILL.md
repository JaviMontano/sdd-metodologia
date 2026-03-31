---
name: sdd-hooks
description: >-
  This skill should be used when the user asks to "install hooks", "set up git hooks",
  "enable assertion integrity", "install pre-commit hooks", "configure commit validation",
  or "protect test hashes". It installs git pre-commit and post-commit hooks that
  enforce assertion integrity by validating .feature file SHA-256 hashes on every commit.
  Use this skill whenever the user mentions hooks, assertion integrity, or commit validation.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Hooks — Git Hook Installation for Assertion Integrity [EXPLICIT]

Install git hooks that enforce assertion integrity by validating .feature file hashes on commit.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run Hook Installation

```bash
bash scripts/sdd-hooks-install.sh
```

### 2. Hooks Installed

| Hook | Purpose |
|------|---------|
| `pre-commit` | Validates .feature file SHA-256 hashes before allowing commit |
| `post-commit` | Updates sentinel state after successful commit |

### 3. Report

```
Hooks installed!

pre-commit:  .git/hooks/pre-commit (assertion hash validation)
post-commit: .git/hooks/post-commit (sentinel state update)

Test: modify a .feature file and try to commit — should be blocked
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Git repository exists | If no `.git/`, ERROR. [EXPLICIT] |
| 2 | Hooks directory writable | If permissions denied, suggest `chmod`. [EXPLICIT] |
| 3 | Existing hooks backed up | If hooks exist, backup as `.bak` before overwriting. [EXPLICIT] |
| 4 | Hooks are bash scripts | Require bash 3.2+ (macOS compatible). [EXPLICIT] |
| 5 | SHA-256 validation uses `.specify/assertion-hashes.json` | Hash store must exist for pre-commit to validate. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No git repo | `.git/` missing | ERROR: "Initialize git first". [EXPLICIT] |
| Existing hooks present | `.git/hooks/pre-commit` exists | Backup to `.bak`, install new, warn user. [EXPLICIT] |
| No .feature files yet | No assertion hashes to validate | Install hooks anyway — they'll activate when .feature files appear. [EXPLICIT] |
| Hooks disabled by user | `--no-verify` on commit | Cannot prevent — warn in report about bypass risk. [INFERRED] |
| Windows environment | Bash hooks on Windows | Suggest using Git Bash or WSL. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:hooks` installs with verification
```
Hooks installed!
pre-commit: validates 12 assertion hashes
post-commit: updates sentinel state
Backup: pre-commit.bak (previous hook preserved)
```

**Bad**: Hook installation without feedback
```
x No confirmation of what was installed
x No backup of existing hooks
x No test suggestion
```

**Why**: Hook installation must confirm what was installed, backup existing hooks, and suggest testing. [EXPLICIT]

## Validation Gate

Before marking hook installation as complete, verify: [EXPLICIT]

- [ ] V1: `.git/hooks/pre-commit` installed and executable
- [ ] V2: `.git/hooks/post-commit` installed and executable
- [ ] V3: Existing hooks backed up if present
- [ ] V4: Installation confirmed with hook descriptions
- [ ] V5: Test suggestion provided
