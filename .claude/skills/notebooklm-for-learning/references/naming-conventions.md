# NLM for Learning — Naming Conventions

## Notebook Naming

### Pattern
```
{TOPIC} — {TYPE}: {NAME}
```

### Examples
```
BMAD Method — Learning Hub
BMAD Method — D1: Body of Knowledge
BMAD Method — D2: State of the Art
BMAD Method — D3: Capability Model
BMAD Method — D4: Profession Assessment
BMAD Method — D5: Maturity Model
BMAD Method — D6: Working Prompts
BMAD Method — D7: GenAI Applications
BMAD Method — L1: Cero a Competente
BMAD Method — L2: Competente a Versado
BMAD Method — L3: Versado a Experto
```

## Slug Generation

```
Input: "BMAD Method para desarrollo con IA"
Slug: "bmad-method-ia"

Rules:
1. Lowercase
2. Remove articles: "para", "con", "de", "el", "la", "los", "las", "un", "una"
3. Replace spaces with hyphens
4. Remove special characters
5. Max 40 characters
6. Trim trailing hyphens
```

## Source Labeling

### Simple (default)
```
[D1] Original Source Title
[D2] Original Source Title
```

### Detailed (deep mode)
```
[D1-FOUND] Foundational textbook or paper
[D1-HIST]  Historical reference
[D2-2026]  Recent publication (2024-2026)
[D2-TREND] Trend analysis
[D3-SKILL] Skill/competency description
[D4-ROLE]  Job role or career path
[D4-CERT]  Certification or credential
[D5-MODEL] Maturity model description
[D6-PRMT]  Prompt template or example
[D7-TOOL]  AI tool or platform
[D7-CASE]  Use case or application
```

## Note Naming

```
📚 {TOPIC} — Índice del Learning Hub
🔍 {TOPIC} — Auto-Diagnóstico de Nivel
🗺️ {TOPIC} — Ruta de Estudio
📊 {TOPIC} — Progreso y Logros
```

## Tag Convention

```
Tag format: lowercase, no spaces, hyphen-separated
Tags applied to ALL notebooks in ecosystem:
  - {slug}                    # topic identifier
  - nlm-learning              # skill identifier
  - dimension-d{N}            # dimension identifier (D1-D7)
  - level-l{N}                # level identifier (L1-L3)
  - hub                       # hub notebook only
```

## State File Naming

```
.specify/nlm-learning-state.json           # primary
.specify/nlm-learning-state.{slug}.json    # if multiple topics active
```

## Artifact Naming (downloads)

```
{slug}-l{N}-podcast.mp3
{slug}-l{N}-flashcards.json
{slug}-l{N}-quiz.json
{slug}-l{N}-mind-map.json
{slug}-l{N}-report.md
{slug}-l{N}-slides.pdf
{slug}-d{N}-infographic.png
```
