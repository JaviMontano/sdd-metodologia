# NLM Infographic — Quality Gate

## Pre-Generation Checklist

- [ ] Notebook has ≥3 sources (infographics need less data than podcasts)
- [ ] `notebook_describe()` confirms topic relevance
- [ ] `chat_configure()` applied with Capa 0 system prompt for selected orientation
- [ ] Source filtering: 5-20 sources selected (less = more focused visual)
- [ ] Focus prompt composed and verified ≤5000 chars
- [ ] Orientation matches content type (data→landscape, process→portrait, social→square)
- [ ] Style matches audience (corporate→professional, youth→kawaii, tech→scientific)
- [ ] Detail level matches density (≤5 points→concise, 5-15→standard, 15+→detailed)

## Post-Generation Checklist

- [ ] `studio_status()` returns "completed"
- [ ] Infographic artifact has non-null URL
- [ ] Download successful: `download_artifact()` produces valid PNG

## Visual Quality Checks (Agent Self-Assessment)

### Visual Density Check
| Detail Level | Expected Data Points | If Over |
|-------------|---------------------|---------|
| concise | ≤5 | Too dense — switch to standard |
| standard | 5-15 | Optimal |
| detailed | 15+ | Verify readability |

### Readability Guidelines
- Text must be legible at intended display size
- For portrait (mobile): minimum font would be ~14pt equivalent
- For landscape (presentation): minimum font would be ~18pt equivalent
- For square (social): maximum 50 words total

### Data Accuracy
After generation, verify key numbers via:
```
notebook_query(notebook_id, "What are the key numbers/metrics about {TOPIC}?")
```
Compare with infographic content — flag discrepancies.

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Too cluttered | detail_level too high for orientation | Lower detail_level |
| Too empty | detail_level too low for content | Increase to standard |
| Wrong style | Auto-select chose poorly | Override with explicit style |
| Missing key data | Source filtering too aggressive | Include more source_ids |
| Wrong language | Default "en" not overridden | Set language explicitly |
