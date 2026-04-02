---
name: nlm-learning-deep
type: variation
variant: deep
---
# NLM for Learning — Deep Mode

Maximum depth execution with additional passes, detailed labeling, and full artifact suite.

## Activation

Triggered when:
- User says `--deep`, `maximum depth`, `exhaustive`, `comprehensive`, `reference library`
- User says "I need this for my team", "build the most thorough learning ecosystem possible"
- Lead agent detects deep mode intent in natural language

State file: `state.mode` set to `"deep"`

## Modified Pipeline

### Phase 0: Preparation (same as standard)
- Hub + 7 dimension notebooks + 3 level notebooks = 11 total

### Phase 1: Genesis (enhanced)
- All 7 deep researches launched with `mode: "deep"` (same as standard)
- **No difference** — deep research is already the default

### Phase 2: Harvest (enhanced)
- **Labeling mode**: Use **detailed** labeling convention `[D{N}-SUB]` instead of simple
  - See `references/naming-conventions.md` for sub-category list
  - Example: `[D1-FOUND]`, `[D2-TREND]`, `[D3-SKILL]`, `[D4-ROLE]`, `[D5-MODEL]`, `[D6-PRMT]`, `[D7-CASE]`
- **Source quality audit**: Specialist runs noise detection heuristics on each dimension
  - Creates audit note in Hub per dimension with signal/noise analysis
- **G2 threshold elevated**: ≥20 PASS (vs ≥15 standard), 15-19 CONCERNS, <15 LOW_YIELD

### Phase 3: Synthesis (enhanced)
- Standard tutor configuration PLUS:
- **Cross-dimension synthesis**: Query D1-D7 with connecting questions:
  - "How do the capabilities in D3 relate to the maturity levels in D5?"
  - "Which working prompts from D6 address the profession roles in D4?"
  - "What GenAI applications from D7 require the skills described in D3?"
- Add synthesis results as text sources to L2 and L3 notebooks

### Phase 4: Artifacts (full suite)
All standard artifacts PLUS additional deep-mode artifacts:

| Artifact | Location | Type | Config |
|----------|----------|------|--------|
| Video overview | L1 | video | format: explainer, visual_style: auto_select |
| Debate podcast | L3 | audio | format: debate, length: long |
| Briefing Doc | Hub | report | format: Briefing Doc |
| Infographic | Each D1-D7 | infographic | orientation: landscape, detail: standard |
| Tools comparison | D2 | data_table | description: "Compare tools, frameworks in {TOPIC}" |
| Career paths table | D4 | data_table | description: "Career paths, roles, salaries in {TOPIC}" |
| Slide deck | D4 | slide_deck | format: detailed_deck |

**Total deep-mode artifacts**: Standard (9-11) + Deep extras (13) = **22-24 artifacts**

### Phase 5: Hub Assembly (enhanced)
- Standard index + diagnosis + study path notes
- **Additional**: Briefing Doc report added as Hub artifact
- **Additional**: Cross-reference note linking all dimension insights

## Modified Quality Gates (Deep Mode)

| Gate | Standard Threshold | Deep Threshold |
|------|-------------------|----------------|
| G2 | ≥15 PASS | ≥20 PASS |
| G3 | ≥100 total | ≥150 total |
| G5 | L1≥3, L2≥4, L3≥4 | L1≥5, L2≥6, L3≥6 (full suite) |

## Time Estimate

- **Parallel**: ~45 min (7 deep researches + artifact generation)
- **Sequential**: ~4 hrs (dimension by dimension with quality audits)
- **Recommended**: Sequential — quality over speed for deep mode

## When to Use

- User explicitly requests maximum depth
- Topic is central to user's career or business
- Building a reference library for a team, not just individual
- User has 45+ min to wait for full pipeline
- User wants detailed source classification and audit reports
