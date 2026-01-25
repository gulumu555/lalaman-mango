"""MomentPin MVP API scaffold (FastAPI).

Run locally (once deps installed):
  uvicorn backend.app:app --reload --port 8000
"""
from __future__ import annotations

import json
import logging
import math
import os
import shutil
import subprocess
import time
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Request
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from .db import get_connection, init_db, row_to_dict, rows_to_dicts
from .seed_data import build_seed_payloads

app = FastAPI(title="MomentPin MVP API", version="0.1.0")

BASE_DIR = os.path.dirname(__file__)
STATIC_DIR = os.path.join(BASE_DIR, "static")
RENDER_DIR = os.path.join(STATIC_DIR, "renders")
TMP_DIR = os.path.join(BASE_DIR, "tmp")

logger = logging.getLogger("momentpin")
if not logger.handlers:
    logging.basicConfig(level=logging.INFO, format="%(message)s")

DB = get_connection()


@app.on_event("startup")
def on_startup() -> None:
    init_db(DB)
    os.makedirs(RENDER_DIR, exist_ok=True)
    os.makedirs(TMP_DIR, exist_ok=True)


app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = request.headers.get("X-Request-Id") or f"req_{uuid4().hex}"
    start = time.time()
    response = await call_next(request)
    duration_ms = int((time.time() - start) * 1000)
    response.headers["X-Request-Id"] = request_id
    logger.info(
        "request_id=%s method=%s path=%s status=%s duration_ms=%s",
        request_id,
        request.method,
        request.url.path,
        response.status_code,
        duration_ms,
    )
    return response


class GeoInput(BaseModel):
    lat: float
    lng: float
    zone_name: Optional[str] = None
    radius_m: Optional[int] = None
    hidden: Optional[bool] = None


class AssetsInput(BaseModel):
    photo_url: str
    audio_url: str
    mp4_url: Optional[str] = None
    thumb_url: Optional[str] = None
    duration_s: float


class MomentCreateInput(BaseModel):
    user_id: Optional[str] = None
    title: Optional[str] = None
    mood_code: Optional[str] = None
    mood_bucket: Optional[str] = None
    visibility: str = Field(default="private", pattern="^(public_anonymous|private)$")
    geo: GeoInput
    motion_template_id: str
    pony: bool = False
    allow_replies: Optional[bool] = None
    allow_map_display: Optional[bool] = None
    angel_enabled: Optional[bool] = None
    angel_mode: Optional[str] = None
    allow_microcuration: Optional[bool] = None
    allow_echo: Optional[bool] = None
    allow_timecapsule: Optional[bool] = None
    horse_trail_enabled: Optional[bool] = None
    horse_witness_enabled: Optional[bool] = None
    model_type: Optional[str] = None
    model_id: Optional[str] = None
    style_key: Optional[str] = None
    ref_image_urls: Optional[List[str]] = None
    ip_character_id: Optional[str] = None
    ip_pose: Optional[str] = None
    render_status: Optional[str] = None
    render_error: Optional[str] = None
    preview_url: Optional[str] = None
    transcript_text: Optional[str] = None
    caption_segments: Optional[List[str]] = None
    task_step: Optional[str] = None
    task_status: Optional[str] = None
    assets: AssetsInput


class SeedreamRenderInput(BaseModel):
    moment_id: str
    prompt: Optional[str] = None
    image_urls: Optional[List[str]] = None


class LocalRenderInput(BaseModel):
    moment_id: str
    duration_s: Optional[float] = None


class ModerationEventInput(BaseModel):
    user_id: Optional[str] = None
    target_type: str = Field(pattern="^(moment|user)$")
    target_id: str
    reason: Optional[str] = None
    note: Optional[str] = None


class AngelEventCreateInput(BaseModel):
    user_id: str
    moment_id: Optional[str] = None
    type: str = Field(pattern="^(microcuration|echo|timecapsule)$")
    state: str = Field(pattern="^(pending|triggered|dismissed|completed)$")
    scheduled_time: Optional[int] = None
    payload: Optional[Dict[str, Any]] = None


class AngelMomentEventInput(BaseModel):
    user_id: Optional[str] = None
    type: str = Field(pattern="^(microcuration|echo|timecapsule)$")
    scheduled_time: Optional[int] = None
    payload: Optional[Dict[str, Any]] = None


class VisibilityUpdateInput(BaseModel):
    visibility: str = Field(pattern="^(public_anonymous|private)$")


