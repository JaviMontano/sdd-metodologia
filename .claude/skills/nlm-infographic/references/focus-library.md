# NLM Infographic — Focus Prompt Library

> Templates con placeholders. El agente reemplaza en runtime. Total compuesto ≤5000 chars.

---

### FP-I-001: Executive Dashboard
- **Orientación**: landscape | **Estilo**: professional | **Detail**: standard
- **Cuándo**: Resumen ejecutivo, KPIs, métricas

**Template**:
> Crea una infografía tipo dashboard ejecutivo sobre {TOPIC}. Panel izquierdo: 3-5 métricas clave con números grandes. Panel central: visualización principal del concepto o flujo. Panel derecho: top 3 takeaways accionables. Audiencia: {AUDIENCE}. Datos clave: {DATA_POINTS}. Estilo limpio, corporativo, alta legibilidad. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-002: Instagram Story
- **Orientación**: portrait | **Estilo**: editorial | **Detail**: concise
- **Cuándo**: Redes sociales, impacto visual rápido

**Template**:
> Crea una infografía vertical tipo Instagram sobre {TOPIC}. UN solo dato o insight impactante en el centro. Título arriba en bold. Subtítulo explicativo breve. Visual llamativo. Máximo 3 puntos de texto. Audiencia: {AUDIENCE}. Dato principal: {DATA_POINTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-003: Social Media Post
- **Orientación**: square | **Estilo**: bento_grid | **Detail**: concise
- **Cuándo**: LinkedIn, Twitter, carousel

**Template**:
> Crea una infografía cuadrada para redes sociales sobre {TOPIC}. Grid 2x2 con 4 puntos clave, cada celda auto-contenida. Título centrado arriba. Call-to-action abajo. Visual limpio, compartible. Audiencia: {AUDIENCE}. Conceptos: {KEY_CONCEPTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-004: Technical Reference
- **Orientación**: portrait | **Estilo**: scientific | **Detail**: detailed
- **Cuándo**: Documentación técnica, papers, wiki

**Template**:
> Crea una infografía técnica detallada sobre {TOPIC}. Secciones numeradas con diagramas de flujo o componentes. Cada sección: título + explicación + dato. Notación técnica. Referencias a fuentes. Audiencia: {AUDIENCE}. Conceptos técnicos: {KEY_CONCEPTS}. Datos: {DATA_POINTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-005: Tutorial Paso a Paso
- **Orientación**: portrait | **Estilo**: instructional | **Detail**: standard
- **Cuándo**: How-to, onboarding, guías

**Template**:
> Crea una infografía tutorial sobre {TOPIC}. 5-8 pasos secuenciales de arriba a abajo. Cada paso: número + título + descripción breve + icono. Flujo visual claro con flechas entre pasos. Audiencia: {AUDIENCE}. Pasos clave: {KEY_CONCEPTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-006: Brainstorm / Concept Map
- **Orientación**: landscape | **Estilo**: sketch_note | **Detail**: standard
- **Cuándo**: Workshop, lluvia de ideas, mapa conceptual

**Template**:
> Crea una infografía tipo mapa conceptual sobre {TOPIC}. Concepto central grande. Ramas con sub-conceptos interconectados. Estilo handmade/sketch. Relaciones visuales entre ideas. Audiencia: {AUDIENCE}. Conceptos principales: {KEY_CONCEPTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-007: Blog Header / Banner
- **Orientación**: landscape | **Estilo**: editorial | **Detail**: concise
- **Cuándo**: Encabezado de blog, newsletter, banner

**Template**:
> Crea un banner editorial sobre {TOPIC}. Título grande a la izquierda. 1-3 datos clave a la derecha. Visual impactante. Alta legibilidad. Optimizado para ancho de blog (16:9 aprox). Audiencia: {AUDIENCE}. Mensaje principal: {DATA_POINTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-008: Data Comparison
- **Orientación**: landscape | **Estilo**: professional | **Detail**: detailed
- **Cuándo**: Comparación de opciones, benchmarks, rankings

**Template**:
> Crea una infografía comparativa sobre {TOPIC}. Tabla visual con 3-5 elementos comparados. Columnas: Nombre, categoría, fortalezas, debilidades, mejor para. Codificación por color. Audiencia: {AUDIENCE}. Elementos a comparar: {KEY_CONCEPTS}. Datos: {DATA_POINTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-009: Friendly Overview
- **Orientación**: square | **Estilo**: kawaii | **Detail**: standard
- **Cuándo**: Contenido amigable, onboarding, youth

**Template**:
> Crea una infografía amigable y visual sobre {TOPIC}. Iconos grandes y coloridos. Texto mínimo pero informativo. Grid 3x3 con los conceptos principales. Estilo cálido y accesible. Audiencia: {AUDIENCE}. Conceptos: {KEY_CONCEPTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

### FP-I-010: Architecture Diagram
- **Orientación**: landscape | **Estilo**: bento_grid | **Detail**: detailed
- **Cuándo**: Diagrama de arquitectura, componentes, sistemas

**Template**:
> Crea un diagrama de arquitectura visual sobre {TOPIC}. Componentes como bloques modulares. Conexiones con flechas etiquetadas. Flujo de datos/proceso visible. Capas separadas (presentación, lógica, datos). Audiencia: {AUDIENCE}. Componentes: {KEY_CONCEPTS}. Flujos: {DATA_POINTS}. NO incluir: {EXCLUSIONS}. Idioma: {LANGUAGE}.

---

## Meta-Prompt (fallback)

Cuando ningún template encaja:

```
[META-INFOGRAPHIC]
Crea una infografía {orientation} sobre {TOPIC} en estilo {infographic_style}
con nivel de detalle {detail_level}.
Audiencia: {AUDIENCE}. Plataforma: {PLATFORM}.
Conceptos clave: {KEY_CONCEPTS}.
Datos clave: {DATA_POINTS}.
NO incluir: {EXCLUSIONS}.
Idioma: {LANGUAGE}.
```
