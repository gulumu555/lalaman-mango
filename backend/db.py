from __future__ import annotations

import os
import sqlite3
from pathlib import Path
from typing import Any, Dict, Iterable, List

DB_PATH = Path(os.getenv("MOMENTPIN_DB_PATH", Path(__file__).with_name("momentpin.db")))
SCHEMA_PATH = Path(__file__).with_name("schema.sql")


def get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn


def init_db(conn: sqlite3.Connection) -> None:
    schema = SCHEMA_PATH.read_text(encoding="utf-8")
    conn.executescript(schema)
    ensure_moments_columns(conn)
    conn.commit()


def ensure_moments_columns(conn: sqlite3.Connection) -> None:
    rows = conn.execute("PRAGMA table_info(moments)").fetchall()
    existing = {row[1] for row in rows}
    columns = {
        "mood_bucket": "TEXT",
        "geo_hidden": "INTEGER NOT NULL DEFAULT 0",
        "mp4_url": "TEXT",
        "allow_replies": "INTEGER NOT NULL DEFAULT 1",
        "allow_map_display": "INTEGER NOT NULL DEFAULT 1",
        "angel_enabled": "INTEGER NOT NULL DEFAULT 0",
        "angel_mode": "TEXT",
        "allow_microcuration": "INTEGER NOT NULL DEFAULT 0",
        "allow_echo": "INTEGER NOT NULL DEFAULT 0",
        "allow_timecapsule": "INTEGER NOT NULL DEFAULT 1",
        "horse_trail_enabled": "INTEGER NOT NULL DEFAULT 0",
        "horse_witness_enabled": "INTEGER NOT NULL DEFAULT 0",
        "model_type": "TEXT",
        "model_id": "TEXT",
        "style_key": "TEXT",
        "ref_image_urls": "TEXT",
        "ip_character_id": "TEXT",
        "ip_pose": "TEXT",
        "render_status": "TEXT",
        "render_error": "TEXT",
        "preview_url": "TEXT",
        "transcript_text": "TEXT",
        "caption_segments": "TEXT",
        "task_step": "TEXT",
        "task_status": "TEXT",
        "task_updated_at": "INTEGER",
    }
    for name, definition in columns.items():
        if name not in existing:
            conn.execute(f"ALTER TABLE moments ADD COLUMN {name} {definition}")


def row_to_dict(row: sqlite3.Row) -> Dict[str, Any]:
    return dict(row)


def rows_to_dicts(rows: Iterable[sqlite3.Row]) -> List[Dict[str, Any]]:
    return [dict(row) for row in rows]