MOOD_EMOJI_BY_CODE = {
    "light": "🙂",
    "happy": "😄",
    "luck": "✨",
    "funny": "😂",
    "calm": "🍃",
    "healing": "🫧",
    "rest": "💤",
    "quiet": "🌙",
    "tired": "😮‍💨",
    "emo": "🥲",
    "annoyed": "😵‍💫",
    "down": "😔",
}
MOTION_TEMPLATE_IDS = {
    "T01_Wave",
    "T02_Cloud",
    "T03_Neon",
    "T04_LightLeak",
    "T05_Flag",
    "T06_Wind",
    "T07_Sparkle",
    "T08_Bokeh",
}


def now_ms() -> int:
    return int(time.time() * 1000)


def bucket_from_code(code: str) -> str:
    if code in {"light", "happy", "luck", "funny"}:
        return "A"
    if code in {"calm", "healing", "rest", "quiet"}:
        return "B"
    if code in {"tired", "emo", "annoyed", "down"}:
        return "C"
    return "A"


def bounding_box(lat: float, lng: float, radius_m: int) -> Tuple[float, float, float, float]:
    lat_delta = radius_m / 111000
    lng_delta = radius_m / (111000 * max(0.1, math.cos(lat * math.pi / 180)))
    return lat - lat_delta, lat + lat_delta, lng - lng_delta, lng + lng_delta


def moment_row_to_payload(row: Dict[str, Any]) -> Dict[str, Any]:
    ref_images = []
    if row.get("ref_image_urls"):
        try:
            ref_images = json.loads(row["ref_image_urls"])
        except json.JSONDecodeError:
            ref_images = []
    caption_segments = []
    if row.get("caption_segments"):
        try:
            caption_segments = json.loads(row["caption_segments"])
        except json.JSONDecodeError:
            caption_segments = []
    return {
        "id": row["id"],
        "user_id": row["user_id"],
        "title": row["title"],
        "mood_code": row["mood_code"],
        "mood_emoji": row["mood_emoji"],
        "mood_bucket": row["mood_bucket"],
        "visibility": row["visibility"],
        "geo": {
            "lat": row["lat"],
            "lng": row["lng"],
            "geohash": row["geohash"],
            "zone_name": row["zone_name"],
            "radius_m": row["radius_m"],
            "hidden": bool(row["geo_hidden"]),
        },
        "assets": {
            "photo_url": row["photo_url"],
            "audio_url": row["audio_url"],
            "mp4_url": row["mp4_url"],
            "thumb_url": row["thumb_url"],
            "duration_s": row["duration_s"],
        },
        "motion_template_id": row["motion_template_id"],
        "pony": bool(row["pony"]),
        "allow_replies": bool(row["allow_replies"]),
        "allow_map_display": bool(row.get("allow_map_display", 1)),
        "angel": {
            "enabled": bool(row.get("angel_enabled", 0)),
            "mode": row.get("angel_mode"),
            "allow_microcuration": bool(row.get("allow_microcuration", 0)),
            "allow_echo": bool(row.get("allow_echo", 0)),
            "allow_timecapsule": bool(row.get("allow_timecapsule", 1)),
        },
        "horse": {
            "trail_enabled": bool(row.get("horse_trail_enabled", 0)),
            "witness_enabled": bool(row.get("horse_witness_enabled", 0)),
        },
        "model": {
            "type": row.get("model_type"),
            "id": row.get("model_id"),
        },
        "style_key": row.get("style_key"),
        "ref_image_urls": ref_images,
        "ip_character": {
            "id": row.get("ip_character_id"),
            "pose": row.get("ip_pose"),
        },
        "render": {
            "status": row.get("render_status") or "pending",
            "error": row.get("render_error"),
            "preview_url": row.get("preview_url"),
        },
        "transcript_text": row.get("transcript_text"),
        "caption_segments": caption_segments,
        "task": {
            "step": row.get("task_step"),
            "status": row.get("task_status"),
            "updated_at": row.get("task_updated_at"),
        },
        "created_at": row["created_at"],
        "updated_at": row["updated_at"],
    }


def _moment_allows_angel_event(row: Dict[str, Any], event_type: str) -> Tuple[bool, str]:
    if not row.get("angel_enabled"):
        return False, "angel_disabled"
    if event_type == "timecapsule":
        return (bool(row.get("allow_timecapsule")), "timecapsule_disabled")
    if row.get("visibility") != "public_anonymous":
        return False, "not_public"
    if event_type == "microcuration":
        if not row.get("allow_microcuration"):
            return False, "microcuration_disabled"
        if not row.get("allow_map_display"):
            return False, "map_display_disabled"
    if event_type == "echo" and not row.get("allow_echo"):
        return False, "echo_disabled"
    return True, ""


