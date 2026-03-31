---
name: sdd-sync
description: >-
  This skill should be used when the user asks to "sync upstream", "update from IIC/kit",
  "pull latest framework", "sync intent integrity chain", "update SDD engine",
  or "reapply brand overlay". It syncs the upstream IIC/kit repository and reapplies
  the MetodologIA brand layer. Use this skill whenever the user mentions sync, upstream,
  IIC/kit update, or brand reapplication.
license: MIT
metadata:
  version: "1.7.0"
---

# SDD Sync — Upstream IIC/Kit Sync + Brand Reapply [EXPLICIT]

Sync upstream intent-integrity-chain/kit and reapply MetodologIA brand overlay.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### 1. Sync Upstream

```bash
bash scripts/sync-upstream.sh
```

### 2. Brand Overlay

```bash
bash scripts/brand-overlay.sh
```

### 3. Verify

```bash
bash scripts/verify-brand.sh
```

## Report

```
Sync complete!

Upstream: intent-integrity-chain/kit (commit: <hash>)
Brand: MetodologIA overlay applied
Verify: N/N brand checks passed

Changes: <list of updated files>
```

## Assumptions and Limits

| # | Assumption | Handling |
|---|-----------|----------|
| 1 | Git remote `upstream` configured for IIC/kit | If missing, ERROR with setup instructions. [EXPLICIT] |
| 2 | `.gitattributes` protects brand files | Brand files won't be overwritten by merge. [EXPLICIT] |
| 3 | Brand overlay is idempotent | Safe to run multiple times. [EXPLICIT] |
| 4 | Only HTML/CSS branding diverges from upstream | Skill logic stays in sync with IIC/kit. [EXPLICIT] |
| 5 | Network access required for fetch | If offline, ERROR. [EXPLICIT] |

## Edge Cases

| Scenario | Detection | Handling |
|----------|-----------|----------|
| No upstream remote | `git remote` missing upstream | ERROR with `git remote add upstream` command. [EXPLICIT] |
| Merge conflicts | Git conflict markers in files | Report conflicted files, suggest manual resolution. [EXPLICIT] |
| No changes upstream | Already up to date | Report "no updates", skip brand overlay. [EXPLICIT] |
| Brand verification fails | verify-brand.sh reports failures | Re-run brand-overlay.sh, report persistent failures. [EXPLICIT] |
| Offline | Network unreachable | ERROR with "check network connection". [EXPLICIT] |

## Good vs Bad Example

**Good**: `/sdd:sync` pulls and rebrands
```
Sync complete!
Upstream: IIC/kit @ abc1234 (3 files updated)
Brand: MetodologIA overlay applied (2 HTML patches)
Verify: 6/6 brand checks passed
```

**Bad**: Sync without verification
```
x Pulled upstream without brand reapplication
x No verification after merge
x No change list reported
```

**Why**: Sync must pull upstream, reapply brand, verify integrity, and report changes. [EXPLICIT]

## Validation Gate

Before marking sync as complete, verify: [EXPLICIT]

- [ ] V1: Upstream fetch executed
- [ ] V2: Merge/rebase completed
- [ ] V3: Brand overlay applied
- [ ] V4: Brand verification passed
- [ ] V5: Changed files reported
