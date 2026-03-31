---
name: iikit-04-testify
description: >-
  This skill should be used when the user asks to "generate test scenarios",
  "create BDD tests", "write Gherkin features", "add acceptance criteria tests",
  or "verify requirements with assertion hashing".
  It produces cryptographically-verified .feature files with SHA-256 assertion hashes
  that prevent unauthorized test modification by AI agents.
  Use this skill whenever the user mentions testing, BDD, or Gherkin,
  even if they don't explicitly ask for "testify".
license: MIT
metadata:
  version: "1.7.0"
---

# Intent Integrity Kit Testify [EXPLICIT]

Generate executable Gherkin `.feature` files from requirement artifacts before implementation. Enables TDD by creating hash-locked BDD scenarios that serve as acceptance criteria.

## User Input

```text
$ARGUMENTS
```

This skill accepts **no user input parameters** — it reads artifacts automatically.

## Constitution Loading

Load constitution per [constitution-loading.md](../iikit-core/references/constitution-loading.md) (basic mode), then perform TDD assessment:

**Scan for TDD indicators**:
- Strong (MUST/REQUIRED + "TDD", "test-first", "red-green-refactor") -> **mandatory**
- Moderate (MUST + "test-driven", "tests before code") -> **mandatory**
- Implicit (SHOULD + "quality gates", "coverage requirements") -> **optional**
- Prohibition (MUST + "test-after", "no unit tests") -> **forbidden** (ERROR, halt)
- None found -> **optional**

Report per [formatting-guide.md](../iikit-core/references/formatting-guide.md) (TDD Assessment section).

## Prerequisites Check

1. Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/check-prerequisites.sh --phase 04 --json`
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/check-prerequisites.ps1 -Phase 04 -Json`
2. Parse for `FEATURE_DIR` and `AVAILABLE_DOCS`. Require **plan.md** and **spec.md** (ERROR if missing).
3. If JSON contains `needs_selection: true`: present the `features` array as a numbered table (name and stage columns). Follow the options presentation pattern in [conversation-guide.md](../iikit-core/references/conversation-guide.md). After user selects, run:
   ```bash
   bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/set-active-feature.sh --json <selection>
   ```
   Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/set-active-feature.ps1 -Json <selection>`

   Then re-run the prerequisites check from step 1.
4. Checklist gate per [checklist-gate.md](../iikit-core/references/checklist-gate.md).

## Acceptance Scenario Validation

Search spec.md for Given/When/Then patterns. If none found: ERROR with `Run: /iikit-clarify`.

## Execution Flow

### 1. Load Artifacts

- **Required**: `spec.md` (acceptance scenarios), `plan.md` (API contracts, tech stack)
- **Optional**: `data-model.md` (validation rules)

### 2. Generate Gherkin Feature Files

Create `.feature` files in `FEATURE_DIR/tests/features/`:

**Output directory**: `FEATURE_DIR/tests/features/` (create if it does not exist)

**File organization**: Generate one `.feature` file per user story or logical grouping. Use descriptive filenames (e.g., `login.feature`, `user-management.feature`).

#### 2.1 Gherkin Tag Conventions

Every scenario MUST include traceability tags:
- `@TS-XXX` — test spec ID (sequential, unique across all .feature files)
- `@FR-XXX` — functional requirement from spec.md
- `@SC-XXX` — success criteria from spec.md
- `@US-XXX` — user story reference
- `@P1` / `@P2` / `@P3` — priority level
- `@acceptance` / `@contract` / `@validation` — test type

**SC-XXX coverage rule**: For each SC-XXX in spec.md, ensure at least one scenario is tagged with the corresponding `@SC-XXX`. If an FR scenario already covers the success criterion, add the `@SC-XXX` tag to that scenario rather than creating a duplicate.

Feature-level tags for shared metadata:
- `@US-XXX` on the Feature line for the parent user story

#### 2.2 Transformation Rules

**From spec.md — Acceptance Tests**: For each Given/When/Then scenario, generate a Gherkin scenario.

Use [testspec-template.md](../iikit-core/templates/testspec-template.md) as the Gherkin file template. For transformation examples, advanced constructs (Background, Scenario Outline, Rule), and syntax validation rules, see [gherkin-reference.md](references/gherkin-reference.md).

### 3. Add DO NOT MODIFY Markers

Add an HTML comment at the top of each `.feature` file:
```gherkin
# DO NOT MODIFY SCENARIOS
# These .feature files define expected behavior derived from requirements.
# During implementation:
#   - Write step definitions to match these scenarios
#   - Fix code to pass tests, don't modify .feature files
#   - If requirements change, re-run /iikit-04-testify
```

### 4. Idempotency

If `tests/features/` already contains `.feature` files:
- Preserve existing scenario tags (TS-XXX) where the source scenario is unchanged
- Add new scenarios for new requirements
- Mark removed scenarios as deprecated (comment out with `# DEPRECATED:`)
- Show diff summary of changes

### 5. Store Assertion Integrity Hash

**CRITICAL**: Store SHA256 hash of assertion content in both locations:

```bash
# Context.json (auto-derived from features directory path)
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh store-hash "FEATURE_DIR/tests/features"

# Git note (tamper-resistant backup — uses first .feature file for note attachment)
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/testify-tdd.sh store-git-note "FEATURE_DIR/tests/features"
```

**Windows (PowerShell):**
```powershell
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/testify-tdd.ps1 store-hash "FEATURE_DIR/tests/features"
pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/testify-tdd.ps1 store-git-note "FEATURE_DIR/tests/features"
```

The implement skill verifies this hash before proceeding, blocking if `.feature` file assertions were tampered with.

### 5b. Generate QA Test Coverage Matrix

Generate `FEATURE_DIR/qa/test-coverage.md` with FR→TS traceability:

