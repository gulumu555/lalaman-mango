---
name: demo-seed-data
description: Use when generating or validating Chengdu 3km demo seed data (>=30 items).
---

# Demo Seed Data (Chengdu 3km)

Use this skill to generate or validate demo items for Nearby and Detail views.

## Workflow
1) Generate >=30 items within 3km radius.
2) Include mood emoji, title, zoneName, duration, coordinates.
3) Mark as demo items for UI.
4) Validate count and coordinate bounds.

## References
- Seed schema: `references/seed_schema.md`
- Generator script: `scripts/generate_chengdu_seeds.py`
