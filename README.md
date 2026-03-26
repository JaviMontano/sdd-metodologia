# SDD — Spec Driven Development

> **by metodolog*IA***

[![Version](https://img.shields.io/badge/version-3.4.0-FFD700?style=flat-square&labelColor=122562)](https://github.com/JaviMontano/sdd-metodologia)
[![License](https://img.shields.io/badge/license-GPL--3.0-137DC5?style=flat-square&labelColor=122562)](LICENSE)
[![Commands](https://img.shields.io/badge/commands-39-FFD700?style=flat-square&labelColor=122562)]()
[![Upstream](https://img.shields.io/badge/upstream-IIC%2Fkit-137DC5?style=flat-square&labelColor=122562)](https://github.com/intent-integrity-chain/kit)

Desarrollo de software dirigido por especificación con verificación BDD criptográfica, inteligencia ambiental y branding Neo-Swiss de MetodologIA. SDD conduce el desarrollo desde principios de gobernanza hasta issues en GitHub — o vitaminiza tu proceso operativo buscando, creando y desplegando habilidades.

---

## Inicio Rápido

```bash
/sdd:tour              # Onboarding guiado (8 pasos interactivos)
/sdd:demo              # Generar proyecto demo + dashboard
/sdd:init              # Inicializar un proyecto real
/sdd:menu              # Paleta de comandos — los 39 comandos
```

## Características

### Pipeline de 9 Fases
Constitución → Especificar → Planificar → Checklist → Testificar → Tareas → Analizar → Implementar → Issues. Las puertas de calidad G1-G3 detienen el avance ante violaciones. Nunca se saltan fases.

### Heartbeat Ambiental
Inteligencia por prompt vía hook `UserPromptSubmit`. Se ejecuta en < 100ms en cada prompt. Detecta artefactos obsoletos, archivos faltantes y regresión de salud — silencioso cuando todo está bien.

### Grafo de Conocimiento
Trazabilidad completa: Principios de Constitución → Requisitos (FR) → Especificaciones de prueba (TS) → Tareas (T). Detecta huérfanos automáticamente. Se renderiza como SVG de fuerza dirigida en el dashboard.

### ALM — Application Lifecycle Manager
ALM visual como micro-frontend: 10 páginas interconectadas que rastrean el pipeline SDD completo para cualquier proyecto. Medidor de salud, tablero de pipeline, mapa de historias, trazabilidad de pruebas, sparklines de insights, explorador de workspace con sesiones por tarea. No es específico de dominio — funciona en cualquier codebase donde SDD esté inicializado.

### Sesiones de Workspace por Tarea
Cada tarea crea una carpeta fechada (`workspace/yyyy-mm-dd-nombre/`) con inputs, archivos RAG, logs y tasklog. El workspace activo enruta automáticamente las capturas RAG y los logs de sesión. Se integra con el dashboard ALM.

### Memoria RAG
Los inputs de sesión se capturan como `rag-memory-of-{slug}.md` con detección automática de tipo MIME, extracción de estructura HTML, resumen + conclusiones clave + contenido completo. Indexado en JSON. Enrutamiento consciente del workspace activo.

### Tour de Onboarding
Recorrido interactivo de 8 pasos: pipeline, dashboard, heartbeat, grafo de conocimiento, comandos. Modales oscuros de glassmorfismo Neo-Swiss.

---

## Pipeline

| Fase | Comando | Alias | Puerta |
|------|---------|-------|--------|
| Init | `/sdd:core` | `/sdd:init` | — |
| 0 | `/sdd:00-constitution` | — | — |
| 1 | `/sdd:01-specify` | `/sdd:spec` | — |
| 2 | `/sdd:02-plan` | `/sdd:plan` | **G1** |
| 3 | `/sdd:03-checklist` | `/sdd:check` | — |
| 4 | `/sdd:04-testify` | `/sdd:test` | — |
| 5 | `/sdd:05-tasks` | `/sdd:tasks` | **G2** |
| 6 | `/sdd:06-analyze` | `/sdd:analyze` | — |
| 7 | `/sdd:07-implement` | `/sdd:impl` | **G3** |
| 8 | `/sdd:08-issues` | `/sdd:issues` | — |

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
├── .claude-plugin/plugin.json     # Manifiesto v3.4.0
├── AGENTS.md (→ CLAUDE.md)        # Orquestador
├── FORK.md                        # Documentación del fork mejorado
├── CONSTITUTION.md                # Gobernanza del framework
├── HEARTBEAT.md                   # Especificación del sentinel (percibir-decidir-actuar)
├── CLARIFICATIONS.md              # Registro de decisiones
├── commands/                      # 39 definiciones de comandos
├── scripts/
│   ├── sdd-heartbeat-lite.sh      # Heartbeat por prompt (< 100ms)
│   ├── sdd-workspace.sh           # Sesiones de workspace por tarea
│   ├── sdd-knowledge-graph.js     # Constructor del grafo de trazabilidad
│   ├── sdd-sentinel.sh            # Ciclo completo del sentinel
│   ├── sdd-insights.js            # Puntuaciones de salud + recomendaciones
│   ├── sdd-seed-demo.sh           # Generador de demo
│   ├── sdd-rag-capture.sh         # Memoria RAG con detección MIME
│   ├── sdd-session-log.sh         # Log de sesión con dual-write
│   ├── sdd-tour.html              # Tour de onboarding
│   ├── generate-dashboard.js      # Generador del dashboard
│   ├── command-center/            # Micro-frontend (10 páginas)
│   └── ...                        # Scripts de utilidad
├── .claude/skills/                # 12 skills IIKit
├── hooks/hooks.json               # 4 eventos de hook
├── references/
│   ├── design-tokens.json         # Tokens de marca Neo-Swiss
│   ├── sequence-diagrams.md       # 7 diagramas Mermaid
│   └── data-schemas.md            # Esquemas JSON
└── landing.html                   # Página de aterrizaje con marca
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

## Marca: Neo-Swiss Dark

| Token | Valor |
|-------|-------|
| Body | `#020617` |
| Navy | `#122562` |
| Gold | `#FFD700` |
| Blue | `#137DC5` (nunca verde) |
| Encabezados | Poppins |
| Cuerpo | Montserrat |
| Código | JetBrains Mono |
| Tarjetas | `blur(16px) saturate(180%)` |

---

## Créditos

- **Co-creadores**: Javier Montaño & Katherin Oquendo
- **Upstream**: [Intent Integrity Chain / Kit](https://github.com/intent-integrity-chain/kit) (MIT)
- **Marca**: MetodologIA (GPL-3.0)
- **Estética**: Neo-Swiss Clean
- **Potenciado por**: Claude Code, Antigravity & Agente Pristino

*Construido con mucho amor.*

*SDD v3.4 · Spec Driven Development · by metodologIA*
