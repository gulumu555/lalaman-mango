# Handoff

## Scope
- Project: MomentPin MVP (iOS-first)
- Repo: /Users/lalanman/Desktop/LaLaMan/漫过（啦啦漫2.0）
- Branch: dev

## User constraints to remember
- No waveform display.
- Create flow: photo -> style (3–4) -> pony optional -> voice -> MP4 default micro-motion.
- Subtitle is required, segmented, rolling with audio; keep minimal style.
- “+” entry must go to UGC flow (not publish settings first).
- API data must not be uploaded to Git or public (no secrets in repo).

## What I just completed (latest increment)
- Added moment task tracking + transcript/caption fields in backend + API spec.
- Commit: 09cb14f (pushed to origin/dev).

## Files touched in latest increment
- backend/app.py
- backend/db.py
- backend/schema.sql
- docs/API_DATA_SPEC.md

## How to verify
- rg "transcript_text|caption_segments|task_status" backend/app.py
- rg "task_status|task_step|task_updated_at" backend/schema.sql
- rg "caption_segments" docs/API_DATA_SPEC.md

## Current state (high level)
- iOS UI Create flow was expanded earlier to match new PRD steps; no waveform.
- Backend now supports task step/status + transcript + caption segments in Moment payloads.

## Next work (per user request)
1) Record the two new PRDs (Angel system + Year of the Horse) into docs (likely PRD_MVP.md or new PRD files).
2) Update plan and align iOS/Backend stubs with new PRDs (no heavy implementation yet).
3) Continue mainline development (MVP-first), small increments with commit + verify info.

## Open questions / confirmations needed
- Where to store the new PRDs (append to docs/PRD_MVP.md or separate files)?
- Confirm scope for “Angel system” MVP: only document & stubs now, or begin data model/UI cards next.
- Confirm desired name for Angel features in UI (Chinese/English).

## Notes about Pencil
- User asked to stop Pencil canvas work; focus on mainline code.
