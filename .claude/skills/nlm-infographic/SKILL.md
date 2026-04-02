---
name: nlm-infographic
description: >
  Visual designer for NotebookLM. Generates high-precision infographics
  (portrait, landscape, square) with 11 visual styles, 3 detail levels,
  and optimized focus prompts ≤5000 chars. Auto-detects optimal orientation
  and style based on content type.
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

# NLM Infographic — Visual Vitaminado para NotebookLM

## 1. Qué hace este skill

Genera infografías de **máxima precisión visual** desde cualquier notebook.
En vez de un `studio_create` genérico, este skill:

1. **Analiza** el contenido (datos, proceso, concepto, comparación)
2. **Recomienda** orientación + estilo + nivel de detalle óptimos
3. **Pre-configura** el chat con system prompt Capa 0 visual
4. **Compone** un focus_prompt ≤5000 chars (template + contexto + instrucciones)
5. **Genera** con parámetros optimizados
6. **Descarga** PNG para uso inmediato

## 2. Comandos

| Comando | Acción |
|---------|--------|
| `/nlm:infographic <nb_id>` | Auto-detecta orientación + estilo óptimos |
| `/nlm:infographic:portrait <nb_id>` | Vertical (Instagram, póster, blog largo) |
| `/nlm:infographic:landscape <nb_id>` | Horizontal (presentación, dashboard, header) |
| `/nlm:infographic:square <nb_id>` | Cuadrada (redes sociales, carousel) |

## 3. Parámetros de Infografía

### Orientaciones
| Orientación | Mejor para | Ratio |
|------------|-----------|-------|
| `portrait` | Procesos, timelines, tutoriales, Instagram | Vertical |
| `landscape` | Dashboards, comparaciones, presentaciones | Horizontal |
| `square` | Redes sociales, conceptos únicos, carousel | 1:1 |

### 11 Estilos Visuales
| Estilo | Mejor para |
|--------|-----------|
| `professional` | Corporate, ejecutivo, formal |
| `editorial` | Blog, publicaciones, storytelling |
| `bento_grid` | Datos estructurados, grids, comparaciones |
| `scientific` | Papers, técnico, académico |
| `instructional` | Tutoriales, paso a paso, how-to |
| `sketch_note` | Brainstorming, creativo, workshop |
| `bricks` | Modular, building blocks, arquitectura |
| `clay` | Lúdico, amigable, onboarding |
| `kawaii` | Informal, engaging, youth |
| `anime` | Tech culture, gaming, youth |
| `auto_select` | Dejar que NLM elija (default) |

### 3 Niveles de Detalle
| Detail Level | Cuándo usar | Data Points |
|-------------|-------------|-------------|
| `concise` | 1 mensaje clave, thumbnail, social | ≤5 |
| `standard` | Overview, blog, presentación | 5-15 |
| `detailed` | Referencia técnica, póster, handbook | 15+ |

## 4. Pipeline (10 pasos)

1. **Analyze**: `notebook_describe(nb_id)` → tema, source count, tipo de contenido
2. **Detect Content Type**: datos → landscape, proceso → portrait, social → square
3. **Recommend**: orientación + estilo + detail_level (ver `agents/designer.md`)
4. **Configure**: `chat_configure(nb_id, goal="custom", custom_prompt=CAPA_0_VISUAL)`
5. **Filter**: Seleccionar 5-20 fuentes más relevantes
6. **Compose**: Template de `focus-library.md` + placeholders → ≤5000 chars
7. **Confirm**: Presentar configuración al usuario
8. **Generate**: `studio_create(nb_id, "infographic", orientation, detail_level, infographic_style, focus_prompt, source_ids, language, confirm=true)`
9. **Poll**: `studio_status(nb_id)` cada 30s
10. **Download**: `download_artifact(nb_id, "infographic", output_path)` → PNG

## 5. Quality Gate

Ver `references/quality-gate.md`.

## 6. Reference Index

| Need | Read |
|------|------|
| Combinaciones orientación×estilo×detail | `references/format-matrix.md` |
| Prompt templates con placeholders | `references/focus-library.md` |
| Checklists pre/post generación | `references/quality-gate.md` |
| System prompts Capa 0 por orientación | `templates/system-prompts.md` |
