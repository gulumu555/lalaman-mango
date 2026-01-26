# MVP Progress (PRD_MVP-based)

This is a lightweight, checkable view of MVP progress mapped to `docs/PRD_MVP.md`.
Percentages reflect implementation presence (code or UI placeholders), not verified runtime success.

## Overall
- Estimated progress: **~57%**

## Checklist (PRD_MVP)

### Data & Docs
- Seed data (Chengdu 3km >= 30): **Done** (docs/seed/chengdu_demo_seed.json)
- Motion templates doc: **Done** (docs/MOTION_TEMPLATES.md)
- PRD coverage: **Done** (docs/PRD_MVP.md)

### Backend (FastAPI)
- API scaffold (nearby/detail/create/reaction/reply/bottle/notification/angel/horse): **Partial**
- Schema + DB helpers + seed loader: **Partial**
- Render pipeline endpoints (dev stubs): **Partial**
- Smoke tests (run): **Not run**

### iOS UI
- Nearby map + mood weather UI: **Partial**
- Create flow (photo->style->pony->voice->mp4->publish): **Partial**
- Detail/playback + reaction/template replies UI: **Partial**
- Bottles + Notifications UI: **Partial**

### Rendering & Media
- Photo+voice -> MP4 pipeline: **Not started**
- Failure fallback (static MP4): **Placeholder only**

### Verification
- One-command local run documented: **Partial**
- Smoke test Create -> Play -> Map list executed: **Not run**

## Notes
- Progress is tracked by presence of code/UI stubs. Real runtime validation is tracked separately in `docs/VERIFY_MVP.md`.
