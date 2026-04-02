# Format Matrix — NLM Slides

> Selection guide: match presentation context to NotebookLM slide parameters.

| ID | Context | slide_format | slide_length | Typical Slides | Rationale |
|------|-----------|------------------|--------------|----------------|-----------|
| SM-01 | Workshop | detailed_deck | default | 15-25 | Speaker notes essential for facilitation; exercises need detail |
| SM-02 | Keynote | presenter_slides | default | 12-20 | Clean visuals; speaker drives the narrative, not the slides |
| SM-03 | Training | detailed_deck | default | 20-30 | Self-contained for async learning; notes serve as reference |
| SM-04 | Executive | presenter_slides | short | 6-10 | Minimal slides, maximum impact; every slide earns its place |
| SM-05 | Technical | detailed_deck | default | 15-25 | Detail-heavy; diagrams, specs, and reference material |

## Selection Algorithm

```
1. Identify presentation context → {workshop, keynote, training, executive, technical}
2. Match to SM-XX row
3. Extract slide_format + slide_length
4. Load corresponding focus template from focus-library.md (FP-S-0XX)
5. Load Capa 0 system prompt from templates/system-prompts.md
```

## Context Detection Heuristics

| Signal | Inferred Context |
|--------|-----------------|
| "taller", "hands-on", "ejercicio práctico" | Workshop |
| "conferencia", "charla", "keynote", "TED" | Keynote |
| "capacitación", "curso", "formación", "onboarding" | Training |
| "junta directiva", "board", "C-suite", "decisión" | Executive |
| "arquitectura", "API", "sistema", "código", "infra" | Technical |

## Override Rules

- User explicitly requests a format → use it regardless of matrix
- User says "corto" / "pocas slides" → override slide_length=short
- User says "detallado" / "completo" → override to detailed_deck + default
- User specifies slide count (e.g., "10 slides") → adjust length accordingly
- Content has < 2 sources → prefer short length

## Post-Generation Revision Triggers

After generation, the Presentation Architect evaluates:
- Title slide clarity
- Content density per slide (too dense → suggest split)
- Narrative arc (intro → body → conclusion)
- Call-to-action presence on final slide
- Section transitions
