# Primary Prompt — NLM Slides Execution Flow

> Step-by-step execution flow for generating and optionally revising slide decks via NotebookLM.

---

## Phase 1: Context Gathering

1. **Extract from user request**:
   - Topic: What the presentation is about
   - Context: {workshop, keynote, training, executive, technical}
   - Audience: Who will see/use these slides
   - Notebook ID: If provided; else create notebook and add sources
   - Language: Detect from user input or ask

2. **If no notebook_id provided**:
   ```
   → notebook_create(title="{TOPIC} — Slides")
   → source_add(notebook_id, source_type="url"|"text", ...)
   → Wait for source processing
   ```

3. **Verify notebook readiness**:
   ```
   → notebook_get(notebook_id)
   → Confirm ≥1 source exists and is processed
   ```

## Phase 2: Format Selection

1. **Route to Presentation Architect** (agents/architect.md):
   - Input: user request + notebook metadata
   - Output: slide_format + slide_length + focus_template_id

2. **Load focus template** from references/focus-library.md:
   - Select FP-S-XXX matching architect decision
   - Fill placeholders: {TOPIC}, {AUDIENCE}, {KEY_CONCEPTS}, {OBJECTIVE}, {EXCLUSIONS}, {LANGUAGE}
   - Validate total ≤5000 chars

3. **Confirm with user**:
   ```
   "Voy a generar un deck tipo {slide_format} ({slide_length}) sobre {TOPIC}.
   ¿Procedo o prefieres ajustar algo?"
   ```

## Phase 3: Pre-Generation Quality Gate

Run references/quality-gate.md pre-generation checklist:
- [ ] QG-PRE-01: Notebook has sources
- [ ] QG-PRE-02: Sources are processed
- [ ] QG-PRE-03: Format selected (detailed_deck | presenter_slides)
- [ ] QG-PRE-04: Length selected (short | default)
- [ ] QG-PRE-05: Focus prompt populated and ≤5000 chars
- [ ] QG-PRE-06: Language confirmed

## Phase 4: Generation

```python
studio_create(
    notebook_id="{notebook_id}",
    artifact_type="slide_deck",
    slide_format="{selected_format}",      # detailed_deck | presenter_slides
    slide_length="{selected_length}",      # short | default
    focus_prompt="{populated_focus}",
    language="{language}",
    confirm=True
)
```

## Phase 5: Poll and Wait

```python
# Poll studio_status every 30s, max 5 min
studio_status(notebook_id="{notebook_id}")
# Check for artifact_type="slide_deck" with status="completed"
```

If status == "failed":
- Report error to user
- Suggest: simplify focus prompt, reduce sources, retry
- Do NOT auto-retry without user consent

## Phase 6: Post-Generation Review

1. **Run post-generation quality gate**:
   - [ ] QG-POST-01: Generation succeeded
   - [ ] QG-POST-02: Artifact accessible (URL available)
   - [ ] QG-POST-03: User review offered

2. **Present results**:
   ```
   Slide deck generado:
   - Formato: {slide_format} / {slide_length}
   - Tema: {TOPIC}
   - URL: {artifact_url}
   ```

3. **Offer revision** (key differentiator):
   ```
   "¿Quieres que analice las diapositivas y sugiera mejoras específicas?
   Puedo ajustar slides individuales sin regenerar todo el deck."
   ```

## Phase 7: Revision (Optional)

If user wants revision:

1. **Analyze current deck** via architect agent
2. **Propose specific changes** per slide:
   ```
   Sugerencias de revisión:
   - Slide 1: Agregar subtítulo con audiencia target
   - Slide 3: Simplificar diagrama — demasiado denso
   - Slide 7: Agregar call-to-action al cierre
   ```

3. **On user approval**, execute:
   ```python
   studio_revise(
       notebook_id="{notebook_id}",
       artifact_id="{original_artifact_id}",
       slide_instructions=[
           {"slide": 1, "instruction": "Add subtitle with target audience"},
           {"slide": 3, "instruction": "Simplify diagram, reduce to 3 key elements"},
           {"slide": 7, "instruction": "Add clear call-to-action with next steps"}
       ],
       confirm=True
   )
   ```

4. **Poll for revised deck** (new artifact):
   ```python
   studio_status(notebook_id="{notebook_id}")
   # New artifact created — original preserved
   ```

## Phase 8: Export

Offer export options:
- **Download PDF**: `download_artifact(notebook_id, artifact_type="slide_deck", output_path="slides.pdf")`
- **Download PPTX**: `download_artifact(notebook_id, artifact_type="slide_deck", output_path="slides.pptx", slide_deck_format="pptx")`
- **Export to Google Docs**: `export_artifact(notebook_id, artifact_id, export_type="docs")`

## Error Recovery

| Error | Recovery |
|-------|----------|
| No sources | Add sources before generating |
| Generation failed | Simplify focus, reduce sources, retry |
| Revision failed | Adjust instructions, try fewer slides at once |
| Export failed | Try alternative format (PDF vs PPTX) |
| Timeout | Re-poll; slides can take 3-5 minutes |
