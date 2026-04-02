# NLM for Learning — Learning Model (7x3)

> Modelo teórico: 7 Dimensiones de Conocimiento x 3 Niveles de Progresión
> Framework para transformar un tema en un sistema de aprendizaje completo.

---

## El Framework 7x3

```
                    L1: Cero→Competente   L2: Competente→Versado   L3: Versado→Experto
                    ─────────────────     ──────────────────────   ───────────────────
D1: Body of Knowledge   Fundamentos           Profundización           Especialización
D2: State of the Art    Panorama              Tendencias               Frontera
D3: Capability Model    Skills básicos        Skills avanzados         Mastery
D4: Profession Assess.  Exploración           Posicionamiento          Liderazgo
D5: Maturity Model      Auto-diagnóstico      Plan de desarrollo       Mentoría
D6: Working Prompts     Prompts de aprendizaje Prompts de producción   Prompts de innovación
D7: GenAI Applications  Primeros usos         Integración              Arquitectura
```

---

## Nivel L1: Cero a Competente

**Meta**: Entender el territorio, construir vocabulario, tener contexto.
**Duración estimada**: 2-4 semanas de estudio dedicado.
**Resultado**: Puede participar en conversaciones, entiende artículos, identifica sub-áreas.

### Ruta de estudio L1:
1. **D1-L1**: Leer resumen del BoK — conceptos core, historia, glosario
2. **D2-L1**: Panorama general del estado actual — quiénes son los líderes, qué herramientas existen
3. **D4-L1**: Explorar roles y carreras — entender el ecosistema profesional
4. **D5-L1**: Auto-diagnóstico — "¿dónde estoy hoy?"
5. **D3-L1**: Identificar las 10 capabilities más fundamentales
6. **D6-L1**: Usar prompts de aprendizaje para profundizar en D1-D5
7. **D7-L1**: Probar 3 herramientas de IA aplicadas al tema

### Artifacts L1:
- Audio overview (podcast introductorio)
- Flashcards de vocabulario esencial (50+ términos)
- Quiz de auto-evaluación nivel básico
- Mind map del dominio

### Configuración del asistente L1:
```
SYSTEM PROMPT:
Eres un tutor paciente y claro especializado en {TOPIC}.
Tu estudiante es un principiante absoluto — NUNCA asumas conocimiento previo.
- Explica cada concepto con analogías simples y ejemplos cotidianos
- Define CADA término técnico la primera vez que lo uses
- Responde siempre citando las fuentes del notebook
- Al final de cada respuesta, sugiere: "Para profundizar, podrías preguntar sobre..."
- Si el estudiante pregunta algo fuera del notebook, dilo honestamente
- Usa formato estructurado: definición → ejemplo → por qué importa
```

---

## Nivel L2: Competente a Versado

**Meta**: Aplicar conocimiento, conectar conceptos, producir trabajo de calidad.
**Duración estimada**: 1-3 meses de práctica deliberada.
**Resultado**: Puede ejecutar tareas del dominio, tomar decisiones informadas, mentorear L1.

### Ruta de estudio L2:
1. **D1-L2**: Profundizar en 2-3 sub-áreas de mayor interés
2. **D3-L2**: Desarrollar capabilities intermedias — hands-on projects
3. **D2-L2**: Seguir tendencias activamente — newsletters, conferencias, papers
4. **D6-L2**: Usar prompts de producción para generar trabajo real
5. **D7-L2**: Integrar IA en flujo de trabajo diario del dominio
6. **D5-L2**: Plan de desarrollo personal — gaps y siguientes pasos
7. **D4-L2**: Posicionamiento profesional — portfolio, certificaciones

### Artifacts L2:
- Audio overview (deep dive en áreas clave)
- Report tipo Study Guide con ejercicios prácticos
- Data table de herramientas y frameworks comparados
- Slide deck de conocimiento intermedio

### Configuración del asistente L2:
```
SYSTEM PROMPT:
Eres un mentor experimentado en {TOPIC}.
Tu estudiante tiene fundamentos sólidos — NO necesita definiciones básicas.
- Responde con profundidad técnica y matices
- Compara enfoques y señala trade-offs
- Desafía suposiciones con preguntas socráticas
- Conecta conceptos entre sub-áreas
- Sugiere ejercicios prácticos y proyectos
- Cita fuentes del notebook y distingue entre hechos y opiniones
- Cuando haya debate abierto, presenta AMBOS lados
- Formato: análisis → implicaciones → recomendación → ejercicio
```

---

## Nivel L3: Versado a Experto

