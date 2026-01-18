"""MomentPin MVP API scaffold (FastAPI).

Run locally (once deps installed):
  uvicorn backend.app:app --reload --port 8000
"""
from __future__ import annotations

import json
import logging
import math
import time
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Request, Response
from pydantic import BaseModel, Field

from .db import get_connection, init_db, row_to_dict, rows_to_dicts
from .seed_data import build_seed_payloads

app = FastAPI(title="MomentPin MVP API", version="0.1.0")

DB = get_connection()
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("momentpin")


@app.middleware("http")
async def add_request_logging(request: Request, call_next) -> Response:
    request_id = f"req_{uuid4().hex}"
    request.state.request_id = request_id
    start = time.perf_counter()
    response = await call_next(request)
    duration_ms = (time.perf_counter() - start) * 1000
    response.headers["X-Request-Id"] = request_id
    LOGGER.info(
        "request_id=%s method=%s path=%s status=%s duration_ms=%.2f",
        request_id,
        request.method,
        request.url.path,
        response.status_code,
        duration_ms,
    )
    return response


@app.on_event("startup")
def on_startup() -> None:
    init_db(DB)


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
    model_type: Optional[str] = None
    model_id: Optional[str] = None
    style_key: Optional[str] = None
    ref_image_urls: Optional[List[str]] = None
    ip_character_id: Optional[str] = None
    ip_pose: Optional[str] = None
    assets: AssetsInput


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


def now_ms() -> int:
    return int(time.time() * 1000)


def request_id_from(request: Request) -> str:
    return getattr(request.state, "request_id", "unknown")


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
        "created_at": row["created_at"],
        "updated_at": row["updated_at"],
    }

