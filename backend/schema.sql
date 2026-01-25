-- MomentPin MVP schema (SQLite-friendly)

CREATE TABLE IF NOT EXISTS moments (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  title TEXT,
  mood_code TEXT NOT NULL,
  mood_emoji TEXT NOT NULL,
  mood_bucket TEXT,
  visibility TEXT NOT NULL CHECK (visibility IN ('public_anonymous', 'private')),
  lat REAL NOT NULL,
  lng REAL NOT NULL,
  geohash TEXT,
  zone_name TEXT,
  radius_m INTEGER,
  geo_hidden INTEGER NOT NULL DEFAULT 0,
  photo_url TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  mp4_url TEXT,
  thumb_url TEXT,
  duration_s REAL NOT NULL,
  motion_template_id TEXT NOT NULL,
  pony INTEGER NOT NULL DEFAULT 0,
  allow_replies INTEGER NOT NULL DEFAULT 1,
  allow_map_display INTEGER NOT NULL DEFAULT 1,
  angel_enabled INTEGER NOT NULL DEFAULT 0,
  angel_mode TEXT,
  allow_microcuration INTEGER NOT NULL DEFAULT 0,
  allow_echo INTEGER NOT NULL DEFAULT 0,
  allow_timecapsule INTEGER NOT NULL DEFAULT 1,
  horse_trail_enabled INTEGER NOT NULL DEFAULT 0,
  horse_witness_enabled INTEGER NOT NULL DEFAULT 0,
  model_type TEXT,
  model_id TEXT,
  style_key TEXT,
  ref_image_urls TEXT,
  ip_character_id TEXT,
  ip_pose TEXT,
  render_status TEXT,
  render_error TEXT,
  preview_url TEXT,
  transcript_text TEXT,
  caption_segments TEXT,
  task_step TEXT,
  task_status TEXT,
  task_updated_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_moments_geo_visibility
  ON moments (lat, lng, visibility);

CREATE TABLE IF NOT EXISTS reactions (
  moment_id TEXT NOT NULL,
  type TEXT NOT NULL,
  count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (moment_id, type),
  FOREIGN KEY (moment_id) REFERENCES moments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS template_replies (
  id TEXT PRIMARY KEY,
  moment_id TEXT NOT NULL,
  user_id TEXT,
  reply_id TEXT NOT NULL,
  text TEXT NOT NULL,
  mood_tag TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (moment_id) REFERENCES moments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bottles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  open_at INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('floating', 'opened')),
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS bottle_moments (
  bottle_id TEXT NOT NULL,
  moment_id TEXT NOT NULL,
  PRIMARY KEY (bottle_id, moment_id),
  FOREIGN KEY (bottle_id) REFERENCES bottles(id) ON DELETE CASCADE,
  FOREIGN KEY (moment_id) REFERENCES moments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('bottle_opened', 'system')),
  payload TEXT NOT NULL,
  read INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS angel_events (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  moment_id TEXT,
  type TEXT NOT NULL CHECK (type IN ('microcuration', 'echo', 'timecapsule')),
  state TEXT NOT NULL CHECK (state IN ('pending', 'triggered', 'dismissed', 'completed')),
  scheduled_time INTEGER,
  delivered_channel TEXT NOT NULL DEFAULT 'in_app',
  cooldown_until INTEGER,
  payload TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS moderation_events (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('report', 'block')),
  user_id TEXT,
  target_type TEXT NOT NULL CHECK (target_type IN ('moment', 'user')),
  target_id TEXT NOT NULL,
  reason TEXT,
  note TEXT,
  created_at INTEGER NOT NULL
);
