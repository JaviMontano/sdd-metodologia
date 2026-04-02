# Quality Gate — NLM Podcast

> Checklists that must pass before and after audio generation.

---

## Pre-Generation Checklist

All 6 items must be verified before calling `studio_create` with `artifact_type: "audio"`.

| # | Check | How to Verify | Fail Action |
|---|-------|---------------|-------------|
| QG-PRE-01 | **Notebook has sources** | `notebook_get` returns ≥1 source | Add sources first — audio without sources is empty |
| QG-PRE-02 | **Sources are processed** | Source status is not "processing" | Wait or poll `notebook_get` until ready |
| QG-PRE-03 | **Format selected** | `audio_format` ∈ {deep_dive, debate, brief, critique} | Run format-matrix selection algorithm |
| QG-PRE-04 | **Length selected** | `audio_length` ∈ {short, default, long} | Run format-matrix selection algorithm |
| QG-PRE-05 | **Focus prompt populated** | Focus prompt ≤5000 chars, all placeholders replaced | Fill placeholders from user context; truncate if over limit |
| QG-PRE-06 | **Language confirmed** | `language` is valid BCP-47 code | Default to "es" if user speaks Spanish, "en" otherwise |

### Pre-Generation Decision Record

Before generating, log:
```
- Notebook: {notebook_id}
- Sources: {count} sources, {total_chars} chars estimated
- Format: {audio_format} / {audio_length}
- Focus template: {FP-P-XXX}
- Language: {language}
- User confirmation: {yes/no}
```

---

## Post-Generation Checklist

All 3 items verified after `studio_status` shows `status: "completed"`.

| # | Check | How to Verify | Fail Action |
|---|-------|---------------|-------------|
| QG-POST-01 | **Generation succeeded** | `studio_status` → artifact status is "completed" | If "failed", report error and suggest: reduce sources, simplify focus, retry |
| QG-POST-02 | **Artifact accessible** | `studio_status` returns a valid URL | If no URL, wait 30s and re-poll; max 3 retries |
| QG-POST-03 | **User review offered** | Present URL + offer download option | Always ask: "Quieres que descargue el audio o prefieres escucharlo en NotebookLM?" |

### Post-Generation Report Template

```
Podcast generado:
- Tipo: {audio_format} / {audio_length}
- Tema: {TOPIC}
- Fuentes usadas: {count}
- URL: {artifact_url}
- Siguiente: escuchar en NotebookLM o descargar con /nlm:podcast:download
```

---

## Failure Recovery

| Failure | Recovery |
|---------|----------|
| No sources in notebook | Offer to add URL/text/Drive sources |
| Generation timeout | Re-poll after 60s; NotebookLM audio can take 2-5 min |
| Generation failed | Simplify focus prompt; reduce to ≤3 sources; retry |
| Audio too short | Switch to longer length or add more sources |
| Audio off-topic | Refine focus prompt with more specific {KEY_CONCEPTS} |