def seedream_configured() -> bool:
    return bool(os.getenv("ARK_API_KEY"))


def _download_asset(url: str, dst_path: str) -> None:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme in {"http", "https"}:
        urllib.request.urlretrieve(url, dst_path)
        return
    if parsed.scheme == "file":
        src_path = urllib.request.url2pathname(parsed.path)
        shutil.copyfile(src_path, dst_path)
        return
    if os.path.exists(url):
        shutil.copyfile(url, dst_path)
        return
    raise ValueError("unsupported_asset_url")


def _render_mp4(photo_url: str, audio_url: Optional[str], duration_s: float, output_path: str) -> None:
    duration = max(3.0, min(duration_s, 12.0))
    photo_path = os.path.join(TMP_DIR, f"photo_{uuid4().hex}.jpg")
    audio_path = os.path.join(TMP_DIR, f"audio_{uuid4().hex}.m4a")
    try:
        _download_asset(photo_url, photo_path)
        if audio_url:
            _download_asset(audio_url, audio_path)
        cmd = [
            "ffmpeg",
            "-y",
            "-loop",
            "1",
            "-i",
            photo_path,
        ]
        if audio_url:
            cmd += ["-i", audio_path]
        cmd += [
            "-t",
            f"{duration:.2f}",
            "-vf",
            "scale=1080:1440,format=yuv420p",
            "-c:v",
            "libx264",
            "-profile:v",
            "high",
            "-crf",
            "20",
            "-preset",
            "medium",
        ]
        if audio_url:
            cmd += ["-c:a", "aac", "-b:a", "128k", "-ar", "44100"]
        cmd.append(output_path)
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            raise RuntimeError("ffmpeg_failed")
    finally:
        for path in (photo_path, audio_path):
            if os.path.exists(path):
                os.remove(path)

@app.get("/api/moments/nearby")
async def list_moments_nearby(
    lat: float,
    lng: float,
    radius_m: int = 3000,
    visibility: str = "public_anonymous",
    mood_code: Optional[str] = None,
) -> Dict[str, Any]:
    """Return clusters + items + mood_weather."""
    min_lat, max_lat, min_lng, max_lng = bounding_box(lat, lng, radius_m)
    params = [min_lat, max_lat, min_lng, max_lng, visibility]
    mood_clause = ""
    if mood_code:
        mood_clause = " AND mood_code = ?"
        params.append(mood_code)
    rows = DB.execute(
        """
        SELECT * FROM moments
        WHERE lat BETWEEN ? AND ?
          AND lng BETWEEN ? AND ?
          AND visibility = ?
        """
        + mood_clause
        + " ORDER BY created_at DESC",
        params,
    ).fetchall()
    items = [moment_row_to_payload(row_to_dict(row)) for row in rows]

    clusters: Dict[str, Dict[str, Any]] = {}
    for item in items:
        key = f"{round(item['geo']['lat'], 3)}:{round(item['geo']['lng'], 3)}"
        if key not in clusters:
            clusters[key] = {
                "id": key,
                "lat": item["geo"]["lat"],
                "lng": item["geo"]["lng"],
                "count": 0,
            }
        clusters[key]["count"] += 1

    mood_counts: Dict[str, int] = {}
    for item in items:
        code = item["mood_code"]
        mood_counts[code] = mood_counts.get(code, 0) + 1
    total = sum(mood_counts.values()) or 0
    summary = []
    for code, count in mood_counts.items():
        summary.append(
            {
                "mood_code": code,
                "mood_emoji": MOOD_EMOJI_BY_CODE.get(code, "🙂"),
                "percent": round((count / total) * 100, 2) if total else 0,
            }
        )

    if not summary:
        summary = [
            {"mood_code": "light", "mood_emoji": "🙂", "percent": 40},
            {"mood_code": "healing", "mood_emoji": "🫧", "percent": 30},
            {"mood_code": "tired", "mood_emoji": "😮‍💨", "percent": 20},
            {"mood_code": "emo", "mood_emoji": "🥲", "percent": 10},
        ]

    return {
        "clusters": list(clusters.values()),
        "items": items,
        "mood_weather": {
            "center_lat": lat,
            "center_lng": lng,
            "radius_m": radius_m,
            "summary": summary,
            "updated_at": now_ms(),
        },
    }


