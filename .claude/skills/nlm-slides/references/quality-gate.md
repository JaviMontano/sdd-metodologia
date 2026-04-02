# Quality Gate — NLM Slides

> Checklists for pre-generation, post-generation, and slide-by-slide review.

---

## Pre-Generation Checklist

All 6 items must pass before calling `studio_create` with `artifact_type: "slide_deck"`.

| # | Check | How to Verify | Fail Action |
|---|-------|---------------|-------------|
| QG-PRE-01 | **Notebook has sources** | `notebook_get` returns ≥1 source | Add sources first |
| QG-PRE-02 | **Sources are processed** | Source status is not "processing" | Wait or poll until ready |
| QG-PRE-03 | **Format selected** | `slide_format` ∈ {detailed_deck, presenter_slides} | Run format-matrix selection |
| QG-PRE-04 | **Length selected** | `slide_length` ∈ {short, default} | Run format-matrix selection |
| QG-PRE-05 | **Focus prompt populated** | Focus ≤5000 chars, all placeholders replaced | Fill from user context |
| QG-PRE-06 | **Language confirmed** | Valid BCP-47 code | Default to "es" or "en" |

---

## Post-Generation Checklist

Verified after `studio_status` shows `status: "completed"`.

| # | Check | How to Verify | Fail Action |
|---|-------|---------------|-------------|
| QG-POST-01 | **Generation succeeded** | Artifact status is "completed" | Report error; suggest simplify + retry |
| QG-POST-02 | **Artifact accessible** | URL available in studio_status | Wait 30s, re-poll; max 3 retries |
| QG-POST-03 | **User review offered** | Present URL + export options | Always ask user preference |

---

## Slide-by-Slide Review Protocol

After post-generation checklist passes, the Presentation Architect performs a structural review.

### Review Criteria

| Slide Position | Check | Common Issue | Suggested Fix |
|---------------|-------|--------------|---------------|
| Slide 1 (Title) | Clear topic + audience | Vague or generic title | "Add subtitle specifying the target audience" |
| Slide 2 | Sets context or hook | Jumps to content too fast | "Add a problem statement or compelling question" |
| Body slides | 1 idea per slide | Information overload | "Split this slide into 2: concept and example" |
| Transition slides | Clear section breaks | No visual separation | "Add a section divider slide" |
| Data slides | Visual > text for data | Bullet-point data dumps | "Convert data to a chart or comparison table" |
| Penultimate | Summary / synthesis | Missing recap | "Add a summary slide before the closing" |
| Last slide | Call-to-action | Ends without direction | "Add next steps or call-to-action" |

### Review Output Format

Present as actionable suggestions:
```
Análisis del deck ({N} slides):

Fortalezas:
- [strength 1]
- [strength 2]

Sugerencias de mejora:
- Slide {X}: {specific suggestion}
- Slide {Y}: {specific suggestion}
- Slide {Z}: {specific suggestion}

¿Quieres que aplique estas mejoras? (studio_revise crea un nuevo deck — el original se preserva)
```

### Revision Execution Rules

1. **Maximum 5 slides per revision call** — more risks coherence issues
2. **Instructions must be specific** — "improve" is too vague; "add a diagram showing the 3 components" is specific
3. **One round of revision default** — second round only if user explicitly asks
4. **Always inform**: revision creates a NEW artifact; original is preserved
5. **After revision**: re-run post-generation checklist on new artifact

---

## Failure Recovery

| Failure | Recovery |
|---------|----------|
| No sources | Offer to add URL/text/Drive sources |
| Generation failed | Simplify focus; reduce sources; retry |
| Revision failed | Reduce number of slides being revised; simplify instructions |
| Export failed (PDF) | Try PPTX format instead |
| Export failed (PPTX) | Try PDF format instead |
| Timeout | Re-poll; slides can take 3-5 minutes |
| Slides too few | Add more sources or extend focus prompt with more sections |
| Slides too many | Use slide_length=short or reduce focus prompt scope |
