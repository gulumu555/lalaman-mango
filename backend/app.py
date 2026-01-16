"""MomentPin MVP API scaffold (FastAPI).

Run locally (once deps installed):
  uvicorn backend.app:app --reload --port 8000
"""
from __future__ import annotations

from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="MomentPin MVP API", version="0.1.0")


class GeoInput(BaseModel):
    lat: float
    lng: float
    zone_name: Optional[str] = None
    radius_m: Optional[int] = None


class AssetsInput(BaseModel):
    photo_url: str
    audio_url: str
    mp4_url: str
    thumb_url: Optional[str] = None
    duration_s: float


class MomentCreateInput(BaseModel):
    title: Optional[str] = None
    mood_code: str
    visibility: str = Field(pattern="^(public_anonymous|private)$")
    geo: GeoInput
    motion_template_id: str
    pony: bool = False
    assets: AssetsInput


@app.get("/api/moments/nearby")
async def list_moments_nearby(
    lat: float,
    lng: float,
    radius_m: int = 3000,
    visibility: str = "public_anonymous",
    mood_code: Optional[str] = None,
) -> Dict[str, Any]:
    """Return clusters + items + mood_weather placeholder."""
    return {
        "clusters": [],
        "items": [],
        "mood_weather": {
            "center_lat": lat,
            "center_lng": lng,
            "radius_m": radius_m,
            "summary": [],
            "updated_at": 0,
        },
    }


@app.get("/api/moments/{moment_id}")
async def get_moment(moment_id: str) -> Dict[str, Any]:
    """Fetch moment detail (stub)."""
    raise HTTPException(status_code=404, detail="Moment not found")


@app.post("/api/moments")
async def create_moment(payload: MomentCreateInput) -> Dict[str, str]:
    """Create a moment (stub)."""
    return {"id": "moment_stub"}


@app.post("/api/moments/{moment_id}/reactions")
async def add_reaction(moment_id: str, body: Dict[str, str]) -> Dict[str, Any]:
    """Increment reaction counter (stub)."""
    if "type" not in body:
        raise HTTPException(status_code=400, detail="Missing reaction type")
    return {"ok": True, "counts": []}


@app.post("/api/moments/{moment_id}/template-replies")
async def add_template_reply(moment_id: str, body: Dict[str, str]) -> Dict[str, Any]:
    """Store template reply (stub)."""
    if "reply_id" not in body:
        raise HTTPException(status_code=400, detail="Missing reply_id")
    return {"ok": True}


@app.get("/api/me/moments")
async def list_my_moments() -> List[Dict[str, Any]]:
    """Return current user's moments (stub)."""
    return []


class BottleCreateInput(BaseModel):
    moment_ids: List[str]
    open_at: int


@app.post("/api/bottles")
async def create_bottle(payload: BottleCreateInput) -> Dict[str, str]:
    """Create bottle (stub)."""
    return {"id": "bottle_stub"}


@app.get("/api/me/bottles")
async def list_bottles() -> Dict[str, Any]:
    """List bottles grouped by status (stub)."""
    return {"floating": [], "opened": []}


@app.post("/api/bottles/{bottle_id}/open")
async def open_bottle(bottle_id: str) -> Dict[str, bool]:
    """Dev-only open bottle (stub)."""
    return {"ok": True}


@app.get("/api/me/notifications")
async def list_notifications() -> List[Dict[str, Any]]:
    """List notifications (stub)."""
    return []


@app.post("/api/me/notifications/{notification_id}/read")
async def mark_notification_read(notification_id: str) -> Dict[str, bool]:
    """Mark notification read (stub)."""
    return {"ok": True}