@app.get("/api/moments/{moment_id}")
async def get_moment(moment_id: str) -> Dict[str, Any]:
    """Fetch moment detail."""
    row = DB.execute("SELECT * FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    moment = moment_row_to_payload(row_to_dict(row))
    reactions = rows_to_dicts(
        DB.execute(
            "SELECT moment_id, type, count FROM reactions WHERE moment_id = ?",
            (moment_id,),
        ).fetchall()
    )
    replies_preview = rows_to_dicts(
        DB.execute(
            "SELECT id, reply_id, text, created_at FROM template_replies WHERE moment_id = ? ORDER BY created_at DESC LIMIT 3",
            (moment_id,),
        ).fetchall()
    )
    return {"moment": moment, "reactions": reactions, "template_replies_preview": replies_preview}


@app.post("/api/moments")
async def create_moment(payload: MomentCreateInput) -> Dict[str, str]:
    """Create a moment."""
    moment_id = f"moment_{uuid4().hex}"
    if payload.motion_template_id not in MOTION_TEMPLATE_IDS:
        raise HTTPException(status_code=400, detail="Invalid motion template")
    mood_code = payload.mood_code or "light"
    mood_emoji = MOOD_EMOJI_BY_CODE.get(mood_code, "🙂")
    mood_bucket = payload.mood_bucket or bucket_from_code(mood_code)
    created_at = now_ms()
    allow_replies = payload.allow_replies if payload.allow_replies is not None else True
    allow_map_display = (
        payload.allow_map_display
        if payload.allow_map_display is not None
        else payload.visibility == "public_anonymous"
    )
    angel_enabled = payload.angel_enabled if payload.angel_enabled is not None else False
    allow_microcuration = (
        payload.allow_microcuration if payload.allow_microcuration is not None else False
    )
    allow_echo = payload.allow_echo if payload.allow_echo is not None else False
    allow_timecapsule = (
        payload.allow_timecapsule if payload.allow_timecapsule is not None else True
    )
    horse_trail_enabled = (
        payload.horse_trail_enabled if payload.horse_trail_enabled is not None else False
    )
    horse_witness_enabled = (
        payload.horse_witness_enabled if payload.horse_witness_enabled is not None else False
    )
    if payload.render_status and payload.render_status not in {
        "pending",
        "rendering",
        "ready",
        "failed",
    }:
        raise HTTPException(status_code=400, detail="Invalid render status")
    render_status = payload.render_status or ("ready" if payload.preview_url else "pending")
    render_error = payload.render_error or ("render_failed" if render_status == "failed" else None)
    ref_image_urls = json.dumps(payload.ref_image_urls) if payload.ref_image_urls else None
    caption_segments = json.dumps(payload.caption_segments) if payload.caption_segments else None
    task_updated_at = created_at if payload.task_status else None
    geo_hidden = 1 if payload.geo.hidden else 0
    DB.execute(
        """
        INSERT INTO moments (
            id, user_id, title, mood_code, mood_emoji, mood_bucket, visibility,
            lat, lng, geohash, zone_name, radius_m, geo_hidden,
            photo_url, audio_url, mp4_url, thumb_url, duration_s,
            motion_template_id, pony, allow_replies, allow_map_display,
            angel_enabled, angel_mode, allow_microcuration, allow_echo, allow_timecapsule,
            horse_trail_enabled, horse_witness_enabled,
            model_type, model_id, style_key, ref_image_urls, ip_character_id, ip_pose,
            render_status, render_error, preview_url,
            transcript_text, caption_segments, task_step, task_status, task_updated_at,
            created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            moment_id,
            payload.user_id,
            payload.title,
            mood_code,
            mood_emoji,
            mood_bucket,
            payload.visibility,
            payload.geo.lat,
            payload.geo.lng,
            None,
            payload.geo.zone_name,
            payload.geo.radius_m,
            geo_hidden,
            payload.assets.photo_url,
            payload.assets.audio_url,
            payload.assets.mp4_url,
            payload.assets.thumb_url,
            payload.assets.duration_s,
            payload.motion_template_id,
            1 if payload.pony else 0,
            1 if allow_replies else 0,
            1 if allow_map_display else 0,
            1 if angel_enabled else 0,
            payload.angel_mode,
            1 if allow_microcuration else 0,
            1 if allow_echo else 0,
            1 if allow_timecapsule else 0,
            1 if horse_trail_enabled else 0,
            1 if horse_witness_enabled else 0,
            payload.model_type,
            payload.model_id,
            payload.style_key,
            ref_image_urls,
            payload.ip_character_id,
            payload.ip_pose,
            render_status,
            render_error,
            payload.preview_url,
            payload.transcript_text,
            caption_segments,
            payload.task_step,
            payload.task_status,
            task_updated_at,
            created_at,
            created_at,
        ),
    )
    DB.commit()
    return {"id": moment_id}


@app.post("/api/moments/{moment_id}/reactions")
async def add_reaction(moment_id: str, body: Dict[str, str]) -> Dict[str, Any]:
    """Increment reaction counter."""
    if "type" not in body:
        raise HTTPException(status_code=400, detail="Missing reaction type")
    reaction_type = body["type"]
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    DB.execute(
        """
        INSERT INTO reactions (moment_id, type, count)
        VALUES (?, ?, 1)
        ON CONFLICT(moment_id, type) DO UPDATE SET count = count + 1
        """,
        (moment_id, reaction_type),
    )
    DB.commit()
    counts = rows_to_dicts(
        DB.execute(
            "SELECT moment_id, type, count FROM reactions WHERE moment_id = ?",
            (moment_id,),
        ).fetchall()
    )
    return {"ok": True, "counts": counts}


@app.post("/api/moments/{moment_id}/template-replies")
async def add_template_reply(moment_id: str, body: Dict[str, str]) -> Dict[str, Any]:
    """Store template reply."""
    if "reply_id" not in body:
        raise HTTPException(status_code=400, detail="Missing reply_id")
    reply_id = body["reply_id"]
    user_id = body.get("user_id")
    text = body.get("text", reply_id)
    now = now_ms()
    if user_id:
        start_of_day = now - (now % 86_400_000)
        existing = DB.execute(
            """
            SELECT 1 FROM template_replies
            WHERE moment_id = ? AND user_id = ? AND created_at >= ?
            LIMIT 1
            """,
            (moment_id, user_id, start_of_day),
        ).fetchone()
        if existing:
            raise HTTPException(status_code=429, detail="Daily reply limit reached")
    reply_row = DB.execute("SELECT allow_replies FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not reply_row:
        raise HTTPException(status_code=404, detail="Moment not found")
    if reply_row["allow_replies"] == 0:
        raise HTTPException(status_code=403, detail="Replies disabled")
    DB.execute(
        """
        INSERT INTO template_replies (id, moment_id, user_id, reply_id, text, mood_tag, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (f"reply_{uuid4().hex}", moment_id, user_id, reply_id, text, None, now),
    )
    DB.commit()
    return {"ok": True}


@app.post("/api/moments/{moment_id}/visibility")
async def update_moment_visibility(
    moment_id: str,
    payload: VisibilityUpdateInput,
) -> Dict[str, Any]:
    """Update moment visibility."""
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    DB.execute(
        """
        UPDATE moments
        SET visibility = ?, updated_at = ?
        WHERE id = ?
        """,
        (payload.visibility, now_ms(), moment_id),
    )
    DB.commit()
    return {"ok": True}


@app.delete("/api/moments/{moment_id}")
async def delete_moment(moment_id: str) -> Dict[str, Any]:
    """Delete a moment and related records."""
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    DB.execute("DELETE FROM reactions WHERE moment_id = ?", (moment_id,))
    DB.execute("DELETE FROM template_replies WHERE moment_id = ?", (moment_id,))
    DB.execute("DELETE FROM bottle_moments WHERE moment_id = ?", (moment_id,))
    DB.execute("DELETE FROM moments WHERE id = ?", (moment_id,))
    DB.commit()
    return {"ok": True}


@app.post("/api/moderation/report")
async def create_report(payload: ModerationEventInput) -> Dict[str, Any]:
    """Stub: record a report event."""
    if payload.target_type == "moment":
        row = DB.execute("SELECT id FROM moments WHERE id = ?", (payload.target_id,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Moment not found")
    event_id = f"mod_{uuid4().hex}"
    DB.execute(
        """
        INSERT INTO moderation_events
        (id, type, user_id, target_type, target_id, reason, note, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            event_id,
            "report",
            payload.user_id,
            payload.target_type,
            payload.target_id,
            payload.reason,
            payload.note,
            now_ms(),
        ),
    )
    DB.commit()
    return {"ok": True, "id": event_id}


@app.post("/api/moderation/block")
async def create_block(body: Dict[str, str]) -> Dict[str, Any]:
    """Stub: record a block event."""
    user_id = body.get("user_id")
    target_user_id = body.get("target_user_id")
    if not user_id or not target_user_id:
        raise HTTPException(status_code=400, detail="Missing user_id or target_user_id")
    event_id = f"mod_{uuid4().hex}"
    DB.execute(
        """
        INSERT INTO moderation_events
        (id, type, user_id, target_type, target_id, reason, note, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            event_id,
            "block",
            user_id,
            "user",
            target_user_id,
            None,
            body.get("note"),
            now_ms(),
        ),
    )
    DB.commit()
    return {"ok": True, "id": event_id}


@app.get("/api/me/moments")
async def list_my_moments(user_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """Return current user's moments."""
    if not user_id:
        return []
    rows = DB.execute(
        "SELECT * FROM moments WHERE user_id = ? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    return [moment_row_to_payload(row_to_dict(row)) for row in rows]


class BottleCreateInput(BaseModel):
    user_id: Optional[str] = None
    moment_ids: List[str]
    open_at: int


@app.post("/api/bottles")
async def create_bottle(payload: BottleCreateInput) -> Dict[str, str]:
    """Create bottle."""
    if not payload.user_id:
        raise HTTPException(status_code=400, detail="Missing user_id")
    bottle_id = f"bottle_{uuid4().hex}"
    created_at = now_ms()
    DB.execute(
        """
        INSERT INTO bottles (id, user_id, open_at, status, created_at)
        VALUES (?, ?, ?, 'floating', ?)
        """,
        (bottle_id, payload.user_id, payload.open_at, created_at),
    )
    for moment_id in payload.moment_ids:
        DB.execute(
            "INSERT OR IGNORE INTO bottle_moments (bottle_id, moment_id) VALUES (?, ?)",
            (bottle_id, moment_id),
        )
    DB.commit()
    return {"id": bottle_id}


@app.get("/api/me/bottles")
async def list_bottles(user_id: Optional[str] = None) -> Dict[str, Any]:
    """List bottles grouped by status."""
    if not user_id:
        return {"floating": [], "opened": []}
    rows = DB.execute(
        "SELECT * FROM bottles WHERE user_id = ? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    bottles = rows_to_dicts(rows)
    for bottle in bottles:
        moment_rows = DB.execute(
            "SELECT moment_id FROM bottle_moments WHERE bottle_id = ?",
            (bottle["id"],),
        ).fetchall()
        bottle["moment_ids"] = [row["moment_id"] for row in moment_rows]
    floating = [bottle for bottle in bottles if bottle["status"] == "floating"]
    opened = [bottle for bottle in bottles if bottle["status"] == "opened"]
    return {"floating": floating, "opened": opened}


@app.post("/api/bottles/{bottle_id}/open")
async def open_bottle(bottle_id: str) -> Dict[str, bool]:
    """Dev-only open bottle."""
    row = DB.execute("SELECT * FROM bottles WHERE id = ?", (bottle_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Bottle not found")
    DB.execute(
        "UPDATE bottles SET status = 'opened' WHERE id = ?",
        (bottle_id,),
    )
    payload = json.dumps({"bottle_id": bottle_id})
    DB.execute(
        """
        INSERT INTO notifications (id, user_id, type, payload, read, created_at)
        VALUES (?, ?, 'bottle_opened', ?, 0, ?)
        """,
        (f"notice_{uuid4().hex}", row["user_id"], payload, now_ms()),
    )
    DB.commit()
    return {"ok": True}


@app.get("/api/me/notifications")
async def list_notifications(user_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """List notifications."""
    if not user_id:
        return []
    rows = DB.execute(
        "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    notices = []
    for row in rows:
        item = row_to_dict(row)
        item["payload"] = json.loads(item["payload"])
        item["read"] = bool(item["read"])
        notices.append(item)
    return notices


@app.get("/api/me/angel-events")
async def list_angel_events(user_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """List angel events (in-app cards)."""
    if not user_id:
        return []
    rows = DB.execute(
        "SELECT * FROM angel_events WHERE user_id = ? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    events = []
    for row in rows:
        item = row_to_dict(row)
        item["payload"] = json.loads(item["payload"]) if item.get("payload") else None
        events.append(item)
    return events


@app.post("/api/me/angel-events")
async def create_angel_event(payload: AngelEventCreateInput) -> Dict[str, Any]:
    """Create an angel event (dev stub)."""
    event_id = f"angel_{uuid4().hex}"
    DB.execute(
        """
        INSERT INTO angel_events
        (id, user_id, moment_id, type, state, scheduled_time, delivered_channel, cooldown_until, payload, created_at)
        VALUES (?, ?, ?, ?, ?, ?, 'in_app', NULL, ?, ?)
        """,
        (
            event_id,
            payload.user_id,
            payload.moment_id,
            payload.type,
            payload.state,
            payload.scheduled_time,
            json.dumps(payload.payload) if payload.payload else None,
            now_ms(),
        ),
    )
    DB.commit()
    return {"id": event_id}


@app.post("/api/moments/{moment_id}/angel-events")
async def create_angel_event_from_moment(
    moment_id: str,
    payload: AngelMomentEventInput,
) -> Dict[str, Any]:
    """Create an angel event from a moment (guarded by flags)."""
    row = DB.execute("SELECT * FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    moment = row_to_dict(row)
    allowed, reason = _moment_allows_angel_event(moment, payload.type)
    if not allowed:
        raise HTTPException(status_code=403, detail=reason)
    user_id = moment.get("user_id") or payload.user_id
    if not user_id:
        raise HTTPException(status_code=400, detail="missing_user_id")
    event_id = f"angel_{uuid4().hex}"
    DB.execute(
        """
        INSERT INTO angel_events
        (id, user_id, moment_id, type, state, scheduled_time, delivered_channel, cooldown_until, payload, created_at)
        VALUES (?, ?, ?, ?, ?, ?, 'in_app', NULL, ?, ?)
        """,
        (
            event_id,
            user_id,
            moment_id,
            payload.type,
            "pending",
            payload.scheduled_time,
            json.dumps(payload.payload) if payload.payload else None,
            now_ms(),
        ),
    )
    DB.commit()
    return {"id": event_id}


@app.post("/api/me/angel-events/{event_id}/state")
async def update_angel_event_state(event_id: str, body: Dict[str, str]) -> Dict[str, Any]:
    """Update angel event state (stub)."""
    state = body.get("state")
    if state not in {"pending", "triggered", "dismissed", "completed"}:
        raise HTTPException(status_code=400, detail="Invalid state")
    row = DB.execute("SELECT id FROM angel_events WHERE id = ?", (event_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Angel event not found")
    DB.execute(
        "UPDATE angel_events SET state = ? WHERE id = ?",
        (state, event_id),
    )
    DB.commit()
    return {"ok": True}


@app.post("/api/me/notifications/{notification_id}/read")
async def mark_notification_read(notification_id: str) -> Dict[str, bool]:
    """Mark notification read (stub)."""
    DB.execute(
        "UPDATE notifications SET read = 1 WHERE id = ?",
        (notification_id,),
    )
    DB.commit()
    return {"ok": True}


@app.post("/api/dev/seed/chengdu")
async def seed_chengdu() -> Dict[str, Any]:
    """Dev-only: seed Chengdu demo moments."""
    existing = DB.execute("SELECT COUNT(1) AS count FROM moments").fetchone()
    if existing and existing["count"] >= 30:
        return {"ok": True, "count": existing["count"]}
    payloads = build_seed_payloads()
    created = 0
    for payload in payloads:
        moment_id = f"moment_{uuid4().hex}"
        mood_code = payload["mood_code"] or "light"
        mood_emoji = MOOD_EMOJI_BY_CODE.get(mood_code, "🙂")
        mood_bucket = bucket_from_code(mood_code)
        created_at = now_ms()
        DB.execute(
            """
            INSERT INTO moments (
                id, user_id, title, mood_code, mood_emoji, mood_bucket, visibility,
                lat, lng, geohash, zone_name, radius_m, geo_hidden,
                photo_url, audio_url, mp4_url, thumb_url, duration_s,
                motion_template_id, pony, allow_replies, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                moment_id,
                None,
                payload["title"],
                mood_code,
                mood_emoji,
                mood_bucket,
                payload["visibility"],
                payload["lat"],
                payload["lng"],
                None,
                payload["zone_name"],
                payload["radius_m"],
                0,
                payload["photo_url"],
                payload["audio_url"],
                payload["mp4_url"],
                payload["thumb_url"],
                payload["duration_s"],
                payload["motion_template_id"],
                1 if payload["pony"] else 0,
                1,
                created_at,
                created_at,
            ),
        )
        created += 1
    DB.commit()
    return {"ok": True, "count": created}


@app.post("/api/dev/moments/{moment_id}/render")
async def dev_update_render(moment_id: str, body: Dict[str, Any]) -> Dict[str, Any]:
    """Dev-only: update render status for demo."""
    status = body.get("status")
    if status not in {"pending", "rendering", "ready", "failed"}:
        raise HTTPException(status_code=400, detail="Invalid render status")
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    DB.execute(
        """
        UPDATE moments
        SET render_status = ?, render_error = ?, preview_url = ?, updated_at = ?
        WHERE id = ?
        """,
        (
            status,
            body.get("error"),
            body.get("preview_url"),
            now_ms(),
            moment_id,
        ),
    )
    DB.commit()
    return {"ok": True}


@app.post("/api/dev/render/local")
async def dev_local_render(body: LocalRenderInput) -> Dict[str, Any]:
    """Dev-only: render MP4 locally from photo/audio."""
    row = DB.execute(
        "SELECT photo_url, audio_url, duration_s FROM moments WHERE id = ?",
        (body.moment_id,),
    ).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    DB.execute(
        """
        UPDATE moments
        SET render_status = ?, render_error = ?, updated_at = ?
        WHERE id = ?
        """,
        ("rendering", None, now_ms(), body.moment_id),
    )
    DB.commit()
    output_name = f"{body.moment_id}_{int(time.time())}.mp4"
    output_path = os.path.join(RENDER_DIR, output_name)
    mp4_url = f"/static/renders/{output_name}"
    duration_s = body.duration_s or row["duration_s"] or 8
    try:
        _render_mp4(row["photo_url"], row["audio_url"], float(duration_s), output_path)
    except Exception as exc:
        DB.execute(
            """
            UPDATE moments
            SET render_status = ?, render_error = ?, updated_at = ?
            WHERE id = ?
            """,
            ("failed", str(exc), now_ms(), body.moment_id),
        )
        DB.commit()
        return {"ok": False, "error": str(exc)}
    DB.execute(
        """
        UPDATE moments
        SET mp4_url = ?, render_status = ?, render_error = ?, preview_url = ?, updated_at = ?
        WHERE id = ?
        """,
        (mp4_url, "ready", None, mp4_url, now_ms(), body.moment_id),
    )
    DB.commit()
    return {"ok": True, "mp4_url": mp4_url}


@app.post("/api/dev/render/seedream")
async def dev_seedream_render(body: SeedreamRenderInput) -> Dict[str, Any]:
    """Dev-only: placeholder for external rendering."""
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (body.moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    if not body.prompt and not (body.image_urls or []):
        DB.execute(
            """
            UPDATE moments
            SET render_status = ?, render_error = ?, updated_at = ?
            WHERE id = ?
            """,
            ("failed", "seedream_payload_missing", now_ms(), body.moment_id),
        )
        DB.commit()
        raise HTTPException(status_code=400, detail="seedream_payload_missing")
    if not seedream_configured():
        DB.execute(
            """
            UPDATE moments
            SET render_status = ?, render_error = ?, updated_at = ?
            WHERE id = ?
            """,
            ("failed", "seedream_not_configured", now_ms(), body.moment_id),
        )
        DB.commit()
        return {"ok": False, "error": "seedream_not_configured"}
    DB.execute(
        """
        UPDATE moments
        SET render_status = ?, render_error = ?, updated_at = ?
        WHERE id = ?
        """,
        ("rendering", None, now_ms(), body.moment_id),
    )
    DB.commit()
    return {"ok": True, "status": "rendering"}


@app.post("/api/dev/render/seedream/ready")
async def dev_seedream_ready(body: SeedreamRenderInput) -> Dict[str, Any]:
    """Dev-only: mark a render as ready with optional preview URL."""
    row = DB.execute("SELECT id FROM moments WHERE id = ?", (body.moment_id,)).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Moment not found")
    preview_url = body.image_urls[0] if body.image_urls else None
    DB.execute(
        """
        UPDATE moments
        SET render_status = ?, render_error = ?, preview_url = ?, updated_at = ?
        WHERE id = ?
        """,
        ("ready", None, preview_url, now_ms(), body.moment_id),
    )
    DB.commit()
    return {"ok": True, "status": "ready", "preview_url": preview_url}
