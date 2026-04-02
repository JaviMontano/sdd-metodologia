---
name: nlm-podcast-primary
type: primary
---
# NLM Podcast — Execution Flow

## Dynamic Parameters
- `notebook_id` (REQUIRED) — UUID del notebook NotebookLM
- `format` (optional) — deep_dive | debate | brief | critique (auto-detected if omitted)
- `length` (optional) — short | default | long (auto-selected by format matrix)
- `focus_override` (optional) — Custom focus prompt text (≤5000 chars)
- `language` (optional) — BCP-47 code (default: "es")
- `source_ids` (optional) — Array of specific source UUIDs to use

## Execution Steps

### Step 1: Analyze Notebook
```
notebook_describe(notebook_id) → extract:
  - topic (string)
  - source_count (int)
  - summary (string, first ~500 chars for context)
```

### Step 2: Detect Format (if not specified)
Using `agents/producer.md` decision matrix:
- Map source_count + user intent → PM-0X from format-matrix.md
- Extract: audio_format, audio_length

### Step 3: Pre-Configure Chat (Capa 0)
```
chat_configure(
  notebook_id = notebook_id,
  goal = "custom",
  custom_prompt = [load from templates/system-prompts.md for selected format]
)
```

### Step 4: Filter Sources
```
For each source in notebook:
  source_describe(source_id) → evaluate relevance
Select top 15-30 most relevant → store as filtered_source_ids
If source_count < 5: WARN user, proceed with all sources
```

### Step 5: Compose Focus Prompt
```
1. Load template from references/focus-library.md (FP-P-0XX)
2. Replace placeholders:
   {TOPIC}         → topic from Step 1
   {AUDIENCE}      → detected audience
   {KEY_CONCEPTS}  → top 5-10 concepts from summary (max 500 chars)
   {SOURCE_COUNT}  → actual count
   {OBJECTIVE}     → user's stated or inferred objective
   {EXCLUSIONS}    → user-specified exclusions (or empty)
   {LANGUAGE}      → target language
3. Verify total ≤ 5000 chars
4. If over: truncate {KEY_CONCEPTS} first, then {EXCLUSIONS}
```

### Step 6: Confirm with User
Present to user:
```
🎙️ Podcast Configuration
━━━━━━━━━━━━━━━━━━━━━━━
Topic: {topic}
Format: {audio_format} ({audio_length})
Audience: {detected_audience}
Sources: {filtered_count}/{total_count} selected
Focus: {first 100 chars of focus_prompt}...
Language: {language}

¿Proceder con la generación?
```

### Step 7: Generate
```
studio_create(
  notebook_id = notebook_id,
  artifact_type = "audio",
  audio_format = audio_format,
  audio_length = audio_length,
  focus_prompt = composed_focus_prompt,
  source_ids = filtered_source_ids,
  language = language,
  confirm = true
)
```

### Step 8: Poll & Report
```
Loop every 30s:
  studio_status(notebook_id) → check artifact status
  If completed: report URL + estimated duration
  If failed: report error, suggest retry with different format
```
