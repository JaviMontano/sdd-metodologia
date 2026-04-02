---
name: nlm-learning-meta
type: meta
version: 1.0.0
description: "Meta-prompt for NLM for Learning skill routing and activation."
---

# NLM for Learning — Meta Prompt

## Activation Triggers

Activate this skill when the user request matches ANY of:
- Direct: `/nlm:learn`, `/nlm:dim`, `/nlm:lvl`, `/nlm:st`, `/nlm:res`, `/nlm:art`, `/nlm:hub`, `/nlm:cfg`
- Intent: "learn about X", "study X", "become expert in X", "knowledge ecosystem for X"
- Intent: "create learning path for X", "deep research on X for learning"
- Intent: "NotebookLM learning", "NLM learn", "structured study plan"
- Context: User wants to go from zero to expert on any topic

## Skill Routing

1. Load SKILL.md → confirm NLM Learning applies
2. Parse command: full pipeline, single dimension, single level, status, resume
3. Extract topic from user input
4. Check state file existence (.specify/nlm-learning-state.json)
5. Activate lead agent: `nlm-learning-lead`

## Do NOT Activate When
- User wants to query an EXISTING notebook (use notebook_query directly)
- User wants to create a single notebook (use notebook_create directly)
- User wants to run research without the 7x3 framework (use research_start directly)
- Topic is too vague: "learn everything" or "study all of science"
