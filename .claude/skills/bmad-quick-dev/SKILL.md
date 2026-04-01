---
name: bmad-quick-dev
description: >-
  This skill should be used when the user asks to "quick dev", "quick implementation",
  "just build it", "rapid prototype", "small feature fast", or "bypass the full pipeline for
  this tiny change". It provides a controlled fast-track for small implementations (< 50 LOC
  or < 30 min effort) that don't warrant the full SDD pipeline. Includes guardrails to prevent
  abuse and ensures minimum quality standards.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Quick Dev — Rapid Implementation Bypass [EXPLICIT]

Provide a controlled fast-track for small implementations that bypass the full SDD pipeline while maintaining minimum quality standards.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input defines what to build quickly.

## Execution Flow

### 1. Assess Quick Dev Eligibility [EXPLICIT]

Check if the request qualifies for quick dev:

```markdown
## Quick Dev Assessment

| Criterion | Threshold | This Request |
|-----------|-----------|-------------|
| Lines of code | < 50 LOC | {estimate} |
| Effort | < 30 minutes | {estimate} |
| Files affected | ≤ 3 files | {estimate} |
| Risk level | Low (no auth, no data, no infra) | {assessment} |
| Dependencies | No new dependencies | {assessment} |

**Eligible**: ✅ Proceed with quick dev | ❌ Use full pipeline
```

If NOT eligible, redirect:
- Large feature → `/sdd:spec` → `/sdd:impl`
- Architecture change → `/bmad-architect`
- Multiple stories → `/bmad-sprint-planning`

### 2. Mini-Spec (30 seconds) [EXPLICIT]

Write a minimal specification:

```markdown
## Quick Dev: {Title}

**What**: {1-2 sentence description}
**Why**: {business reason or user need}
**How**: {approach in 1-2 sentences}
**Test**: {how to verify it works}
```

### 3. Implement [EXPLICIT]

Write the code directly. Follow these guardrails:
- **Read before write**: Read existing files before modifying
- **Minimal footprint**: Change only what's needed
- **No new dependencies** unless absolutely necessary
- **Match existing style**: Follow the project's conventions
- **Include basic error handling** at system boundaries

### 4. Verify [EXPLICIT]

After implementation:

```markdown
## Quick Dev Verification

- [ ] Code works as described in mini-spec
- [ ] Existing tests still pass
- [ ] No security vulnerabilities introduced
- [ ] Code matches project style
- [ ] Changes are < 50 LOC
```

If verification reveals the change is larger than expected, **stop and redirect** to the full pipeline.

### 5. Bridge to Pipeline [EXPLICIT]

- `/bmad-code-review` — Quick review of the implementation
- `/sdd:test` — Add tests if the change warrants them
- `/sdd:sentinel` — Check overall project health after change
- `/sdd:impl` — If change grew beyond quick dev scope

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Quick dev is for genuinely small changes | Enforce < 50 LOC / < 30 min / ≤ 3 files |
| 2 | User understands this bypasses quality gates | State clearly what's being skipped |
| 3 | Risk level is low (no security-critical changes) | Redirect security-sensitive changes to full pipeline |
| 4 | Quick dev doesn't mean no quality | Mini-spec + verification still apply |
| 5 | This is a controlled bypass, not an escape hatch | Track quick dev usage to prevent pattern abuse |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Change looks small but affects critical path | Redirect to full pipeline with explanation |
| 2 | "Quick" change keeps growing during implementation | Stop at 50 LOC, redirect to `/sdd:spec` |
| 3 | User wants to quick-dev a security feature | Always redirect to full pipeline for auth/security |
| 4 | Change is a one-line config update | Allow but still do mini-spec and verification |
| 5 | User repeatedly uses quick dev for everything | Flag pattern, suggest using the pipeline for better outcomes |

## Good vs Bad Example

**Good**: User asks "Quick dev — add a loading spinner to the submit button" → Skill assesses eligibility (< 10 LOC, 1 file, low risk ✅), writes mini-spec, reads existing button component, adds spinner state, verifies existing tests pass, suggests `/bmad-code-review` for a quick look.

**Bad**: User asks "Quick dev — add user authentication" → Skill implements auth in quick dev mode without redirecting to the full pipeline, skipping security review, test coverage, and architecture planning.

## Validation Gate [EXPLICIT]

- [ ] V1: Quick dev eligibility was explicitly assessed
- [ ] V2: Mini-spec was written before coding
- [ ] V3: Implementation stays within thresholds (< 50 LOC, ≤ 3 files)
- [ ] V4: Existing tests still pass
- [ ] V5: No security-sensitive changes were fast-tracked
- [ ] V6: Verification checklist was completed
