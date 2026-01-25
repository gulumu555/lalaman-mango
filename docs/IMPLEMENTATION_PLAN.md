# MomentPin MVP Implementation Plan

## Goals
- Deliver a minimal backend that supports the MVP flows: create → publish → nearby list → play detail → reactions/template replies → bottles → notifications.
- Provide a lightweight schema aligned with the MVP API spec for future integration with storage and seed data.
- Track post-publish “Angel system” capabilities (micro-curation, echo cards, time capsule) behind explicit user opt-in.

## Phase 0: Scaffolding (this PR)
- Add API skeleton endpoints mapped to the MVP spec.
- Define a SQLite-friendly schema for Moments, Reactions, Template Replies, Bottles, and Notifications.

## Phase 1: Data layer + seed data
- Implement a thin data access layer (SQLite or Postgres) with CRUD helpers.
- Add seed loader for Chengdu demo data (>= 30 items) and a CLI seed command.
- Store seed assets metadata from `docs/DEMO_SEEDS_CHENGDU.md` and output to JSON.

## Phase 2: Nearby queries + mood weather
- Add geospatial indexing strategy (simple bounding box + radius filter or PostGIS).
- Implement `/api/moments/nearby` with clusters, list pagination, and mood weather summary.
- Add visibility filtering and mood_code filtering.

## Phase 3: Create + playback
- Implement `POST /api/moments` with validation, motion template lookup, and asset references.
- Integrate MP4 generation pipeline (or stub storage links until pipeline exists).
- Add `GET /api/moments/:id` for playback view with reactions/template replies preview.

## Phase 4: Bottles + notifications
- Implement bottle creation, open schedule, and notification generation.
- Add dev-only open endpoint and read receipt updates.

## Phase 5: Observability + QA
- Add structured logging around create, publish, play, and notifications.
- Add smoke tests for create → play → map list.

## Phase 6: Angel system (MVP doc-to-stub)
- Add minimal schema fields for angel permissions and modes on Moment.
- Add an AngelEvent table to record in-app cards (microcuration / echo / timecapsule).
- Implement in-app card stubs with strict opt-in and rate limits (no push).

## Phase 7: Year of the Horse (MVP doc-to-stub)
- Add activity flags for “horse trail” and “angel witness” on Moment.
- Add basic milestone card stubs (no social features).

## Local run (planned)
- `pip install -r backend/requirements.txt`
- `uvicorn backend.app:app --reload --port 8000`
