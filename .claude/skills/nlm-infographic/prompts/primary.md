---
name: nlm-infographic-primary
type: primary
---
# NLM Infographic — Execution Flow

## Dynamic Parameters
- `notebook_id` (REQUIRED) — UUID del notebook NotebookLM
- `orientation` (optional) — portrait | landscape | square (auto-detected if omitted)
- `style` (optional) — professional | editorial | bento_grid | scientific | instructional | sketch_note | bricks | clay | kawaii | anime | auto_select
- `detail_level` (optional) — concise | standard | detailed (auto-detected)
- `focus_override` (optional) — Custom focus prompt (≤5000 chars)
- `language` (optional) — BCP-47 code (default: "es")

## Execution Steps

### Step 1: Analyze Notebook
```
notebook_describe(notebook_id) → extract topic, source_count, summary
notebook_query(notebook_id, "List key concepts and data points") → classify content
```

### Step 2: Auto-Detect Configuration
Using `agents/designer.md` decision trees:
- Content type → orientation (Tree 1)
- Content type → style (Tree 2)
- Source count + complexity → detail_level (Tree 3)

### Step 3: Pre-Configure Chat (Capa 0)
```
chat_configure(
  notebook_id = notebook_id,
  goal = "custom",
  custom_prompt = [load from templates/system-prompts.md for orientation]
)
```

### Step 4: Filter Sources
Select 5-20 most relevant sources for the infographic scope.

### Step 5: Compose Focus Prompt
```
1. Load template from references/focus-library.md (FP-I-0XX)
2. Replace: {TOPIC}, {KEY_CONCEPTS}, {DATA_POINTS}, {PLATFORM}, {AUDIENCE}, {EXCLUSIONS}
3. Verify ≤5000 chars — truncate DATA_POINTS first if over
```

### Step 6: Confirm with User
```
🎨 Infographic Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Topic: {topic}
Orientation: {orientation}
Style: {style}
Detail Level: {detail_level}
Sources: {filtered}/{total} selected
Focus: {first 100 chars}...

¿Proceder?
```

### Step 7: Generate
```
studio_create(
  notebook_id = notebook_id,
  artifact_type = "infographic",
  orientation = orientation,
  detail_level = detail_level,
  infographic_style = style,
  focus_prompt = composed_prompt,
  source_ids = filtered_ids,
  language = language,
  confirm = true
)
```

### Step 8: Poll
```
studio_status(notebook_id) every 30s → wait for completed
```

### Step 9: Download
```
download_artifact(
  notebook_id = notebook_id,
  artifact_type = "infographic",
  output_path = "{topic_slug}-{orientation}.png"
)
```

### Step 10: Quality Gate
Run `references/quality-gate.md` post-generation checklist.
