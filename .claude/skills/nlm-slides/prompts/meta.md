# Meta — NLM Slides Skill

## Activation Triggers

### Positive Triggers
- "presentacion" / "presentaci\u00f3n"
- "slides"
- "deck"
- "diapositivas"
- "powerpoint"
- "/nlm:slides"
- "genera slides"
- "hazme una presentacion"
- "crear diapositivas"
- "slide deck"
- "hacer un deck"
- "preparar presentacion"

### False Positives — DO NOT activate
- "slide to unlock" — UI gesture
- "slide panel" — UI component
- "deck of cards" — card game reference
- "presentation layer" — software architecture term
- "PowerPoint template" — template request, not generation
- "compartir presentacion" — sharing existing file

## Disambiguation Rules

1. If user says "presentacion" + topic → activate
2. If user mentions NotebookLM/notebook + slides → activate immediately
3. If user says "diapositivas" alone → check for topic context
4. If user says "PowerPoint" + topic → activate (generate, not template)
5. If ambiguous, ask: "Quieres que genere una presentacion con NotebookLM?"

## Sub-Command Detection

| Keyword in message | Route to |
|-------------------|----------|
| "detallado" / "detailed" / "con notas" | `/nlm:slides:detailed` |
| "presenter" / "para presentar" / "keynote" | `/nlm:slides:presenter` |
| "revisar" / "mejorar" / "ajustar slide" | `/nlm:slides:revise` |
| "exportar" / "descargar" / "PDF" / "PPTX" | `/nlm:slides:export` |
| (none of above) | `/nlm:slides` (auto-detect) |

## Context Requirements

- At minimum: a topic or notebook_id
- Ideal: topic + presentation context + audience
- Optional: slide count preference, export format, specific slides to revise

## Handoff Protocol

When activated, route to `prompts/primary.md` with extracted context:
- `{TOPIC}`: extracted from user message
- `{CONTEXT}`: inferred presentation context (workshop/keynote/training/executive/technical)
- `{NOTEBOOK_ID}`: if provided
- `{AUDIENCE}`: who will view the slides
