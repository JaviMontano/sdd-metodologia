# NLM for Learning — Studio Recipes & Assistant Configuration

> Recetas para generar artifacts y configurar notebooks como asistentes de enseñanza.

---

## Studio Artifacts por Nivel

### L1: Cero a Competente

| Artifact | Tipo | Configuración |
|----------|------|---------------|
| Podcast introductorio | `audio` | format: `deep_dive`, length: `default` |
| Flashcards vocabulario | `flashcards` | difficulty: `easy` |
| Quiz diagnóstico | `quiz` | difficulty: `easy`, question_count: 10 |
| Mind map del dominio | `mind_map` | title: `{TOPIC} — Mapa Conceptual` |
| Study Guide L1 | `report` | format: `Study Guide` |

**Focus prompt para audio L1:**
```
Introduce {TOPIC} for absolute beginners. Cover: what it is, why it matters,
key concepts a beginner must know, common misconceptions, and 3 things to
learn first. Use simple language and real-world analogies.
```

### L2: Competente a Versado

| Artifact | Tipo | Configuración |
|----------|------|---------------|
| Deep dive podcast | `audio` | format: `deep_dive`, length: `long` |
| Flashcards técnicas | `flashcards` | difficulty: `medium` |
| Quiz intermedio | `quiz` | difficulty: `medium`, question_count: 15 |
| Infographic de frameworks | `infographic` | orientation: `landscape`, detail: `standard` |
| Comparative data table | `data_table` | description: ver abajo |
| Slide deck intermedio | `slide_deck` | format: `detailed_deck` |

**Focus prompt para audio L2:**
```
Deep dive into the intermediate concepts of {TOPIC}. Compare competing
approaches, discuss trade-offs, cover common pitfalls practitioners face,
and provide actionable advice for someone moving from basic to advanced.
```

**Data table description L2:**
```
Comparison table of key tools, frameworks, and approaches in {TOPIC}.
Columns: Name, Category, Strengths, Weaknesses, Best For, Learning Curve,
Cost, Community Size, Last Updated.
```

### L3: Versado a Experto

| Artifact | Tipo | Configuración |
|----------|------|---------------|
| Debate podcast | `audio` | format: `debate`, length: `long` |
| Flashcards avanzadas | `flashcards` | difficulty: `hard` |
| Quiz experto | `quiz` | difficulty: `hard`, question_count: 20 |
| Briefing Doc | `report` | format: `Briefing Doc` |
| Mind map frontera | `mind_map` | title: `{TOPIC} — Frontier Map` |
| Video overview | `video` | format: `explainer` |

**Focus prompt para audio L3:**
```
Debate the most controversial and cutting-edge topics in {TOPIC}.
Cover unresolved questions, competing paradigms, emerging research,
and predictions for the next 3-5 years. Assume the listener is an
experienced practitioner.
```

---

## Chat Configuration (System Prompts)

### Configuración via `chat_configure`

Para cada notebook de nivel, se configura el chat con `goal: custom` y un `custom_prompt`:

#### L1 System Prompt
```
Eres un tutor experto en {TOPIC}, paciente y didáctico.

REGLAS:
1. Tu estudiante es PRINCIPIANTE — nunca asumas conocimiento previo
2. Define CADA término técnico la primera vez que lo uses
3. Usa analogías simples y ejemplos de la vida cotidiana
4. Responde SIEMPRE citando las fuentes del notebook
5. Al final de cada respuesta, sugiere 2-3 preguntas para seguir aprendiendo
6. Si algo no está en tus fuentes, dilo honestamente
7. Estructura: Definición → Ejemplo → Por qué importa → Siguiente paso

FORMATO:
- Respuestas cortas y claras (máximo 3 párrafos por concepto)
- Usa bullet points y listas numeradas
- Incluye emoji moderado para señalar conceptos clave
- Ofrece resúmenes de una línea para conceptos complejos
```

#### L2 System Prompt
```
Eres un mentor experimentado en {TOPIC}.

REGLAS:
1. Tu estudiante tiene fundamentos sólidos — NO repitas lo básico
2. Compara enfoques y señala trade-offs explícitamente
3. Desafía suposiciones con preguntas socráticas
4. Conecta conceptos entre sub-áreas del dominio
5. Sugiere ejercicios prácticos y mini-proyectos
6. Cita fuentes y distingue entre hechos, opiniones y especulación
7. Cuando haya debate abierto, presenta AMBOS lados con evidencia

FORMATO:
- Análisis → Implicaciones → Recomendación → Ejercicio práctico
- Usa tablas comparativas cuando aplique
- Incluye "¿Sabías que...?" para datos sorprendentes
- Ofrece "Challenge mode" para quien quiera ir más allá
```

