# SDD — Spec Driven Development

> **by metodolog*IA***

[![Version](https://img.shields.io/badge/version-3.5.0-FFD700?style=flat-square&labelColor=122562)](https://github.com/JaviMontano/sdd-metodologia)
[![License](https://img.shields.io/badge/license-GPL--3.0-137DC5?style=flat-square&labelColor=122562)](LICENSE)
[![Commands](https://img.shields.io/badge/commands-39-FFD700?style=flat-square&labelColor=122562)]()
[![Scripts](https://img.shields.io/badge/scripts-27-137DC5?style=flat-square&labelColor=122562)]()
[![Upstream](https://img.shields.io/badge/upstream-IIC%2Fkit-137DC5?style=flat-square&labelColor=122562)](https://github.com/intent-integrity-chain/kit)

Desarrollo de software dirigido por especificación con puertas de calidad mandatorias, hashing criptográfico de aserciones BDD, validación de esquemas, inteligencia ambiental y estética Neo-Swiss de MetodologIA. SDD conduce el desarrollo desde principios de gobernanza hasta issues en GitHub — o vitaminiza tu proceso operativo buscando, creando y desplegando habilidades.

---

## Inicio Rápido

```bash
/sdd:tour              # Onboarding guiado (8 pasos interactivos)
/sdd:demo              # Generar proyecto demo + dashboard
/sdd:init              # Inicializar un proyecto real
/sdd:menu              # Paleta de comandos — los 39 comandos
```

## Características

### Pipeline de 9 Fases con Puertas Mandatorias
Constitución → Especificar → Planificar → Checklist → Testificar → Tareas → Analizar → Implementar → Issues. Tres puertas de calidad (G1, G2, G3) **detienen el pipeline** ante violaciones — no son advertencias. Cada fase actualiza `context.json` con `completedPhases[]` para prevenir saltos.

### Hashing Criptográfico de Aserciones
SHA-256 sobre bloques de escenarios en archivos `.feature`. Se genera en la Fase 4 (Testificar) y se verifica en la Fase 7 (Implementar). Si un `.feature` se modifica después del hashing, la puerta G3 detecta la manipulación y detiene el pipeline.

### Validación de Esquemas
Esquemas JSON para `context.json`, `session.json` y `gate-results.json`. Validadores de contenido para `spec.md` (patrones FR-NNN), `plan.md` (secciones de modelo de datos y arquitectura), `tasks.md` (identificadores T-NNN y dependencias).

### Heartbeat Ambiental
Inteligencia por prompt vía hook `UserPromptSubmit`. Se ejecuta en < 100ms en cada prompt. Escaneo por `stat` limitado a 50 archivos. Detecta artefactos obsoletos, archivos faltantes y regresión de salud — silencioso cuando todo está bien.

### Grafo de Conocimiento con Detección de Huérfanos
Trazabilidad bidireccional: Principios → Requisitos (FR) → Pruebas (TS) → Tareas (T). Detecta huérfanos en ambas direcciones: requisitos sin pruebas, tareas con FR inexistentes, pruebas con FR rotos. Se renderiza como SVG de fuerza dirigida en el dashboard.

### ALM — Application Lifecycle Manager
ALM visual como micro-frontend: 10 páginas interconectadas que rastrean el pipeline SDD completo. Medidor de salud, tablero de pipeline, mapa de historias, trazabilidad de pruebas, sparklines de insights, explorador de workspace con sesiones por tarea. Funciona en cualquier proyecto donde SDD esté inicializado.

### Sesiones de Workspace por Tarea
Cada tarea crea una carpeta fechada (`workspace/yyyy-mm-dd-nombre/`) con inputs, archivos RAG, logs y tasklog. El workspace activo enruta automáticamente las capturas RAG y los logs de sesión. Escrituras atómicas (patrón `mv`) y concurrencia por `flock`.

### Memoria RAG con Guardas de Seguridad
Los inputs se capturan como `rag-memory-of-{slug}.md` con detección MIME, límite de 10 MB, resolución de symlinks y detección de archivos binarios. Enrutamiento consciente del workspace activo.

---

## Pipeline

| Fase | Comando | Alias | Puerta |
|------|---------|-------|--------|
| Init | `/sdd:core` | `/sdd:init` | — |
| 0 | `/sdd:00-constitution` | — | — |
| 1 | `/sdd:01-specify` | `/sdd:spec` | — |
| 2 | `/sdd:02-plan` | `/sdd:plan` | — |
| 3 | `/sdd:03-checklist` | `/sdd:check` | **G1** |
| 4 | `/sdd:04-testify` | `/sdd:test` | — |
| 5 | `/sdd:05-tasks` | `/sdd:tasks` | — |
| 6 | `/sdd:06-analyze` | `/sdd:analyze` | — |
| 7 | `/sdd:07-implement` | `/sdd:impl` | **G2** |
| 8 | `/sdd:08-issues` | `/sdd:issues` | **G3** |

**Utilidades:** `/sdd:clarify` `/sdd:bugfix` `/sdd:feature` `/sdd:workspace` `/sdd:verify` `/sdd:hooks` `/sdd:sync`
**Inteligencia:** `/sdd:sentinel` `/sdd:insights` `/sdd:graph` `/sdd:qa` `/sdd:dashboard`
**Memoria:** `/sdd:capture` `/sdd:memory`
**Experiencia:** `/sdd:tour` `/sdd:demo` `/sdd:seed` `/sdd:menu`

---

## Instalación

```bash
git clone https://github.com/JaviMontano/sdd-metodologia.git ~/.claude/plugins/sdd-metodologia
```

---

## Arquitectura

```
sdd-metodologia/
├── .claude-plugin/plugin.json     # Manifiesto v3.5.0
├── AGENTS.md (→ CLAUDE.md)        # Orquestador
├── FORK.md                        # Documentación del fork mejorado
├── CONSTITUTION.md                # Gobernanza del framework
├── commands/                      # 39 definiciones de comandos
├── scripts/
│   ├── sdd-gate-check.sh          # Puertas mandatorias G1/G2/G3
│   ├── sdd-phase-complete.sh      # Actualizador de estado del pipeline
│   ├── sdd-validate-artifact.sh   # Validación de esquemas y contenido
│   ├── sdd-assertion-hash.sh      # Hashing SHA-256 de aserciones BDD
│   ├── sdd-heartbeat-lite.sh      # Heartbeat por prompt (< 100ms)
│   ├── sdd-workspace.sh           # Sesiones de workspace por tarea
│   ├── sdd-knowledge-graph.js     # Grafo de trazabilidad bidireccional
│   ├── sdd-sentinel.sh            # Ciclo completo del sentinel
│   ├── sdd-insights.js            # Puntuaciones de salud
│   ├── sdd-rag-capture.sh         # Memoria RAG (10MB, symlink, binario)
│   ├── sdd-session-log.sh         # Log con concurrencia flock
│   ├── command-center/            # Micro-frontend ALM (10 páginas)
│   └── ...                        # 15 scripts adicionales
├── references/
│   ├── design-tokens.json         # Tokens Neo-Swiss v2.0 (paleta + voz)
│   ├── schemas/                   # Esquemas JSON (context, session, gates)
│   └── data-schemas.md            # Esquemas de datos
├── .claude/skills/                # 12 skills IIKit
├── hooks/hooks.json               # 4 eventos de hook
└── landing.html                   # Página de aterrizaje
```

---

## Hooks

| Evento | Script | Propósito |
|--------|--------|-----------|
| `UserPromptSubmit` | `sdd-heartbeat-lite.sh` | Chequeo de salud por prompt |
| `PostToolUse (Write\|Edit)` | `sdd-session-log.sh` | Pista de auditoría + dual-write |
| `SessionStart` | `sdd-heartbeat-lite.sh --init` | Restauración de contexto |
| `PreCompact` | `sdd-session-log.sh` | Instantánea de estado |

---

## Marca: Neo-Swiss Clean and Soft Explainer

| Token | Valor |
|-------|-------|
| Body | `#1F2833` (charcoal) |
| Superficies | `#122562` (navy) |
| Gold | `#FFD700` (acentos, CTAs) |
| Blue | `#137DC5` (nunca verde) |
| Lavender | `#BBA0CC` (texto secundario) |
| Gray | `#808080` (muted, disabled) |
| Titulares | Poppins |
| Cuerpo | Trebuchet MS |
| Notas | Futura |
| Código | JetBrains Mono |
| Tarjetas | Glassmorphism `blur(16px) saturate(180%)` |
| Grid | Swiss 8px |

---

## Créditos

- **Co-creadores**: Javier Montaño & Katherin Oquendo
- **Upstream**: [Intent Integrity Chain / Kit](https://github.com/intent-integrity-chain/kit) (MIT)
- **Marca**: MetodologIA (GPL-3.0)
- **Estética**: Neo-Swiss Clean and Soft Explainer
- **Potenciado por**: Claude Code, Antigravity & Agente Pristino

*Construido con mucho amor.*

*SDD v3.5 · Spec Driven Development · by metodologIA*