@app.get("/api/moments/nearby")
async def list_moments_nearby(
    request: Request,
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

    response = {
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
    LOGGER.info(
        "request_id=%s nearby_moments lat=%.4f lng=%.4f radius_m=%s visibility=%s mood_code=%s total=%s",
        request_id_from(request),
        lat,
        lng,
        radius_m,
        visibility,
        mood_code,
        len(items),
    )
    return response


@app.get("/api/moments/{moment_id}")
async def get_moment(moment_id: str, request: Request) -> Dict[str, Any]:
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
    LOGGER.info("request_id=%s get_moment id=%s", request_id_from(request), moment_id)
    return {"moment": moment, "reactions": reactions, "template_replies_preview": replies_preview}


@app.post("/api/moments")
async def create_moment(payload: MomentCreateInput, request: Request) -> Dict[str, str]:
    """Create a moment."""
    moment_id = f"moment_{uuid4().hex}"
    mood_code = payload.mood_code or "light"
    mood_emoji = MOOD_EMOJI_BY_CODE.get(mood_code, "🙂")
    mood_bucket = payload.mood_bucket or bucket_from_code(mood_code)
    created_at = now_ms()
    allow_replies = payload.allow_replies if payload.allow_replies is not None else True
    ref_image_urls = json.dumps(payload.ref_image_urls) if payload.ref_image_urls else None
    geo_hidden = 1 if payload.geo.hidden else 0
    DB.execute(
        """
        INSERT INTO moments (
            id, user_id, title, mood_code, mood_emoji, mood_bucket, visibility,
            lat, lng, geohash, zone_name, radius_m, geo_hidden,
            photo_url, audio_url, mp4_url, thumb_url, duration_s,
            motion_template_id, pony, allow_replies,
            model_type, model_id, style_key, ref_image_urls, ip_character_id, ip_pose,
            created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            payload.model_type,
            payload.model_id,
            payload.style_key,
            ref_image_urls,
            payload.ip_character_id,
            payload.ip_pose,
            created_at,
            created_at,
        ),
    )
    DB.commit()
    LOGGER.info(
        "request_id=%s create_moment id=%s visibility=%s mood_code=%s",
        request_id_from(request),
        moment_id,
        payload.visibility,
        mood_code,
    )
    return {"id": moment_id}


@app.post("/api/moments/{moment_id}/reactions")
async def add_reaction(moment_id: str, body: Dict[str, str], request: Request) -> Dict[str, Any]:
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
    LOGGER.info(
        "request_id=%s add_reaction moment_id=%s type=%s",
        request_id_from(request),
        moment_id,
        reaction_type,
    )
    return {"ok": True, "counts": counts}


@app.post("/api/moments/{moment_id}/template-replies")
async def add_template_reply(moment_id: str, body: Dict[str, str], request: Request) -> Dict[str, Any]:
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
    LOGGER.info(
        "request_id=%s add_template_reply moment_id=%s reply_id=%s",
        request_id_from(request),
        moment_id,
        reply_id,
    )
    return {"ok": True}


@app.get("/api/me/moments")
async def list_my_moments(request: Request, user_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """Return current user's moments."""
    if not user_id:
        LOGGER.info("request_id=%s list_my_moments empty_user", request_id_from(request))
        return []
    rows = DB.execute(
        "SELECT * FROM moments WHERE user_id = ? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    moments = [moment_row_to_payload(row_to_dict(row)) for row in rows]
    LOGGER.info(
        "request_id=%s list_my_moments user_id=%s total=%s",
        request_id_from(request),
        user_id,
        len(moments),
    )
    return moments


class BottleCreateInput(BaseModel):
    user_id: Optional[str] = None
    moment_ids: List[str]
    open_at: int


@app.post("/api/bottles")
async def create_bottle(payload: BottleCreateInput, request: Request) -> Dict[str, str]:
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
    LOGGER.info(
        "request_id=%s create_bottle id=%s moments=%s",
        request_id_from(request),
        bottle_id,
        len(payload.moment_ids),
    )
    return {"id": bottle_id}


@app.get("/api/me/bottles")
async def list_bottles(request: Request, user_id: Optional[str] = None) -> Dict[str, Any]:
    """List bottles grouped by status."""
    if not user_id:
        LOGGER.info("request_id=%s list_bottles empty_user", request_id_from(request))
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
    LOGGER.info(
        "request_id=%s list_bottles user_id=%s floating=%s opened=%s",
        request_id_from(request),
        user_id,
        len(floating),
        len(opened),
    )
    return {"floating": floating, "opened": opened}


@app.post("/api/bottles/{bottle_id}/open")
async def open_bottle(bottle_id: str, request: Request) -> Dict[str, bool]:
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
    LOGGER.info(
        "request_id=%s open_bottle id=%s user_id=%s",
        request_id_from(request),
        bottle_id,
        row["user_id"],
    )
    return {"ok": True}


@app.get("/api/me/notifications")
async def list_notifications(request: Request, user_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """List notifications."""
    if not user_id:
        LOGGER.info("request_id=%s list_notifications empty_user", request_id_from(request))
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
    LOGGER.info(
        "request_id=%s list_notifications user_id=%s total=%s",
        request_id_from(request),
        user_id,
        len(notices),
    )
    return notices


@app.post("/api/me/notifications/{notification_id}/read")
async def mark_notification_read(notification_id: str, request: Request) -> Dict[str, bool]:
    """Mark notification read (stub)."""
    DB.execute(
        "UPDATE notifications SET read = 1 WHERE id = ?",
        (notification_id,),
    )
    DB.commit()
    LOGGER.info(
        "request_id=%s mark_notification_read id=%s",
        request_id_from(request),
        notification_id,
    )
    return {"ok": True}


@app.post("/api/dev/seed/chengdu")
async def seed_chengdu(request: Request) -> Dict[str, Any]:
    """Dev-only: seed Chengdu demo moments."""
    existing = DB.execute("SELECT COUNT(1) AS count FROM moments").fetchone()
    if existing and existing["count"] >= 30:
        LOGGER.info(
            "request_id=%s seed_chengdu skip count=%s",
            request_id_from(request),
            existing["count"],
        )
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
    LOGGER.info("request_id=%s seed_chengdu count=%s", request_id_from(request), created)
    return {"ok": True, "count": created}