```markdown
# Test Coverage Matrix — {Feature Name}
Generated from .feature files | {date}

## FR → TS Traceability
| Requirement | Tests | Coverage |
|-------------|-------|----------|
| FR-001 | TS-001, TS-002, TS-003 | 3 scenarios |
| FR-002 | TS-004 | 1 scenario |
| FR-003 | — | UNTESTED |

## Summary
- Total FR: {N} | Covered: {M} | Untested: {K}
- Coverage: {M/N * 100}%
- Assertion Hash: {sha256}
```

Each FR-XXX from spec.md is matched against @FR-XXX tags in .feature files. Untested FRs are flagged.

### 6. Report

Output: TDD determination, scenario counts by source (acceptance/contract/validation), output directory path, number of `.feature` files generated, hash status (LOCKED).

## Error Handling

| Condition | Response |
|-----------|----------|
| No constitution | ERROR: Run /iikit-00-constitution |
| TDD forbidden | ERROR with evidence |
| No plan.md | ERROR: Run /iikit-02-plan |
| No spec.md | ERROR: Run /iikit-01-specify |
| No acceptance scenarios | ERROR: Run /iikit-clarify |
| .feature syntax error | FIX: Auto-correct and report |

## Commit

```bash
git add specs/*/tests/features/ specs/*/context.json .specify/context.json
git commit -m "testify: <feature-short-name> BDD scenarios"
```

## Dashboard Refresh

Regenerate the dashboard so the pipeline reflects the new testify artifacts:

```bash
bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/generate-dashboard-safe.sh
```

Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/generate-dashboard-safe.ps1`

## Next Steps

Run: `bash .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/bash/next-step.sh --phase 04 --json`
Windows: `pwsh .tessl/tiles/tessl-labs/intent-integrity-kit/skills/iikit-core/scripts/powershell/next-step.ps1 -Phase 04 -Json`

Parse the JSON and present:
1. If `clear_after` is true: suggest `/clear` before proceeding
2. Present `next_step` as the primary recommendation
3. If `alt_steps` non-empty: list as alternatives
4. For `next_step` and each `alt_step`, include the `model_tier` from the JSON so the user knows which model is best for each option. Look up tiers in [model-recommendations.md](../iikit-core/references/model-recommendations.md) for agent-specific switch commands.
5. Append dashboard link

Format:
```
Feature files generated!
Next: [/clear → ] <next_step> (model: <tier>)
[- <alt_step> — <reason> (model: <tier>)]

- Dashboard: file://$(pwd)/.specify/dashboard.html (resolve the path)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | spec.md exists with FR-NNN and SC-NNN identifiers | Prerequisite check validates; blocks execution if missing. [EXPLICIT] |
| 2 | plan.md exists with technical decisions | Prerequisite check validates; blocks if missing. Tests need architecture context. [EXPLICIT] |
| 3 | SHA-256 hashing requires each scenario to have a unique assertion block | Duplicate assertions are detected and rejected during hash generation. [EXPLICIT] |
| 4 | .feature files follow Gherkin syntax (Given/When/Then) | Template enforces structure; malformed scenarios are caught during validation. [EXPLICIT] |
| 5 | Assertion hashes are immutable once committed | Pre-commit hook validates hash integrity; modified assertions fail the hook. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| Spec has scenarios without Given/When/Then structure | SC-NNN entries missing keywords | Convert to proper Gherkin structure or flag as incomplete for /iikit-clarify. [EXPLICIT] |
| Assertion hash collision (astronomically rare with SHA-256) | Duplicate hash detected in assertion-hashes.json | Append scenario ID to hash input to guarantee uniqueness. [EXPLICIT] |
| Feature file already exists for this spec | .feature file found in feature directory | Offer: (a) regenerate and rehash, (b) append new scenarios only, (c) skip. Never silently overwrite. [EXPLICIT] |
| TDD mode: tests before implementation | User invokes with --tdd flag or mentions "test first" | Generate test stubs that will fail (red phase), suggest /iikit-07-implement for green phase. [EXPLICIT] |
| Spec references external API contracts | FR-NNN contains API endpoint references from plan.md | Generate API contract test scenarios with mock expectations. [INFERRED] |

## Good vs Bad Example

**Good**: Properly hashed BDD scenario
```gherkin
Feature: User Registration
  @FR-001 @SC-001
  Scenario: Successful registration with valid credentials
    Given a new user with email "test@example.com"
    And a password meeting strength requirements
    When the user submits the registration form
    Then an account is created with status "pending_verification"
    And a verification email is sent to "test@example.com"
    # assertion-hash: a3f2b8c1d4e5f6... (SHA-256 of normalized scenario)
```

**Bad**: Untraceable, unhashed scenario
```gherkin
Scenario: Registration works
  Given a user
  When they register
  Then it works
```

**Why**: Good scenarios have FR/SC traceability tags, specific Given/When/Then steps with concrete data, and a cryptographic assertion hash that prevents unauthorized modification. Bad scenarios lack traceability, use vague language, and have no integrity verification. [EXPLICIT]

## Validation Gate

Before marking testify as complete, verify: [EXPLICIT]

- [ ] V1: Every SC-NNN from spec.md has a corresponding Gherkin scenario
- [ ] V2: All scenarios have @FR-NNN and @SC-NNN tags for traceability
- [ ] V3: Every scenario has a SHA-256 assertion hash comment
- [ ] V4: assertion-hashes.json is updated with all new hashes
- [ ] V5: No duplicate assertion hashes exist
- [ ] V6: Gherkin syntax validates (Given/When/Then present in every scenario)
- [ ] V7: Pre-commit hook is installed for hash verification
- [ ] V8: Next step recommendation displayed (/iikit-05-tasks or /iikit-06-analyze)
