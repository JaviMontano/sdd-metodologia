---
description: "SDD — Export feature artifacts as consolidated Markdown bundle or HTML"
user-invocable: true
---

# /sdd:export

Consolidates all artifacts of the active feature into a single exportable document.

## Execution

**Step 1**: Resolve active feature from `.specify/active-feature` or user argument.

**Step 2**: Collect artifacts from `specs/$FEATURE/`:
- CONSTITUTION.md (project root)
- spec.md (functional requirements)
- plan.md (technical design)
- checklist.md (quality checklists, if exists)
- tasks.md (task breakdown)
- analysis.md (consistency report, if exists)
- *.feature files (BDD test specs)
- QA-PLAN.md (if exists)

**Step 3**: Generate consolidated Markdown at `specs/$FEATURE/EXPORT.md`:

```markdown
# [Feature Name] — SDD Export
> Generated [date] by SDD v3.7 · MetodologIA

## Table of Contents
1. Constitution
2. Specification
3. Technical Plan
4. Quality Checklist
5. BDD Test Specs
6. Task Breakdown
7. Analysis Report

---

## 1. Constitution
[Full CONSTITUTION.md content]

## 2. Specification
[Full spec.md content]

... [each artifact as a section]
```

**Step 4**: Report file location and size.

## Options

- `markdown` (default) — Single .md file
- `html` — Branded Neo-Swiss HTML (reads design-tokens.json for styling)
