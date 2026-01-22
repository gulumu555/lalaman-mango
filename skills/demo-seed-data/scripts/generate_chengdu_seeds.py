#!/usr/bin/env python3
import json
import math
import random

CENTER_LAT = 30.6570
CENTER_LNG = 104.0800
RADIUS_KM = 3.0

MOODS = ["🙂", "😮‍💨", "🥲", "✨", "🫧"]
ZONES = [
    "太古里附近",
    "宽窄巷子",
    "九眼桥附近",
    "春熙路",
    "人民公园",
    "文殊院",
    "锦江绿道",
    "望江楼",
]

TITLES = [
    "风在桥上",
    "今天很轻",
    "想停一下",
    "街角的灯",
    "慢一点",
    "给自己一句话",
    "散步中",
    "小小安静",
]


def random_point_within_km(center_lat, center_lng, radius_km):
    radius_deg = radius_km / 111.0
    u = random.random()
    v = random.random()
    w = radius_deg * math.sqrt(u)
    t = 2 * math.pi * v
    lat = center_lat + w * math.cos(t)
    lng = center_lng + w * math.sin(t)
    return lat, lng


def generate(count=30):
    items = []
    for i in range(count):
        lat, lng = random_point_within_km(CENTER_LAT, CENTER_LNG, RADIUS_KM)
        item = {
            "id": f"demo-{i+1:03d}",
            "title": random.choice(TITLES),
            "moodEmoji": random.choice(MOODS),
            "zoneName": random.choice(ZONES),
            "lat": round(lat, 6),
            "lng": round(lng, 6),
            "durationSec": random.randint(3, 15),
            "isDemo": True,
        }
        items.append(item)
    return items


if __name__ == "__main__":
    data = generate(30)
    print(json.dumps(data, ensure_ascii=True, indent=2))
