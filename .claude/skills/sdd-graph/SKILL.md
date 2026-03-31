---
name: sdd-graph
description: >-
  This skill should be used when the user asks to "build knowledge graph", "trace requirements",
  "show traceability", "map dependencies between artifacts", "visualize requirement flow",
  or "detect orphan nodes". It builds a knowledge graph tracing Constitution principles
  to requirements, tests, and tasks with edge types (governs, verified_by, implemented_by, validates).
  Use this skill whenever the user mentions knowledge graph, traceability, orphan detection,
  or requirement mapping.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Graph — Knowledge Graph Builder [EXPLICIT]

Build the knowledge graph tracing Constitution principles through requirements, tests, and tasks.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Run Knowledge Graph Builder

```bash
node scripts/sdd-knowledge-graph.js
```

Parses:
- `CONSTITUTION.md` → Principle nodes (P-I, P-II, ...)
- `specs/*/spec.md` → Requirement nodes (FR-NNN)
- `specs/*/tests/features/*.feature` → Test nodes (TS-NNN)
- `specs/*/tasks.md` → Task nodes (T-NNN)

Generates edges:
- `governs`: Principle → Requirement
- `verified_by`: Requirement → Test
- `implemented_by`: Requirement → Task
- `validates`: Test → Requirement

### 2. Detect Orphans

Identify nodes with no incoming or outgoing edges:
- Untested requirements (FR with no `verified_by` edge)
- Untraced principles (P with no `governs` edge)
- Unlinked tasks (T with no `implemented_by` edge)
- Orphan tests (TS with no `validates` edge)

### 3. Output

Writes `.specify/knowledge-graph.json` with nodes and edges arrays.

### 4. Report

```
Knowledge graph built!

Nodes: N principles, N requirements, N tests, N tasks
Edges: N governs, N verified_by, N implemented_by, N validates
Orphans: N detected (list each)

- Dashboard: file://$(pwd)/.specify/dashboard.html (Intelligence view)
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Node.js available | If Node unavailable, ERROR. [EXPLICIT] |
| 2 | CONSTITUTION.md exists for principle nodes | If missing, graph has no governance layer — warn. [EXPLICIT] |
| 3 | Artifacts follow SDD naming conventions | FR-NNN in spec.md, TS-NNN in .feature, T-NNN in tasks.md. [EXPLICIT] |
| 4 | Graph is rebuilt from scratch each run | No incremental updates — full rebuild ensures consistency. [EXPLICIT] |
| 5 | Orphan detection uses edge presence heuristics | A node is orphan if it has zero edges of the expected type. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No CONSTITUTION.md | File not found | Build graph without governance layer, warn about missing principles. [EXPLICIT] |
| Single feature, early stage | Only spec.md exists | Graph has requirements only — all are orphans (no tests/tasks). Report as expected for stage. [EXPLICIT] |
| Circular references | Edge A→B and B→A | Detect and flag as warning — may indicate misclassification. [INFERRED] |
| Very large graph (100+ nodes) | Many features with many artifacts | Performance may degrade — inform user. [INFERRED] |
| Inconsistent IDs | FR-NNN referenced in tasks but not in spec | Flag as broken reference — critical orphan. [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:graph` builds complete traceability
```
Knowledge graph built!

Nodes: 5 principles, 12 requirements, 8 tests, 15 tasks
Edges: 12 governs, 8 verified_by, 15 implemented_by, 8 validates
Orphans: 4 detected
  - FR-009: no test scenario (untested requirement)
  - FR-011: no test scenario (untested requirement)
  - T-022: no spec reference (unlinked task)
  - P-IV: no governed requirements (untraced principle)
```

**Bad**: Traceability without structure
```
x "Requirements are mostly traced" — no specific orphans
x No node/edge counts
x No knowledge-graph.json output
```

**Why**: Knowledge graph must enumerate all nodes/edges, detect specific orphans, and write machine-readable output. [EXPLICIT]

## Validation Gate

Before marking graph build as complete, verify: [EXPLICIT]

- [ ] V1: All artifact types parsed (constitution, spec, tests, tasks)
- [ ] V2: Edge types generated (governs, verified_by, implemented_by, validates)
- [ ] V3: Orphan nodes detected and listed
- [ ] V4: `.specify/knowledge-graph.json` written
- [ ] V5: Node and edge counts reported
- [ ] V6: Dashboard Intelligence view link provided
