---
name: nlm-infographic-meta
type: meta
---
# NLM Infographic — Activation Routing

## Activation Triggers
- "infografía", "infographic"
- "visual", "imagen informativa"
- "poster", "póster"
- "diagrama visual"
- "/nlm:infographic"
- "crear una infografía de", "generar visual de"
- "infographic portrait", "infographic landscape", "infographic square"

## False Positives — Do NOT activate
- "take a screenshot" — user wants a screen capture, not NLM infographic
- "show me a photo" — user wants to view an image, not generate one
- "generate image with DALL-E" — user wants AI image generation, not NLM
- "create a diagram" — could be mermaid/UML, not NLM infographic (ask to clarify)
- "make a chart" — could be data visualization tool, not NLM (ask to clarify)
