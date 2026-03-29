/* SDD ALM Data — Generated 2026-03-29T12:20:29.498Z */
window.DASHBOARD_DATA = {
  "isDemo": false,
  "isEmpty": {
    "features": false,
    "constitution": false,
    "workspace": false,
    "tests": true,
    "tasks": false,
    "logs": false,
    "graph": false,
    "backlog": true
  },
  "generatedAt": "2026-03-29T12:20:29.498Z",
  "project": {
    "name": "sdd-metodologia"
  },
  "premise": null,
  "insights": {
    "healthScore": 98,
    "scoreHistory": []
  },
  "features": [
    {
      "id": "031-bdd-verification-chain",
      "name": "bdd verification chain",
      "phase": "organize-plan",
      "spec": true,
      "plan": true,
      "tasks": true,
      "tests": true,
      "checklist": false,
      "analysis": true,
      "frCount": 17,
      "usCount": 0,
      "scCount": 7,
      "testCount": 0,
      "totalTasks": 54,
      "completedTasks": 53,
      "progress": 98,
      "status": "in_progress",
      "taskItems": [
        {
          "id": "T-1",
          "title": "T001 Modify extract_assertions() in .claude/skills/iikit-core/scripts/bash/testify-tdd.sh to extract Given/When/Then/And/But lines from .feature files instead of **Given**:/**When**:/**Then**: from test-specs.md. Accept both directory path (tests/features/) and single file path. Sort files by name, strip leading whitespace, collapse internal whitespace. [TS-039]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-2",
          "title": "T002 Modify compute_assertion_hash() in .claude/skills/iikit-core/scripts/bash/testify-tdd.sh to handle directory input (glob *.feature, sort, concatenate extracted lines, SHA-256). Return NO_ASSERTIONS if no step lines found. [TS-040]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-3",
          "title": "T003 Modify store_assertion_hash() in .claude/skills/iikit-core/scripts/bash/testify-tdd.sh to store features_dir and file_count in context.json testify object (replacing test_specs_file). [TS-042, TS-043]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-4",
          "title": "T004 Modify derive_context_path() in .claude/skills/iikit-core/scripts/bash/testify-tdd.sh to support features directory path derivation (tests/features/ → context.json two levels up). [TS-042]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-5",
          "title": "T005 Modify comprehensive_integrity_check() in .claude/skills/iikit-core/scripts/bash/testify-tdd.sh to work with .feature directory input instead of single test-specs.md file. [TS-006]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-6",
          "title": "T006 Update BATS tests in tests/bash/testify-tdd.bats for all modified functions — add .feature file fixtures, directory-based hash tests, whitespace normalization tests. [TS-006, TS-008, TS-009]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-7",
          "title": "T007 [P] Modify extract_assertions() in .claude/skills/iikit-core/scripts/powershell/testify-tdd.ps1 — identical behavior to bash T001. [TS-039, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-8",
          "title": "T008 [P] Modify compute_assertion_hash() in .claude/skills/iikit-core/scripts/powershell/testify-tdd.ps1 — identical behavior to bash T002. [TS-040, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-9",
          "title": "T009 [P] Modify store_assertion_hash() in .claude/skills/iikit-core/scripts/powershell/testify-tdd.ps1 — identical behavior to bash T003. [TS-042, TS-043, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-10",
          "title": "T010 [P] Modify derive_context_path() and comprehensive check in .claude/skills/iikit-core/scripts/powershell/testify-tdd.ps1 — identical behavior to bash T004/T005. [TS-006, TS-042, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-11",
          "title": "T011 [US1] Rewrite the test specification generation section of .claude/skills/iikit-05-testify/SKILL.md to instruct the agent to generate standard Gherkin .feature files in FEATURE_DIR/tests/features/ instead of tests/test-specs.md. Include Gherkin tag conventions (@TS-XXX, @FR-XXX, @US-XXX, @P1-3, @acceptance/@contract/@validation). [TS-001, TS-002]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-12",
          "title": "T012 [US1] Add Gherkin advanced construct guidance to .claude/skills/iikit-05-testify/SKILL.md: Background (3+ shared Given), Scenario Outline + Examples (data-only variance), Rule (business rule grouping). [TS-003, TS-004, TS-005]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-13",
          "title": "T013 [US1] Update hash storage commands in .claude/skills/iikit-05-testify/SKILL.md to use directory path (FEATURE_DIR/tests/features) instead of file path (tests/test-specs.md). Update both bash and PowerShell command examples. [TS-006]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-14",
          "title": "T014 [US1] Remove all references to test-specs.md output format from .claude/skills/iikit-05-testify/SKILL.md. Update DO NOT MODIFY markers for .feature file context. [TS-045]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-15",
          "title": "T015 [US1] Add .feature file syntax error handling guidance to .claude/skills/iikit-05-testify/SKILL.md — agent must validate generated Gherkin syntax. [TS-041]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-16",
          "title": "T016 [US2] Modify pre-commit-hook.sh in .claude/skills/iikit-core/scripts/bash/pre-commit-hook.sh to detect staged .feature files (grep for tests/features/.*\\.feature$) instead of test-specs.md. Update fast path exit condition. [TS-007]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-17",
          "title": "T017 [US2] Modify staged file extraction in pre-commit-hook.sh to handle multiple .feature files — extract each staged .feature to temp, compute combined hash, compare against stored hash. [TS-009]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-18",
          "title": "T018 [US2] Modify context.json reading strategy in pre-commit-hook.sh for new testify object format (features_dir, file_count instead of test_specs_file). [TS-042]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-19",
          "title": "T019 [US2] Modify git notes search in pre-commit-hook.sh to match .feature directory paths in note entries. [TS-007]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-20",
          "title": "T020 [US2] Modify post-commit-hook.sh in .claude/skills/iikit-core/scripts/bash/post-commit-hook.sh to detect committed .feature files and store combined hash as git note. Update note entry format for directory-based paths. [TS-006]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-21",
          "title": "T021 [US2] Update BATS tests in tests/bash/pre-commit-hook.bats — add .feature file staging fixtures, multi-file hash tests, whitespace change tests. [TS-007, TS-008]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-22",
          "title": "T022 [P] [US2] Modify pre-commit-hook.ps1 in .claude/skills/iikit-core/scripts/powershell/pre-commit-hook.ps1 — identical behavior to bash T016-T019. [TS-007, TS-009, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-23",
          "title": "T023 [P] [US2] Modify post-commit-hook.ps1 in .claude/skills/iikit-core/scripts/powershell/post-commit-hook.ps1 — identical behavior to bash T020. [TS-006, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-24",
          "title": "T024 [US3] Create verify-steps.sh in .claude/skills/iikit-core/scripts/bash/verify-steps.sh with framework detection (parse plan.md for tech stack keywords, fallback to file extension heuristics). Implement lookup table per plan D4. [TS-010, TS-011, TS-012, TS-013]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-25",
          "title": "T025 [US3] Implement dry-run execution in verify-steps.sh — invoke framework-specific dry-run command, parse output for undefined/pending steps, produce JSON output per contracts/script-outputs.md. [TS-032, TS-033]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-26",
          "title": "T026 [US3] Implement DEGRADED mode in verify-steps.sh — when no framework detected, return status DEGRADED with warning message. [TS-034]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-27",
          "title": "T027 [US3] Create BATS tests in tests/bash/verify-steps.bats — test framework detection, PASS/BLOCKED/DEGRADED responses, JSON output schema validation. [TS-032, TS-033, TS-034, TS-047]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-28",
          "title": "T028 [P] [US3] Create verify-steps.ps1 in .claude/skills/iikit-core/scripts/powershell/verify-steps.ps1 — identical behavior to bash T024-T026. [TS-010, TS-011, TS-012, TS-013, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-29",
          "title": "T029 [US4] Create verify-step-quality.sh in .claude/skills/iikit-core/scripts/bash/verify-step-quality.sh with language detection and AST parser selection per plan D5. [TS-014, TS-015, TS-016, TS-017, TS-018]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-30",
          "title": "T030 [US4] Implement Python AST analysis in verify-step-quality.sh — use python3 -c with ast module to parse step files, extract Then/When/Given function bodies, check for empty bodies, tautologies, and missing assertions. [TS-019]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-31",
          "title": "T031 [US4] Implement JavaScript/TypeScript analysis in verify-step-quality.sh — use node -e for basic AST parsing of step files, same quality checks as Python. [TS-019]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-32",
          "title": "T032 [US4] Implement Go analysis in verify-step-quality.sh — use go/ast via embedded Go script for step file parsing. [TS-019]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-33",
          "title": "T033 [US4] Implement regex fallback in verify-step-quality.sh for unsupported languages (Java, Rust, C#) — flag as DEGRADED_ANALYSIS in output. [TS-035, TS-036]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-34",
          "title": "T034 [US4] Create BATS tests in tests/bash/verify-step-quality.bats — test each language parser, PASS/BLOCKED responses, DEGRADED_ANALYSIS mode, JSON output validation. [TS-014, TS-015, TS-016, TS-035, TS-036, TS-047]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-35",
          "title": "T035 [P] [US4] Create verify-step-quality.ps1 in .claude/skills/iikit-core/scripts/powershell/verify-step-quality.ps1 — identical behavior to bash T029-T033. [TS-014, TS-015, TS-016, TS-017, TS-018, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-36",
          "title": "T036 [US5] Create setup-bdd.sh in .claude/skills/iikit-core/scripts/bash/setup-bdd.sh with framework detection from plan.md, directory creation (tests/features/, tests/step_definitions/), and framework installation per plan D6. [TS-020, TS-021]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-37",
          "title": "T037 [US5] Implement idempotency in setup-bdd.sh — detect existing scaffolding, return ALREADY_SCAFFOLDED. [TS-038]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-38",
          "title": "T038 [US5] Implement NO_FRAMEWORK fallback in setup-bdd.sh — create directory structure without installing framework, return warning. [TS-022, TS-037]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-39",
          "title": "T039 [US5] Create BATS tests in tests/bash/setup-bdd.bats — test framework detection, scaffolding, idempotency, NO_FRAMEWORK mode. [TS-020, TS-021, TS-037, TS-038, TS-047]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-40",
          "title": "T040 [P] [US5] Create setup-bdd.ps1 in .claude/skills/iikit-core/scripts/powershell/setup-bdd.ps1 — identical behavior to bash T036-T038. [TS-020, TS-021, TS-046]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-41",
          "title": "T041 [US6] Update TDD Support Check section in .claude/skills/iikit-08-implement/SKILL.md to call testify-tdd.sh comprehensive-check with .feature directory path instead of test-specs.md file path. Update both bash and PowerShell command examples. [TS-023]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-42",
          "title": "T042 [US6] Update Test Execution Enforcement section in .claude/skills/iikit-08-implement/SKILL.md to add BDD verification chain: write step definitions → verify-steps.sh (must PASS) → run tests (expect RED) → write production code → run tests (expect GREEN) → verify-step-quality.sh (must PASS). [TS-024, TS-025, TS-026, TS-027]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-43",
          "title": "T043 [US6] Add .feature file immutability rule to .claude/skills/iikit-08-implement/SKILL.md — agent MUST NOT modify .feature files during implementation, only step definitions and production code. [TS-028]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-44",
          "title": "T044 [US6] Add task completion gate to .claude/skills/iikit-08-implement/SKILL.md — task not marked complete until verify-steps.sh and verify-step-quality.sh both return PASS. [TS-044]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-45",
          "title": "T045 [US7] Add .feature file tag extraction to coverage detection in .claude/skills/iikit-07-analyze/SKILL.md — parse @FR-XXX, @US-XXX, @TS-XXX tags from all .feature files in tests/features/. [TS-029]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-46",
          "title": "T046 [US7] Add untested requirement detection to .claude/skills/iikit-07-analyze/SKILL.md — flag FR-XXX from spec.md that have no corresponding @FR-XXX tag in any .feature file. [TS-030]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-47",
          "title": "T047 [US7] Add orphaned tag detection to .claude/skills/iikit-07-analyze/SKILL.md — flag @FR-XXX tags in .feature files that reference IDs not present in spec.md. [TS-029]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-48",
          "title": "T048 [US7] Add optional step definition existence check to .claude/skills/iikit-07-analyze/SKILL.md — run verify-steps.sh as part of analysis when .feature files and step definitions exist. [TS-031]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-49",
          "title": "T049 [P] Remove all references to test-specs.md format from .claude/skills/iikit-05-testify/SKILL.md, .claude/skills/iikit-08-implement/SKILL.md, and .claude/skills/iikit-07-analyze/SKILL.md (ensure no residual old-format references). [TS-045]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-50",
          "title": "T050 [P] Update testspec-template.md in .claude/skills/iikit-core/templates/testspec-template.md — either remove (replaced by .feature files) or update to reflect new format. [TS-045]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-51",
          "title": "T051 [P] Modify verify-test-execution.sh in .claude/skills/iikit-core/scripts/bash/verify-test-execution.sh to recognize BDD framework test output (.feature execution logs) in addition to existing test runner output. Update PowerShell equivalent verify-test-execution.ps1. [TS-025, TS-026]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-52",
          "title": "T052 [P] Create Pester tests for verify-steps.ps1, verify-step-quality.ps1, and setup-bdd.ps1 — equivalent coverage to BATS tests T027, T034, T039. [TS-046, TS-047, Constitution III]",
          "status": "done",
          "frRef": null
        },
        {
          "id": "T-53",
          "title": "T053 Run quickstart.md validation scenarios end-to-end to verify all scripts work together. [TS-006, TS-007, TS-032, TS-035]",
          "status": "done",
          "frRef": null
        }
      ]
    }
  ],
  "constitution": {
    "principles": [
      {
        "number": "I",
        "name": "Skills-First",
        "level": "MUST"
      },
      {
        "number": "II",
        "name": "Multi-Agent Compatibility",
        "level": "MUST"
      },
      {
        "number": "III",
        "name": "Cross-Platform Parity",
        "level": "MUST"
      },
      {
        "number": "IV",
        "name": "Phase Separation (NON-NEGOTIABLE)",
        "level": "MUST"
      },
      {
        "number": "V",
        "name": "Self-Validating Skills",
        "level": "MUST"
      }
    ]
  },
  "governance": {
    "principles": {
      "length": 5
    },
    "operationalLogs": {
      "tasklog": {
        "exists": false,
        "entries": 0
      },
      "changelog": {
        "exists": true,
        "entries": 79
      },
      "decisionLog": {
        "exists": false,
        "entries": 0
      }
    }
  },
  "quality": {
    "passRate": 100,
    "totalTests": 0,
    "totalFR": 17
  },
  "workspace": {
    "tree": [
      {
        "name": "specs",
        "path": "specs",
        "type": "dir",
        "children": [
          {
            "name": "031-bdd-verification-chain",
            "path": "specs/031-bdd-verification-chain",
            "type": "dir",
            "children": [
              {
                "name": "analysis.md",
                "path": "specs/031-bdd-verification-chain/analysis.md",
                "type": "file",
                "size": 4791,
                "mtime": "2026-03-22T19:22:28.482Z"
              },
              {
                "name": "checklists",
                "path": "specs/031-bdd-verification-chain/checklists",
                "type": "dir",
                "children": [
                  {
                    "name": "design-quality.md",
                    "path": "specs/031-bdd-verification-chain/checklists/design-quality.md",
                    "type": "file",
                    "size": 8495,
                    "mtime": "2026-03-22T19:22:28.482Z"
                  },
                  {
                    "name": "requirements.md",
                    "path": "specs/031-bdd-verification-chain/checklists/requirements.md",
                    "type": "file",
                    "size": 2006,
                    "mtime": "2026-03-22T19:22:28.483Z"
                  }
                ]
              },
              {
                "name": "context.json",
                "path": "specs/031-bdd-verification-chain/context.json",
                "type": "file",
                "size": 263,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "contracts",
                "path": "specs/031-bdd-verification-chain/contracts",
                "type": "dir",
                "children": [
                  {
                    "name": "script-outputs.md",
                    "path": "specs/031-bdd-verification-chain/contracts/script-outputs.md",
                    "type": "file",
                    "size": 3761,
                    "mtime": "2026-03-22T19:22:28.483Z"
                  }
                ]
              },
              {
                "name": "data-model.md",
                "path": "specs/031-bdd-verification-chain/data-model.md",
                "type": "file",
                "size": 3166,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "plan.md",
                "path": "specs/031-bdd-verification-chain/plan.md",
                "type": "file",
                "size": 14652,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "quickstart.md",
                "path": "specs/031-bdd-verification-chain/quickstart.md",
                "type": "file",
                "size": 2250,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "research.md",
                "path": "specs/031-bdd-verification-chain/research.md",
                "type": "file",
                "size": 4770,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "spec.md",
                "path": "specs/031-bdd-verification-chain/spec.md",
                "type": "file",
                "size": 14175,
                "mtime": "2026-03-22T19:22:28.483Z"
              },
              {
                "name": "tasks.md",
                "path": "specs/031-bdd-verification-chain/tasks.md",
                "type": "file",
                "size": 15586,
                "mtime": "2026-03-22T19:22:28.484Z"
              },
              {
                "name": "tests",
                "path": "specs/031-bdd-verification-chain/tests",
                "type": "dir",
                "children": [
                  {
                    "name": "test-specs.md",
                    "path": "specs/031-bdd-verification-chain/tests/test-specs.md",
                    "type": "file",
                    "size": 18799,
                    "mtime": "2026-03-22T19:22:28.484Z"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "name": ".specify",
        "path": ".specify",
        "type": "dir",
        "children": [
          {
            "name": "context.json",
            "path": ".specify/context.json",
            "type": "file",
            "size": 3,
            "mtime": "2026-03-25T19:37:04.645Z"
          },
          {
            "name": "dashboard.pid.json",
            "path": ".specify/dashboard.pid.json",
            "type": "file",
            "size": 123,
            "mtime": "2026-03-22T19:22:28.479Z"
          },
          {
            "name": "gate-results.json",
            "path": ".specify/gate-results.json",
            "type": "file",
            "size": 386,
            "mtime": "2026-03-29T12:15:25.153Z"
          },
          {
            "name": "knowledge-graph.json",
            "path": ".specify/knowledge-graph.json",
            "type": "file",
            "size": 29225,
            "mtime": "2026-03-29T12:18:44.087Z"
          },
          {
            "name": "score-history.json",
            "path": ".specify/score-history.json",
            "type": "file",
            "size": 242,
            "mtime": "2026-03-22T19:22:28.479Z"
          },
          {
            "name": "sentinel-state.json",
            "path": ".specify/sentinel-state.json",
            "type": "file",
            "size": 170,
            "mtime": "2026-03-25T19:14:12.007Z"
          },
          {
            "name": "session-log.json",
            "path": ".specify/session-log.json",
            "type": "file",
            "size": 9205,
            "mtime": "2026-03-26T02:07:11.462Z"
          },
          {
            "name": "shared",
            "path": ".specify/shared",
            "type": "dir",
            "children": [
              {
                "name": "data.js",
                "path": ".specify/shared/data.js",
                "type": "file",
                "size": 33243,
                "mtime": "2026-03-25T20:01:07.017Z"
              }
            ]
          }
        ]
      },
      {
        "name": "CONSTITUTION.md",
        "path": "CONSTITUTION.md",
        "type": "file",
        "size": 11151,
        "mtime": "2026-03-24T13:32:24.245Z"
      },
      {
        "name": "changelog.md",
        "path": "changelog.md",
        "type": "file",
        "size": 14534,
        "mtime": "2026-03-22T19:22:28.480Z"
      }
    ],
    "ragMemories": [],
    "sessions": [],
    "activeSession": null,
    "fileCount": 29
  },
  "knowledgeGraph": {
    "nodes": 85,
    "edges": 0,
    "orphans": {
      "untested_requirements": [
        "FR-001",
        "FR-002",
        "FR-003",
        "FR-004",
        "FR-005",
        "FR-006",
        "FR-007",
        "FR-008",
        "FR-009",
        "FR-010",
        "FR-011",
        "FR-012",
        "FR-013",
        "FR-014",
        "FR-015",
        "FR-016",
        "FR-017"
      ],
      "untraced_principles": [
        "P-I",
        "P-II",
        "P-III",
        "P-IV",
        "P-V",
        "P-VI",
        "P-VII",
        "P-VIII"
      ],
      "unlinked_tasks": [
        "T-auto-031-bdd-verification-chain-1",
        "T-auto-031-bdd-verification-chain-2",
        "T-auto-031-bdd-verification-chain-3",
        "T-auto-031-bdd-verification-chain-4",
        "T-auto-031-bdd-verification-chain-5",
        "T-auto-031-bdd-verification-chain-6",
        "T-auto-031-bdd-verification-chain-7",
        "T-auto-031-bdd-verification-chain-8",
        "T-auto-031-bdd-verification-chain-9",
        "T-auto-031-bdd-verification-chain-10",
        "T-auto-031-bdd-verification-chain-11",
        "T-auto-031-bdd-verification-chain-12",
        "T-auto-031-bdd-verification-chain-13",
        "T-auto-031-bdd-verification-chain-14",
        "T-auto-031-bdd-verification-chain-15",
        "T-auto-031-bdd-verification-chain-16",
        "T-auto-031-bdd-verification-chain-17",
        "T-auto-031-bdd-verification-chain-18",
        "T-auto-031-bdd-verification-chain-19",
        "T-auto-031-bdd-verification-chain-20",
        "T-auto-031-bdd-verification-chain-21",
        "T-auto-031-bdd-verification-chain-22",
        "T-auto-031-bdd-verification-chain-23",
        "T-auto-031-bdd-verification-chain-24",
        "T-auto-031-bdd-verification-chain-25",
        "T-auto-031-bdd-verification-chain-26",
        "T-auto-031-bdd-verification-chain-27",
        "T-auto-031-bdd-verification-chain-28",
        "T-auto-031-bdd-verification-chain-29",
        "T-auto-031-bdd-verification-chain-30",
        "T-auto-031-bdd-verification-chain-31",
        "T-auto-031-bdd-verification-chain-32",
        "T-auto-031-bdd-verification-chain-33",
        "T-auto-031-bdd-verification-chain-34",
        "T-auto-031-bdd-verification-chain-35",
        "T-auto-031-bdd-verification-chain-36",
        "T-auto-031-bdd-verification-chain-37",
        "T-auto-031-bdd-verification-chain-38",
        "T-auto-031-bdd-verification-chain-39",
        "T-auto-031-bdd-verification-chain-40",
        "T-auto-031-bdd-verification-chain-41",
        "T-auto-031-bdd-verification-chain-42",
        "T-auto-031-bdd-verification-chain-43",
        "T-auto-031-bdd-verification-chain-44",
        "T-auto-031-bdd-verification-chain-45",
        "T-auto-031-bdd-verification-chain-46",
        "T-auto-031-bdd-verification-chain-47",
        "T-auto-031-bdd-verification-chain-48",
        "T-auto-031-bdd-verification-chain-49",
        "T-auto-031-bdd-verification-chain-50",
        "T-auto-031-bdd-verification-chain-51",
        "T-auto-031-bdd-verification-chain-52",
        "T-auto-031-bdd-verification-chain-53"
      ],
      "unimplemented_requirements": [
        "FR-001",
        "FR-002",
        "FR-003",
        "FR-004",
        "FR-005",
        "FR-006",
        "FR-007",
        "FR-008",
        "FR-009",
        "FR-010",
        "FR-011",
        "FR-012",
        "FR-013",
        "FR-014",
        "FR-015",
        "FR-016",
        "FR-017"
      ],
      "broken_refs": [],
      "tasks_with_broken_fr": [],
      "tests_with_broken_fr": []
    },
    "stats": {
      "nodes": 85,
      "edges": 0,
      "coverage": 0,
      "principlesCovered": 0,
      "principlesTotal": 8,
      "requirementsTested": 0,
      "requirementsTotal": 17,
      "features": 1
    }
  },
  "backlog": [],
  "qaplan": null,
  "changelog": [],
  "tasklog": [],
  "decisionLog": [],
  "sentinel": {
    "enabled": true,
    "lastRun": "2026-03-25T19:14:12Z",
    "runCount": 0,
    "intervalMinutes": 30,
    "suppressedUntil": null,
    "findings": [],
    "autoClosedCount": 0
  },
  "sessionLog": [
    {
      "timestamp": "2026-03-26T01:41:32Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:41:40Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:41:40Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:41:47Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:41:55Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:12Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:20Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:20Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:31Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:47Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T01:42:47Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:05:27Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:05:59Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:06:08Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:06:14Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:06:21Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:06:27Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:06:39Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:07:00Z",
      "type": "post-write",
      "description": "Hook: post-write"
    },
    {
      "timestamp": "2026-03-26T02:07:11Z",
      "type": "post-write",
      "description": "Hook: post-write"
    }
  ],
  "smartNav": {
    "message": "1 feature(s) in progress",
    "command": "/sdd:status",
    "action": "Check pipeline status"
  },
  "summary": {
    "totalFeatures": 1,
    "completeFeatures": 0,
    "totalTasks": 54,
    "completedTasks": 53
  }
};
