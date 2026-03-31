---
description: "SDD — Bug report, fix tasks, GitHub issue import"
user-invocable: true
---

# /sdd:bugfix

Report bugs, create bugs.md records, generate fix tasks. Can import from GitHub issues.

## Quick Flow Triage

Before executing, triage the scope to determine if Quick Flow is appropriate:
```bash
bash scripts/sdd-quick-flow-triage.sh "$PROJECT_PATH"
```
If result is ESCALATE: redirect to `/sdd:spec` for full pipeline.
If result is OK or CAUTION: proceed with bugfix.

## Execution
Run the skill at `skills/sdd-bugfix/SKILL.md` with the user's input.
