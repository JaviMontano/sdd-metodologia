# Contribuir a SDD — Spec Driven Development

Gracias por tu interés en contribuir. Este documento describe el proceso para contribuir al plugin SDD by MetodologIA.

## Prerrequisitos

- Node.js 18+ (para scripts JS y dashboard)
- Bash 3.2+ (para scripts de pipeline)
- Python 3.8+ (para validación de esquemas y session logging)
- Git con acceso a GitHub

## Cómo Contribuir

### 1. Branch Naming

| Prefijo | Uso |
|---------|-----|
| `feature/` | Nueva funcionalidad |
| `bugfix/` | Corrección de errores |
| `docs/` | Solo documentación |
| `refactor/` | Refactorización sin cambio funcional |
| `test/` | Solo tests |

Ejemplo: `feature/add-export-html`, `bugfix/fix-gate-check-race`

### 2. Commits (Conventional Commits)

```
feat: descripción corta del cambio
fix: corrección de bug
docs: cambio en documentación
test: agregar o modificar tests
chore: mantenimiento, dependencias
refactor: cambio de estructura sin cambio funcional
```

Incluir `Co-Authored-By:` si el trabajo fue asistido por IA.

### 3. Antes de Crear un PR

```bash
# Verificación completa del plugin
bash scripts/sdd-verify.sh .

# Verificar integridad de aserciones (si tocaste .feature files)
bash scripts/sdd-assertion-hash.sh verify .

# Verificar marca (colores, fonts, tokens)
bash scripts/verify-brand.sh
```

### 4. Pull Request

- Llenar el template de PR completamente
- Cada PR debe tener al menos una aprobación
- CI debe pasar (sdd-verify + assertion hash + brand check)
- CHANGELOG.md debe tener entrada si hay cambio funcional

## Estructura del Proyecto

```
sdd-metodologia/
├── skills/sdd-*/          # 12 SDD skills (self-contained)
├── commands/              # 43 command definitions
├── scripts/               # 39 scripts (30 SDD + 9 upstream)
├── agents/                # Orchestrator agent
├── references/            # Templates, schemas, design tokens
├── hooks/                 # 4 Claude Code hooks
├── .github/workflows/     # CI pipelines
├── tests/                 # 380+ tests (bats, jest, playwright)
└── evals/                 # 5 evaluation frameworks
```

## Tests Locales

```bash
# Bash tests (requiere bats)
./tests/run-tests.sh

# Dashboard tests (requiere Node.js)
cd tests/dashboard && npx jest

# Verificación rápida
bash scripts/sdd-verify.sh .
```

## Licencia

Al contribuir, aceptas que tu contribución se licencie bajo GPL-3.0 (brand layer) con upstream MIT (IIC/kit core logic).

---

*SDD v3.7 · MetodologIA · Co-creado por Javier Montaño & Katherin Oquendo*
