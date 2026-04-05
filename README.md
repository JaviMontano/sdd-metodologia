<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:122562,100:137DC5&height=220&section=header&text=SDD%20%E2%80%94%20Spec%20Driven%20Development&fontSize=32&fontColor=FFD700&fontAlignY=35&desc=La%20especificaci%C3%B3n%20precede%20al%20c%C3%B3digo&descSize=16&descColor=ffffff&descAlignY=55" width="100%" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/versi%C3%B3n-1.0.0-137DC5?style=for-the-badge" alt="Versión" />
  <img src="https://img.shields.io/badge/licencia-GPL--3.0-blue?style=for-the-badge" alt="Licencia" />
  <img src="https://img.shields.io/badge/plugin-IIKit%20integrado-FFD700?style=for-the-badge&labelColor=1E3258" alt="IIKit" />
  <img src="https://img.shields.io/badge/dashboard-interactivo-BBA0CC?style=for-the-badge&labelColor=1E3258" alt="Dashboard" />
</p>

---

## Descripción

**SDD (Spec Driven Development)** es un plugin de desarrollo dirigido por especificación. Cierra la brecha entre la intención y el código con verificación criptográfica en cada paso. Compatible con Claude Code, OpenAI Codex, Google Gemini y OpenCode.

---

## Instalación

Agrega como plugin de Claude Code:

```json
{
  "mcpServers": {
    "sdd": {
      "command": "claude",
      "args": ["mcp", "serve", "--plugin", "mao-sdd"]
    }
  }
}
```

---

## Características Principales

| Característica | Descripción |
| --- | --- |
| **Pipeline completo** | specify → plan → checklist → test → tasks → analyze → implement |
| **IIKit integrado** | Intent-Integrity Chain para trazabilidad criptográfica |
| **Dashboard interactivo** | Visualización en tiempo real del estado del proyecto |
| **Verificación de integridad** | Cada artefacto firmado y verificable |
| **Multi-plataforma** | Claude Code, OpenAI Codex, Google Gemini, OpenCode |

---

## Pipeline SDD

```
01-specify   ─── Captura de intención y especificación formal
02-plan      ─── Descomposición en plan de implementación
03-checklist ─── Lista de verificación pre-implementación
04-testify   ─── Diseño de tests antes del código
05-tasks     ─── Generación de tareas atómicas
06-analyze   ─── Análisis de impacto y dependencias
07-implement ─── Implementación con trazabilidad completa
```

---

## IIKit — Intent-Integrity Chain

El corazón de SDD es el **IIKit**, que garantiza que cada línea de código se pueda rastrear hasta la intención original del usuario. Cada artefacto generado incluye un hash de integridad que conecta la especificación con la implementación.

---

## Autor

<p align="center">
  <img src="https://github.com/ejemplo-deo-repo/mao-brand-assets/blob/main/team_javier-montano.webp?raw=true" width="120" style="border-radius: 50%;" alt="Javier Montaño" />
</p>

<p align="center">
  <strong>Javier Montaño</strong><br/>
  PreSales Architect · Fundador de MetodologIA · JM Labs<br/>
  <a href="https://github.com/JaviMontano">github.com/JaviMontano</a>
</p>

---

## Parte del Ecosistema MetodologIA / JM Labs

| Repositorio | Descripción |
| --- | --- |
| [mao-discovery-framework](https://github.com/JaviMontano/mao-discovery-framework) | Framework universal de discovery |
| [mao-iic](https://github.com/JaviMontano/mao-iic) | Intent-Integrity Chain (núcleo criptográfico) |
| [mao-pm-apex](https://github.com/JaviMontano/mao-pm-apex) | Gestión de proyectos agéntica |

---

<p align="center">
  Creado por <a href="https://github.com/JaviMontano">Javier Montaño</a> · MetodologIA · GPL-3.0
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:122562,100:137DC5&height=120&section=footer" width="100%" />
</p>
