---
name: bmad-review-adversarial
description: >-
  This skill should be used when the user asks to "review this adversarially", "find what's missing",
  "hunt for edge cases", "critique this code", "find unhandled paths", "stress-test this spec",
  or "do a cynical review". It combines adversarial review (finding missing elements and wrong
  assumptions) with edge-case hunting (exhaustive boundary condition analysis) to provide
  comprehensive quality review. Use this skill for any artifact that needs rigorous scrutiny.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Review Adversarial — Cynical Review + Edge-Case Analysis [EXPLICIT]

Perform a dual-methodology review: adversarial review finds what's missing and what's wrong, while edge-case hunting mechanically derives every unhandled path and boundary condition.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input. Expected: artifact to review (code diff, spec, story, doc, or file path). Optional: `--mode adversarial|edge-cases|both` (default: both).

## Execution Flow

### 1. Load Artifact [EXPLICIT]

- Read the artifact from `$ARGUMENTS` (file path, inline content, or git diff)
- Identify artifact type: code, spec/PRD, architecture, story, test plan, or general doc
- Determine review scope: full artifact or specific sections

### 2. Adversarial Review [EXPLICIT]

Adopt a cynical, skeptical stance. For each section/component:

**Missing Elements**:
- What requirements are implied but not stated?
- What error handling is missing?
- What edge cases are not addressed?
- What dependencies are undeclared?
- What happens when this fails?

**Wrong Assumptions**:
- What implicit assumptions could be false?
- What "happy path only" logic exists?
- What race conditions or timing issues are possible?
- What security vulnerabilities exist?
- What scalability limits are not considered?

**Quality Issues**:
- What is over-engineered or under-engineered?
- What violates the project's own conventions?
- What would break during maintenance?
- What would a new team member misunderstand?

### 3. Edge-Case Hunting [EXPLICIT]

Apply exhaustive path-tracing methodology:

**Boundary Conditions**:
- Min/max values for every input
- Empty/null/undefined states
- Single vs multiple items
- First/last element behavior

**State Transitions**:
- Every entry and exit condition
- Interrupted operations (timeout, cancel, crash)
- Concurrent access patterns
- Recovery from partial failures

**Data Variations**:
- Unicode, special characters, extremely long strings
- Negative numbers, zero, overflow values
- Malformed input formats
- Missing optional fields

### 4. Classify Findings [EXPLICIT]

For each finding, assign:
- **Severity**: 🔴 Critical | 🟡 Warning | 🔵 Info
- **Category**: Missing | Wrong | Edge-Case | Quality
- **Location**: File + line/section reference
- **Recommendation**: Specific fix or investigation needed

### 5. Present Report [EXPLICIT]

```markdown
## 🔍 Adversarial Review Report

**Artifact**: {name/path}
**Mode**: {adversarial | edge-cases | both}
**Findings**: {count} ({critical} 🔴 | {warning} 🟡 | {info} 🔵)

### 🔴 Critical Findings
1. **{title}** — {location}
   {description}
   → Fix: {recommendation}

### 🟡 Warnings
...

### 🔵 Info
...

### Edge Cases Not Handled
| # | Input/State | Expected Behavior | Current Behavior |
|---|------------|-------------------|-----------------|
| 1 | {edge case} | {what should happen} | {what happens now} |
...
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Artifact is text-based and readable | Reject binary files |
| 2 | User wants brutally honest feedback | Frame as "adversarial review" — the cynicism is the feature |
| 3 | Not all findings are actionable | Classify by severity so user can prioritize |
| 4 | Edge-case hunting may produce false positives | Mark uncertain findings as 🔵 Info |
| 5 | Code review differs from spec review | Adapt methodology to artifact type |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Artifact is very small (< 20 lines) | Still review, but note limited scope |
| 2 | Artifact has no issues found | Report clean with confidence level |
| 3 | User provides a git diff, not a full file | Focus review on changed lines + surrounding context |
| 4 | Multiple files need review | Process each, aggregate findings in one report |
| 5 | Findings conflict with each other | Note the conflict and recommend investigation |

## Good vs Bad Example

**Good**: User submits an authentication module → Adversarial review finds: no rate limiting on login attempts (🔴), no account lockout after failures (🔴), password comparison not constant-time (🟡). Edge-case hunting finds: empty password string accepted (🔴), unicode normalization not applied (🟡), session token not invalidated on password change (🔴). Total: 10 findings with specific fix recommendations.

**Bad**: User submits the same module → Skill says "Looks good, maybe add some error handling" without specific findings, no edge cases analyzed, no severity classification.

## Validation Gate [EXPLICIT]

- [ ] V1: Artifact was successfully loaded and type identified
- [ ] V2: Adversarial review executed (missing + wrong + quality checks)
- [ ] V3: Edge-case hunting executed (boundaries + states + data variations)
- [ ] V4: All findings classified by severity (🔴🟡🔵)
- [ ] V5: Each finding includes location and specific fix recommendation
- [ ] V6: Report follows the structured format with totals
