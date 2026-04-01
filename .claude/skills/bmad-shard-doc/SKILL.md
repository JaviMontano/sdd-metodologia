---
name: bmad-shard-doc
description: >-
  This skill should be used when the user asks to "shard a document", "split this file",
  "break up this large document", "optimize context window", "split for LLM consumption",
  or "create section files from markdown". It splits large markdown documents into smaller,
  organized section files using level-2 headers as split points, creating an index.md for
  navigation. Use this skill when documents exceed 500 lines or need context optimization.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Shard Doc — Document Sharding for Context Optimization [EXPLICIT]

Split large markdown documents into smaller, organized section files using level-2 headers as split points, with an auto-generated index for navigation and LLM context management.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input. Expected: path to the source markdown file, optional destination folder.

## Execution Flow

### 1. Validate Source [EXPLICIT]

- Verify the source file exists and is markdown (`.md`)
- Count total lines and level-2 (`##`) headers
- If < 200 lines or < 3 sections, warn that sharding may not be necessary

### 2. Parse Section Boundaries [EXPLICIT]

- Split on `## ` (level-2 headers) as primary breakpoints
- Preserve frontmatter (YAML between `---` markers) in a separate `00-frontmatter.md`
- Keep content before the first `##` header in `01-introduction.md`
- Number sections sequentially: `01-{slug}.md`, `02-{slug}.md`, etc.
- Slug generation: lowercase, hyphens, max 40 chars from the header text

### 3. Create Section Files [EXPLICIT]

For each section:
- Include the original `##` header as `# {header}` (promoted to h1)
- Preserve all content until the next `##` header
- Maintain internal links, code blocks, and formatting
- Add a footer: `---\n_Sharded from: {source-filename} | Section {N} of {total}_`

### 4. Generate Index [EXPLICIT]

Create `index.md` in the destination folder:

```markdown
# {Original Document Title}

> Sharded into {N} sections from `{source-path}` on {date}
> Total: {line-count} lines → {N} files

## Sections

| # | Section | Lines | File |
|---|---------|-------|------|
| 1 | {title} | {lines} | [01-{slug}.md](01-{slug}.md) |
| 2 | {title} | {lines} | [02-{slug}.md](02-{slug}.md) |
...
```

### 5. Report Results [EXPLICIT]

```markdown
## 📄 Shard Complete

**Source**: {path} ({total-lines} lines)
**Output**: {dest-folder}/ ({N} section files + index.md)
**Compression**: Original 1 file → {N+1} files

| Section | Lines | File |
|---------|-------|------|
| {title} | {n} | {filename} |
...

💡 Load only the sections you need to preserve context window budget.
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Source is well-structured markdown with `##` headers | Fall back to line-count splitting (every ~200 lines) if no headers |
| 2 | Destination folder does not exist yet | Create it; if exists, warn before overwriting |
| 3 | Document uses CommonMark syntax | Handle GFM tables, code blocks, and admonitions |
| 4 | Internal cross-references may break after sharding | Update relative links in section files |
| 5 | User wants to keep the original file | Never delete source; offer to archive |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Document has no `##` headers | Split by `#` headers or by line count (200-line chunks) |
| 2 | Document is < 200 lines | Warn "too small to shard" but proceed if user insists |
| 3 | Section contains massive code block (>500 lines) | Keep code block intact, do not split mid-block |
| 4 | Source has YAML frontmatter | Preserve in separate `00-frontmatter.md` |
| 5 | Destination folder already has files | Warn and ask for confirmation before overwriting |

## Good vs Bad Example

**Good**: User runs `/bmad-shard-doc docs/architecture.md docs/arch-sections/` → Skill finds 12 `##` headers, creates 13 files (00-frontmatter + 01..12 sections + index.md), reports line counts per section.

**Bad**: User runs `/bmad-shard-doc docs/architecture.md` → Skill splits mid-paragraph, breaks code blocks, loses frontmatter, no index generated.

## Validation Gate [EXPLICIT]

- [ ] V1: Source file was validated as markdown
- [ ] V2: All `##` sections were identified and split correctly
- [ ] V3: No content was lost (total lines of sections = total lines of source)
- [ ] V4: Code blocks and tables were not split mid-block
- [ ] V5: Index.md was generated with links to all sections
- [ ] V6: Original source file was preserved (not deleted)
