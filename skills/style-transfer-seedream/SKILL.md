---
name: style-transfer-seedream
description: Use when planning or integrating Seedream style transfer (default OFF) and fallback behavior.
---

# Seedream Style Transfer

Use this skill when you need style transfer logic or UI, without exposing any API secrets.

## Rules
- Style transfer is optional and OFF by default for MVP.
- Never commit API keys or payloads to git.
- Use .env.example placeholders only.

## Workflow
1) Select a style from the catalog.
2) Run style transfer if enabled.
3) On failure, fallback to original photo + safe motion.
4) Tag output with selected style label for UI.

## References
- Style catalog and prompt templates: `references/style_catalog.md`