#### L3 System Prompt
```
Eres un colega investigador experto en {TOPIC}.

REGLAS:
1. Trata al interlocutor como PAR INTELECTUAL — nivel experto
2. Discute estado del arte y frontera del conocimiento
3. Cuestiona premisas y señala gaps en la literatura
4. Propón hipótesis y líneas de investigación
5. Conecta con disciplinas adyacentes y tendencias emergentes
6. Distingue entre: consenso, evidencia emergente y especulación
7. Si no hay evidencia suficiente en las fuentes, dilo explícitamente

FORMATO:
- Tesis → Evidencia → Contra-argumentos → Síntesis → Preguntas abiertas
- Incluye referencias precisas a papers y fuentes
- Señala niveles de confianza: [ALTO] [MEDIO] [BAJO]
- Ofrece "Research directions" para explorar más allá
```

---

## Hub Notebook — Note Templates

### Nota: Índice del Learning Hub
```markdown
# {TOPIC} — Learning Hub

## Dimensiones de Conocimiento
| # | Dimensión | Fuentes | Status |
|---|-----------|---------|--------|
| D1 | Body of Knowledge | {n} | {status} |
| D2 | State of the Art | {n} | {status} |
| D3 | Capability Model | {n} | {status} |
| D4 | Profession Assessment | {n} | {status} |
| D5 | Maturity Model | {n} | {status} |
| D6 | Working Prompts | {n} | {status} |
| D7 | GenAI Applications | {n} | {status} |

## Niveles de Aprendizaje
| Nivel | Nombre | Artifacts | Status |
|-------|--------|-----------|--------|
| L1 | Cero → Competente | {n} | {status} |
| L2 | Competente → Versado | {n} | {status} |
| L3 | Versado → Experto | {n} | {status} |

## Ruta Recomendada
1. Empieza por L1 — escucha el podcast, haz el quiz
2. Estudia D1 y D2 para fundamentos
3. Usa D6 prompts para practicar
4. Cuando pases el quiz L1, avanza a L2
5. En L2, enfócate en D3 y D4
6. L3 es para cuando puedas enseñar L1
```

### Nota: Auto-Diagnóstico
```markdown
# ¿En qué nivel estoy?

## Indicadores L1 (Competente)
- [ ] Puedo explicar qué es {TOPIC} en 2 minutos
- [ ] Conozco al menos 10 términos clave del dominio
- [ ] Identifico 3+ sub-áreas del campo
- [ ] Nombro 3+ herramientas o frameworks principales
- [ ] Paso el quiz L1 con ≥70%

## Indicadores L2 (Versado)
- [ ] Puedo comparar 2+ enfoques y sus trade-offs
- [ ] He completado un mini-proyecto en el dominio
- [ ] Sigo activamente noticias y tendencias
- [ ] Puedo mentorear a un principiante
- [ ] Paso el quiz L2 con ≥70%

## Indicadores L3 (Experto)
- [ ] Puedo identificar gaps y oportunidades de investigación
- [ ] He publicado o presentado sobre el tema
- [ ] Puedo diseñar soluciones complejas
- [ ] Contribuyo a la comunidad del dominio
- [ ] Paso el quiz L3 con ≥70%
```

---

## Source Labeling Automation

Al importar fuentes de cada deep research, renombrar con prefijo:

```python
# Pseudocode for source labeling
DIMENSION_PREFIXES = {
    "D1": ["[D1-FOUND]", "[D1-HIST]", "[D1-THEORY]", "[D1-REF]"],
    "D2": ["[D2-2026]", "[D2-TREND]", "[D2-LEADER]", "[D2-TOOL]"],
    "D3": ["[D3-SKILL]", "[D3-FRAME]", "[D3-BLOOM]"],
    "D4": ["[D4-ROLE]", "[D4-CERT]", "[D4-SALARY]", "[D4-PATH]"],
    "D5": ["[D5-MODEL]", "[D5-LEVEL]", "[D5-ASSESS]"],
    "D6": ["[D6-PRMT]", "[D6-CHAIN]", "[D6-SYS]"],
    "D7": ["[D7-TOOL]", "[D7-CASE]", "[D7-FUTURE]"],
}

# For each imported source, apply dimension prefix:
# source_rename(notebook_id, source_id, f"[D{n}] {original_title}")
```

El labeling simplificado usa solo el código de dimensión: `[D1]`, `[D2]`, etc.
El labeling detallado usa sub-categoría: `[D1-FOUND]`, `[D2-TREND]`, etc.
