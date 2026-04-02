# SDD QA Strategy

> Estrategia de aseguramiento de calidad para el plugin SDD by MetodologIA.

## Resumen

| Tier | Cuándo | Qué Valida |
|------|--------|-----------|
| **1. Pre-Commit** | Cada commit local | Assertion hashes, shellcheck |
| **2. PR Gate** | Cada Pull Request | sdd-verify, schemas, brand, linting |
| **3. Release** | Push a main + version bump | E2E completo, tile publish, regression |
| **4. Nightly** | 4 AM UTC diario | 6 escenarios E2E, fresh install |

## Tier 1: Pre-Commit (Local)

- **Git hooks** (`/sdd:hooks`): pre-commit verifica assertion hashes de .feature files
- **sdd-verify**: verificación rápida del plugin (8 categorías)
- **verify-brand**: validación de paleta Neo-Swiss (6 colores, 4 fonts)

## Tier 2: PR Gate (CI)

**Workflow**: `.github/workflows/pr-gate.yml`

| Check | Script | Bloqueante |
|-------|--------|-----------|
| Plugin integrity | `sdd-verify.sh` | Sí |
| Assertion hashes | `sdd-assertion-hash.sh verify` | Sí |
| Schema validation | `sdd-validate-artifact.sh context` | Sí |
| Brand compliance | `verify-brand.sh` | Sí |

## Tier 3: Release (CI)

**Workflow**: `.github/workflows/ci.yml`

| Suite | Tests | Framework |
|-------|-------|-----------|
| Bash unit | ~380 tests en 24 archivos | BATS |
| Dashboard unit | 10 suites | Jest |
| Visual regression | 32 snapshots (Darwin + Linux) | Playwright |
| DOM structure | 16 snapshots | Playwright |
| Console errors | Sin errores JS | Playwright |
| PowerShell parity | Windows equivalents | Pester |
| Tile lint | Manifest válido | Tessl CLI |
| Skill review | Score >= 85% | Tessl API |

## Tier 4: Nightly E2E

**Workflow**: `.github/workflows/e2e-nightly.yml` (4 AM UTC)

6 escenarios:
1. Fresh install + inicialización
2. Hash integrity chain (SHA-256 .feature)
3. Dashboard generation (HTML válido)
4. Verification scripts (verify-steps, setup-bdd, verify-step-quality)
5. Pre-commit hook integrity (bloquea .feature tampered)
6. Premise validation schema

## Quality Gates (Runtime)

| Gate | Fase | Criterio |
|------|------|----------|
| **G1** | Phase 03 (Checklist) | Plan completo + FR→plan alignment |
| **G2** | Phase 07 (Implement) | Zero HIGH findings + analysis completo |
| **G3** | Phase 08 (Issues) | Tests pasan + assertion hashes verificados |

## Evaluaciones (Agent Quality)

5 frameworks en `evals/`:
1. Specification (WHAT not HOW) — 10 criterios, max 100 pts
2. Constitution/Governance — completitud de gobernanza
3. Gherkin/BDD Feature Files — sintaxis y estructura
4. Bug Reporting & Fix Tasks — defect tracking
5. Task Format & Traceability — T-NNN + dependencias

## Métricas

| Métrica | Target | Medición |
|---------|--------|----------|
| Tests totales | >380 | `bats + jest + playwright` |
| Coverage | >80% | `jest --coverage` |
| Gate pass rate | >70% first-pass | `gate-results.json` |
| Assertion integrity | 100% | `sdd-assertion-hash.sh verify` |
| Brand compliance | 100% | `verify-brand.sh` |
| Heartbeat perf | <100ms | `time sdd-heartbeat-lite.sh` |
| Concurrent writes | 10/10 | `fcntl.flock session-log` |

---

*SDD v3.7 · MetodologIA*
