---
name: nlm-learning-express
type: variation
variant: express
---
# NLM for Learning — Express Mode

Compressed execution: 3 dimensions + 1 level in ≤10 minutes. Quick familiarization, not full expertise path.

## Activation

Triggered when:
- User says `--express`, `quick overview`, `just the basics`, `10 minutes`, `fast`
- User says "give me a quick intro to", "I just need the fundamentals"
- Lead agent detects express mode intent in natural language

State file: `state.mode` set to `"express"`

## Express Pipeline

### Phase 0: Preparation
- Create 4 notebooks only:
  - `{TOPIC} — D1: Body of Knowledge`
  - `{TOPIC} — D2: State of the Art`
  - `{TOPIC} — D6: Working Prompts`
  - `{TOPIC} — L1: Cero a Competente`
- **No Hub notebook** in express mode
- State file: D3, D4, D5, D7 stay `"pending"` permanently; L2, L3 stay `"pending"`

### Phase 1: Genesis (fast research)
- 3 fast researches launched with `mode: "fast"` (NOT deep)
  - Fast mode: ~30s per dimension, ~10 sources each
- All 3 launched in parallel

### Phase 2: Harvest (simplified)
- Import all sources with **simple labeling** only: `[D1]`, `[D2]`, `[D6]`
- No noise audit — express prioritizes speed
- No Hub audit notes

### Phase 3: Synthesis (L1 only)
- Configure L1 tutor with beginner system prompt (from `references/studio-recipes.md`)
- Query D1+D2+D6 for beginner synthesis content → add as text sources to L1

### Phase 4: Artifacts (minimal)
- **L1 only**: audio (deep_dive, default length) + flashcards (easy)
- That's it — 2 artifacts total

### Phase 5: No Hub Assembly
- Skip entirely in express mode

## Express Quality Gates (reduced)

| Gate | Criteria | Threshold |
|------|----------|-----------|
| G1 | Researches launched | 3/3 (D1, D2, D6) |
| G2 | Per-dimension yield | ≥5 sources (reduced from ≥15) |
| G3 | Total sources | ≥15 (reduced from ≥100) |
| G4 | Tutor configured | L1 only (1/1) |
| G5 | Artifacts generated | ≥2 (audio + flashcards) |
| G6 | N/A | Skipped (no Hub) |

## Upgrade Path

After express completes, the skill offers:

```
🎓 Express pipeline complete for {TOPIC}!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 3 dimensions researched (D1, D2, D6)
✅ L1 tutor configured
✅ 2 artifacts generated

Want to expand to the full learning ecosystem?
→ /nlm:learn:resume will continue from here,
  adding D3-D5, D7, L2, L3, and Hub.
```

The existing state file supports upgrade: D3-D7 and L2-L3 are `"pending"`, so
`/nlm:learn:resume` detects them and continues the full pipeline seamlessly.

## Time Estimate

- **Total**: ≤10 minutes
- Research: ~2 min (3 fast parallel)
- Import + labeling: ~1 min
- Synthesis + configure: ~2 min
- Artifacts: ~5 min (audio generation is the bottleneck)

## When to Use

- Quick overview before deciding to invest in full study
- Time constraint: meeting prep, quick briefing
- Exploratory: checking if a topic is worth deep investment
- Complement to a presentation or workshop
- First touch with a completely new domain
