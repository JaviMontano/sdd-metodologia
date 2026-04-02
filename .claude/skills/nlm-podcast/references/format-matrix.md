# Format Matrix — NLM Podcast

> Selection guide: match audience level + intent to NotebookLM audio parameters.

| ID | Audience | Intent | audio_format | audio_length | Rationale |
|------|-------------|---------------|--------------|--------------|-----------|
| PM-01 | Principiante | Intro | deep_dive | default | Conversational depth builds foundational understanding without overwhelming |
| PM-02 | Principiante | Motivación | brief | short | Quick hook to spark curiosity; low commitment entry point |
| PM-03 | Intermedio | Profundización | deep_dive | long | Extended exploration for learners ready to go deeper |
| PM-04 | Intermedio | Comparación | debate | default | Two-host format naturally surfaces pros/cons of alternatives |
| PM-05 | Experto | Frontera | debate | long | Extended debate format for cutting-edge topics with nuance |
| PM-06 | Experto | Síntesis | critique | default | Critical analysis format for synthesizing advanced material |
| PM-07 | Ejecutivo | Decisión | brief | short | Time-efficient format focused on actionable insights |
| PM-08 | Equipo | Alineación | deep_dive | default | Team-oriented deep dive for shared understanding |

## Selection Algorithm

```
1. Identify audience level → {principiante, intermedio, experto, ejecutivo, equipo}
2. Identify intent → {intro, motivación, profundización, comparación, frontera, síntesis, decisión, alineación}
3. Match to PM-XX row
4. Extract audio_format + audio_length
5. Load corresponding focus template from focus-library.md (FP-P-0XX)
6. Load Capa 0 system prompt from templates/system-prompts.md
```

## Override Rules

- User explicitly requests a format → use it regardless of matrix
- Content is < 2 sources → prefer `brief` over `deep_dive`
- Content is highly technical + audience is mixed → fallback to PM-01
- Time constraint mentioned → prefer `short` length
- User says "completo" or "a fondo" → prefer `long` length

## Duration Estimates

| Length | Approximate Duration |
|--------|---------------------|
| short | 3-5 minutes |
| default | 8-12 minutes |
| long | 15-25 minutes |
