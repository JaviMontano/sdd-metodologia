---
name: bmad-distillator
description: >-
  This skill should be used when the user asks to "compress a document", "distill this file",
  "make this LLM-friendly", "reduce tokens", "create a summary for AI consumption",
  or "optimize this for context window". It performs lossless token-efficient compression
  of documents into dense bullet-point format optimized for downstream LLM consumption.
  Use this skill when documents are too large for context windows.
license: MIT
metadata:
  version: "1.7.0"
---

# BMAD Distillator — Lossless Token-Efficient Compression [EXPLICIT]

Compress large documents into dense, token-efficient distillates that preserve ALL information for downstream LLM consumption. Verifiable through round-trip reconstruction.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input. Expected: path to the document to distill.

## Execution Flow

### 1. Analyze Source Document [EXPLICIT]

- Read the full document
- Count: total lines, words, estimated tokens (words × 1.3)
- Identify document type: PRD, architecture, spec, research, meeting notes, code docs
- Identify information density: high (code, specs) vs low (prose, narrative)

### 2. Apply Compression Strategy [EXPLICIT]

Use a 3-pass compression approach:

**Pass 1 — Structure Extraction**:
- Extract all headings, sub-headings, and section hierarchy
- Identify key entities: names, versions, dates, URLs, IDs
- Extract all tables, code blocks, and diagrams verbatim (never compress these)

**Pass 2 — Prose Compression**:
- Convert paragraphs to dense bullet points
- Remove filler words, redundant phrases, and narrative transitions
- Preserve: all facts, decisions, constraints, numbers, and proper nouns
- Use abbreviations: req → requirement, impl → implementation, config → configuration
- Collapse lists of examples to representative samples with `(+N more)`

**Pass 3 — Verification**:
- Compare distillate sections against source sections
- Flag any information that was present in source but missing in distillate
- Calculate compression ratio: `source_tokens / distillate_tokens`
- Target: 2:1 to 4:1 compression ratio

### 3. Format Distillate [EXPLICIT]

```markdown
# {Title} — Distillate

> Compressed from `{source-path}` | {date}
> Ratio: {X}:1 ({source-tokens} → {distillate-tokens} tokens)

## {Section 1}
- {bullet point 1}
- {bullet point 2}
  - {sub-detail}

## {Section 2}
...

## Preserved Verbatim
{tables, code blocks, diagrams — unchanged}
```

### 4. Report Results [EXPLICIT]

```markdown
## 🧪 Distillation Complete

| Metric | Value |
|--------|-------|
| Source | {path} ({lines} lines, ~{tokens} tokens) |
| Distillate | {output-path} ({lines} lines, ~{tokens} tokens) |
| Compression | {ratio}:1 |
| Info preserved | {percentage}% (verified) |

💡 Use the distillate for LLM context. Reference the original for human reading.
```

---

## Assumptions & Limits [EXPLICIT]

| # | Assumption | Mitigation |
|---|-----------|------------|
| 1 | Source is text-based (markdown, txt, code) | Reject binary files with clear error |
| 2 | Tables and code blocks must be preserved verbatim | Never compress structured data |
| 3 | Compression is lossless (no information lost) | Run verification pass and report coverage |
| 4 | Target ratio is 2:1 to 4:1 | Accept higher ratios for low-density prose |
| 5 | Distillate is for LLM consumption, not human reading | Optimize for token efficiency over readability |

## Edge Cases [EXPLICIT]

| # | Scenario | Behavior |
|---|----------|----------|
| 1 | Document is already dense (mostly code/tables) | Minimal compression possible, report low ratio |
| 2 | Document is very short (<100 lines) | Warn that distillation adds overhead for small files |
| 3 | Document contains images/diagrams | Preserve references, describe content in brackets |
| 4 | Multiple documents need distilling | Process sequentially, report aggregate stats |
| 5 | Compression loses critical info in verification | Flag the specific section and keep it uncompressed |

## Good vs Bad Example

**Good**: User distills a 2000-line architecture doc → 600-line distillate preserving all decisions, constraints, and tech stack. Tables and API contracts kept verbatim. Compression ratio 3.3:1 with 100% info preservation verified.

**Bad**: User distills the same doc → Gets a 200-line "summary" that loses NFR details, drops 3 of 8 API contracts, and paraphrases exact version numbers as "recent versions."

## Validation Gate [EXPLICIT]

- [ ] V1: Source document was fully read and analyzed
- [ ] V2: All tables, code blocks, and structured data preserved verbatim
- [ ] V3: Compression ratio calculated and reported
- [ ] V4: Verification pass confirmed no information loss
- [ ] V5: Output formatted as dense bullet points, not narrative prose
- [ ] V6: Original file preserved (distillate is a new file)
