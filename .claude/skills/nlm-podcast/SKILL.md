---
name: nlm-podcast
description: >
  Podcast producer for NotebookLM. Generates high-precision audio artifacts
  (explanation, debate, brief, critique) using optimized focus prompt templates,
  Capa 0 system prompts, and source filtering. Ensures studio_create output
  never exceeds 5000 chars by composing template + dynamic context at runtime.
license: MIT
metadata:
  version: "1.0.0"
  engine: "NotebookLM MCP"
  max_focus_prompt: 5000
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__notebooklm__notebook_get
  - mcp__notebooklm__notebook_describe
  - mcp__notebooklm__notebook_query
  - mcp__notebooklm__source_describe
  - mcp__notebooklm__chat_configure
  - mcp__notebooklm__studio_create
  - mcp__notebooklm__studio_status
  - mcp__notebooklm__download_artifact
context:
  - type: file
    path: references/format-matrix.md
  - type: file
    path: references/focus-library.md
---

# NLM Podcast — Audio Vitaminado para NotebookLM

## 1. Qué hace este skill

Genera podcasts de **altísima precisión** desde cualquier notebook de NotebookLM.
En vez de un `studio_create` genérico, este skill:

1. **Analiza** el notebook (tema, fuentes, densidad)
2. **Detecta** la audiencia y objetivo óptimos
3. **Pre-configura** el chat con un system prompt Capa 0 específico al formato
4. **Filtra** las fuentes más relevantes (≤30, ≥5)
5. **Compone** un focus_prompt de ≤5000 chars (template + contexto dinámico)
6. **Genera** con parámetros óptimos (formato + longitud)
7. **Valida** con quality gate post-generación

## 2. Comandos

| Comando | Acción |
|---------|--------|
| `/nlm:podcast <notebook_id>` | Auto-detecta formato óptimo |
| `/nlm:podcast:explain <nb_id>` | Explicación (deep_dive + default) |
| `/nlm:podcast:debate <nb_id>` | Debate experto (debate + long) |
| `/nlm:podcast:brief <nb_id>` | Resumen ejecutivo (brief + short) |
| `/nlm:podcast:critique <nb_id>` | Crítica analítica (critique + default) |
| `/nlm:podcast:custom <nb_id> --focus "..."` | Focus personalizado |

## 3. Arquitectura de Prompt Composition

```
┌─────────────────────────────────────────────┐
│ Template base (~1800 chars)                 │ ← references/focus-library.md
│ Estructura, reglas narrativas, formato      │
├─────────────────────────────────────────────┤
│ Contexto dinámico (~2200 chars)             │ ← notebook_describe() + user intent
│ {TOPIC}, {AUDIENCE}, {KEY_CONCEPTS},        │
│ {SOURCE_COUNT}, {OBJECTIVE}, {EXCLUSIONS}   │
├─────────────────────────────────────────────┤
│ Instrucciones específicas (~1000 chars)     │ ← user overrides, language, emphasis
│ Custom adjustments, language, focus area    │
└─────────────────────────────────────────────┘
= Focus prompt final (≤5000 chars) → studio_create()
```

**Regla inquebrantable**: El prompt compuesto NUNCA supera 5000 chars.
Si el contexto dinámico excede el budget, el agente TRUNCA conceptos clave (max 10)
y reduce las instrucciones antes de enviar.

## 4. Pipeline (8 pasos)

1. **Analyze**: `notebook_describe(notebook_id)` → extraer topic, source count, summary
2. **Detect**: Mapear intent del usuario → format-matrix.md → seleccionar PM-0X
3. **Configure**: `chat_configure(notebook_id, goal="custom", custom_prompt=CAPA_0)`
   - System prompt desde `templates/system-prompts.md` según formato
4. **Filter**: `source_describe()` en top sources → seleccionar 5-30 más relevantes
5. **Compose**: Cargar template de `focus-library.md` → reemplazar placeholders → verificar ≤5000 chars
6. **Generate**: `studio_create(notebook_id, artifact_type="audio", audio_format=X, audio_length=Y, focus_prompt=Z, source_ids=[filtered], language=L, confirm=true)`
7. **Poll**: `studio_status(notebook_id)` cada 30s hasta completed
8. **Gate**: Verificar quality gate de `references/quality-gate.md`

## 5. Formatos de Audio

| Formato | audio_format | Mejor para | Duración típica |
|---------|-------------|-----------|-----------------|
| Explicación | `deep_dive` | Aprendizaje, onboarding | 15-25 min |
| Debate | `debate` | Análisis, perspectivas múltiples | 20-35 min |
| Resumen | `brief` | Ejecutivos, tiempo limitado | 5-10 min |
| Crítica | `critique` | Evaluación, decisiones | 10-20 min |

## 6. Quality Gate

Ver `references/quality-gate.md` para checklists pre/post generación.

## 7. Reference Index

| Need | Read |
|------|------|
| Combinaciones audiencia×formato×longitud | `references/format-matrix.md` |
| Prompt templates con placeholders | `references/focus-library.md` |
| Checklists pre/post generación | `references/quality-gate.md` |
| System prompts Capa 0 por formato | `templates/system-prompts.md` |
