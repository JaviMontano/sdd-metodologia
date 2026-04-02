# Meta — NLM Podcast Skill

## Activation Triggers

### Positive Triggers
- "podcast"
- "audio"
- "escuchar"
- "generar podcast"
- "audio overview"
- "/nlm:podcast"
- "crear un podcast sobre"
- "quiero escuchar sobre"
- "hazme un audio"
- "genera audio"
- "podcast educativo"
- "audio explicativo"

### False Positives — DO NOT activate
- "play music" — User wants to play existing music
- "spotify" — Music streaming, not generation
- "reproduce audio" — Playback request, not generation
- "subir audio" — Upload request, not generation
- "grabar audio" — Recording request, not NotebookLM generation
- "audio file" — Generic file reference
- "podcast app" — App reference, not generation request

## Disambiguation Rules

1. If user says "audio" alone, check context for NotebookLM or learning intent
2. If user mentions a topic + "podcast"/"audio", activate
3. If user says "escuchar" + topic, activate (implies wanting to learn by listening)
4. If user references a notebook ID + audio intent, activate immediately
5. If ambiguous, ask: "Quieres que genere un podcast con NotebookLM sobre ese tema?"

## Routing Priority

1. Explicit command `/nlm:podcast` → immediate activation
2. Notebook ID + audio keyword → immediate activation
3. Topic + podcast/audio keyword → activate with topic extraction
4. Ambiguous audio reference → ask for clarification

## Context Requirements

- At minimum: a topic or notebook_id
- Ideal: topic + audience level + desired depth
- Optional: language preference, specific sources, exclusions

## Handoff Protocol

When activated, route to `prompts/primary.md` with extracted context:
- `{TOPIC}`: extracted from user message
- `{AUDIENCE}`: inferred or ask (principiante/intermedio/experto/ejecutivo/equipo)
- `{NOTEBOOK_ID}`: if provided, pass through; else create notebook first
