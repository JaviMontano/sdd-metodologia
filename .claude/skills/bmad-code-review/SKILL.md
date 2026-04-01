---
name: bmad-code-review
description: >-
  This skill should be used when the user asks to "review my code", "code review", "review this
  PR", "check my implementation", "review before merge", or "post-implementation review".
  It performs a structured code review with a quality checklist covering correctness, security,
  performance, maintainability, and test coverage. Use this skill AFTER implementation
  (/sdd:impl or /bmad-quick-dev) and BEFORE shipping (/sdd:issues).
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Code Review — Structured Post-Implementation Review [EXPLICIT]

Perform a structured code review against a quality checklist covering correctness, security, performance, maintainability, and test coverage.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. The input specifies the code, files, PR, or feature to review.

## Execution Flow

### 1. Identify Review Scope [EXPLICIT]

Extract from `$ARGUMENTS`:
- **What to review**: Specific files, a PR, a feature, or "recent changes"
- **Review focus**: Full review or specific concern (security, performance, etc.)
- **Context**: Related spec, story, or requirements

Determine scope by:
1. If files specified → review those files
2. If "recent changes" → check `git diff` or `git log`
3. If feature name → find related files in codebase
4. If PR number → review PR diff

### 2. Read and Analyze Code [EXPLICIT]

Read all files in scope. For each file, assess against the review checklist.

### 3. Apply Review Checklist [EXPLICIT]

```markdown
## Code Review: {scope description}

### Correctness
| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Logic matches requirements/AC | ✅/⚠️/❌ | {detail} |
| 2 | Edge cases handled | ✅/⚠️/❌ | {detail} |
| 3 | Error handling is appropriate | ✅/⚠️/❌ | {detail} |
| 4 | No off-by-one or boundary errors | ✅/⚠️/❌ | {detail} |

### Security
| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Input validation present | ✅/⚠️/❌ | {detail} |
| 2 | No injection vulnerabilities | ✅/⚠️/❌ | {detail} |
| 3 | Authentication/authorization correct | ✅/⚠️/❌ | {detail} |
| 4 | No secrets or credentials in code | ✅/⚠️/❌ | {detail} |

### Performance
| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | No unnecessary loops or N+1 queries | ✅/⚠️/❌ | {detail} |
| 2 | Appropriate data structures used | ✅/⚠️/❌ | {detail} |
| 3 | Resource cleanup (connections, files) | ✅/⚠️/❌ | {detail} |

### Maintainability
| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Code is readable and self-documenting | ✅/⚠️/❌ | {detail} |
| 2 | Functions have single responsibility | ✅/⚠️/❌ | {detail} |
| 3 | No code duplication | ✅/⚠️/❌ | {detail} |
| 4 | Consistent with project style | ✅/⚠️/❌ | {detail} |

### Test Coverage
| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Unit tests exist for new logic | ✅/⚠️/❌ | {detail} |
| 2 | Edge cases are tested | ✅/⚠️/❌ | {detail} |
| 3 | Tests are meaningful (not just coverage) | ✅/⚠️/❌ | {detail} |
```

### 4. Summarize Findings [EXPLICIT]

```markdown
## Review Summary

**Overall**: ✅ Approve | ⚠️ Approve with comments | ❌ Request changes

**Blocking Issues** (must fix):
1. {issue}: {file}:{line} — {description}

**Suggestions** (should consider):
1. {suggestion}: {file}:{line} — {description}

**Praise** (well done):
1. {positive observation}
```

### 5. Bridge to Pipeline [EXPLICIT]

- `/bmad-review-adversarial` — Deeper adversarial analysis if concerns found
- `/sdd:issues` — Ship if review passes
- `/sdd:test` — Add missing test scenarios if coverage gaps found
- `/sdd:impl` — Fix blocking issues and re-review

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Code is readable and accessible | Ask user to specify files if scope is unclear |
| 2 | Review covers the 5 standard categories | User can request focus on specific category |
| 3 | This is a code-level review, not architecture | For architecture review, use `/bmad-architect` |
| 4 | Checklist is comprehensive but not exhaustive | Note domain-specific checks may be needed |
| 5 | Review is constructive, not adversarial | For adversarial review, use `/bmad-review-adversarial` |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | No code changes to review | Ask what to review, suggest `git diff` |
| 2 | Review scope is massive (50+ files) | Focus on changed files or high-risk areas |
| 3 | Code is auto-generated | Note it, focus on configuration/integration code |
| 4 | User asks to review a specific concern only | Scope checklist to that category only |
| 5 | Code has no tests at all | Flag as blocking issue, recommend `/sdd:test` |

## Good vs Bad Example

**Good**: User asks "Review the auth module I just implemented" → Skill reads all auth files, applies full 5-category checklist, finds 1 blocking issue (missing rate limiting on login), 2 suggestions (extract token validation to utility, add logging), 1 praise (clean error handling). Provides file:line references for each finding.

**Bad**: User asks "Review the auth module" → Skill says "looks good" without reading the code, no checklist, no specific findings.

## Validation Gate [EXPLICIT]

- [ ] V1: Review scope was clearly identified
- [ ] V2: Code was actually read (not just described)
- [ ] V3: All 5 checklist categories were evaluated
- [ ] V4: Findings include file:line references
- [ ] V5: Clear verdict (approve / approve with comments / request changes)
- [ ] V6: Bridge to next step based on findings
