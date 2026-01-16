mkdir -p docs
touch PROJECT_BRIEF.md
touch docs/PRD_MVP.md docs/API_DATA_SPEC.md docs/ROADMAP_6M.md docs/DEMO_SEEDS_CHENGDU.md docs/MOTION_TEMPLATES.md
ls
ls docsmkdir -p docs
touch PROJECT_BRIEF.md
touch docs/PRD_MVP.md docs/API_DATA_SPEC.md docs/ROADMAP_6M.md docs/DEMO_SEEDS_CHENGDU.md docs/MOTION_TEMPLATES.md
ls
ls docsmkdir -p docs
touch PROJECT_BRIEF.md
touch docs/PRD_MVP.md docs/API_DATA_SPEC.md docs/ROADMAP_6M.md docs/DEMO_SEEDS_CHENGDU.md docs/MOTION_TEMPLATES.md
ls
ls docs# AGENTS — Codex Execution Contract (Cursor)

You are Codex running inside Cursor with access to this repo. Follow these rules strictly.

## Goals
Ship an MVP for “在么 MomentPin”: Photo + short voice + SAFE motion effect -> MP4.
Content is consumed via a nearby 3km map with “mood weather” and can be saved as “漂流瓶” (time capsule) with in-app notifications.

## Non-negotiable working rules (must follow)
1) Be verifiable: never claim something works unless you ran it locally and show:
   - exact command(s)
   - short output summary / screenshots reference (if available)
2) Small diffs: implement in small increments (<= 5 files per increment, ideally <= 300 LOC).
3) After each increment, provide:
   - What changed (1 paragraph)
   - Files touched (list)
   - How to verify (<= 3 commands)
   - Expected results (bullet points)
4) Prefer simplest implementation. Avoid over-engineering and avoid introducing new frameworks unless necessary.
5) No breaking changes without migration notes.
6) No secrets in code. Use .env.example for configs.

## Repo-first
- Read existing docs and follow repo conventions.
- Reuse existing components, styles, and API patterns.
- If something exists, extend it rather than reinventing.

## MVP scope reminders
- Motion effects PRIORITY. Style transfer (转绘) optional and should be OFF by default or not included in MVP.
- No AR real-time preview in MVP.
- Output MP4 (audio + waveform overlay + subtle motion).
- Default map: nearby 3km.
- Privacy: public_anonymous or private.
- Interactions: reaction + template replies only (no heavy comment threads).

## Deliverables checklist
- Local run with 1 command (document it).
- Seeded demo data for Chengdu 3km (>= 30 items).
- Smoke tests for: create -> play -> map list.
- Minimal logging and error handling.