**Meta**: Crear conocimiento nuevo, liderar, innovar, enseñar.
**Duración estimada**: 6-18 meses de contribución activa.
**Resultado**: Puede innovar, publicar, liderar equipos, definir estrategia.

### Ruta de estudio L3:
1. **D2-L3**: Trabajar en la frontera — papers recientes, problemas abiertos
2. **D3-L3**: Mastery — capabilities de nivel experto, T-shaped depth
3. **D1-L3**: Contribuir al BoK — escribir, publicar, enseñar
4. **D6-L3**: Prompts de innovación — generar ideas originales con IA
5. **D7-L3**: Arquitecturar soluciones de IA para el dominio
6. **D5-L3**: Mentorear — ayudar a otros a progresar
7. **D4-L3**: Liderazgo — conferencias, publicaciones, comunidad

### Artifacts L3:
- Audio overview formato debate (puntos de vista encontrados)
- Report tipo Briefing Doc con análisis original
- Mind map de la frontera del conocimiento
- Infographic de la visión de futuro del dominio

### Configuración del asistente L3:
```
SYSTEM PROMPT:
Eres un colega investigador experto en {TOPIC}.
Tu interlocutor es un profesional avanzado — trata como par intelectual.
- Discute a nivel de estado del arte y frontera
- Cuestiona premisas y señala gaps en la literatura
- Propón hipótesis y líneas de investigación
- Conecta con disciplinas adyacentes
- Distingue entre consenso establecido, evidencia emergente y especulación
- Cita papers y fuentes específicas del notebook
- Si no tienes evidencia suficiente, dilo explícitamente
- Formato: tesis → evidencia → contra-argumentos → síntesis → preguntas abiertas
```

---

## Notebook Architecture

### Estructura completa (11 notebooks):

```
{TOPIC} — Learning Hub                    ← Notebook maestro (índice + notas de progreso)
├── {TOPIC} — D1: Body of Knowledge       ← Deep research D1
├── {TOPIC} — D2: State of the Art        ← Deep research D2
├── {TOPIC} — D3: Capability Model        ← Deep research D3
├── {TOPIC} — D4: Profession Assessment   ← Deep research D4
├── {TOPIC} — D5: Maturity Model          ← Deep research D5
├── {TOPIC} — D6: Working Prompts         ← Deep research D6
├── {TOPIC} — D7: GenAI Applications      ← Deep research D7
├── {TOPIC} — L1: Cero a Competente       ← Asistente nivel 1
├── {TOPIC} — L2: Competente a Versado    ← Asistente nivel 2
└── {TOPIC} — L3: Versado a Experto       ← Asistente nivel 3
```

### Notebooks de Nivel (L1, L2, L3):
- Reciben como fuentes las **notas resumen** de los 7 notebooks dimensionales
- Configurados con `chat_configure` usando el system prompt del nivel
- Generan artifacts específicos del nivel
- Funcionan como **asistentes de enseñanza** personalizados

### Notebook Hub:
- Contiene notas-índice con links a cada notebook
- Nota de auto-diagnóstico (¿en qué nivel estoy?)
- Nota de plan de estudio personalizado
- Nota de progreso y logros

---

## Source Labeling Convention

> **Canonical reference**: See `references/naming-conventions.md` for the full labeling spec.

Two modes:
- **Simple** (default, standard pipeline): `[D{N}] Título` — e.g., `[D1] What is BMAD Method`
- **Detailed** (deep mode): `[D{N}-SUB] Título` — e.g., `[D1-FOUND] Origin of BMAD`, `[D2-TREND] AI-Driven Development 2026`

Sub-categories are documented in `naming-conventions.md`. Default is simple labeling unless deep mode is active.

---

## Quality Gates

> **Canonical definitions**: See `agents/guardian.md` for full gate logic with tiered thresholds.

| Gate | Phase | Criterio | Threshold |
|------|-------|----------|-----------|
| G1 | After Phase 1 | All 7 researches launched | 7/7 task_ids non-null |
| G2 | After Phase 2 | Per-dimension source yield | ≥15 PASS, 10-14 CONCERNS, <10 LOW_YIELD, 0 FAIL |
| G3 | After Phase 2 | Total sources across 7 dimensions | ≥100 (warn if 70-99) |
| G4 | After Phase 3 | Tutor configuration | 3/3 levels with custom system prompt |
| G5 | After Phase 4 | Artifacts per level | L1≥3, L2≥4, L3≥4 (minimum) |
| G6 | After Phase 5 | Hub completeness | Index + Diagnosis + Study Path notes |
