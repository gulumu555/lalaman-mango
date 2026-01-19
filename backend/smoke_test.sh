#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000}"
USER_ID="${USER_ID:-user_demo}" 

seed_response=$(curl -s -X POST "$BASE_URL/api/dev/seed/chengdu")
echo "Seed: $seed_response"

create_payload=$(cat <<JSON
{
  "user_id": "$USER_ID",
  "title": "测试片刻",
  "mood_code": "light",
  "visibility": "public_anonymous",
  "geo": {"lat": 30.6570, "lng": 104.0800, "zone_name": "成都", "radius_m": 3000},
  "motion_template_id": "T02_Cloud",
  "pony": false,
  "assets": {
    "photo_url": "https://example.com/assets/test_photo.jpg",
    "audio_url": "https://example.com/assets/test_audio.mp3",
    "mp4_url": null,
    "thumb_url": null,
    "duration_s": 4.0
  }
}
JSON
)

create_response=$(curl -s -X POST "$BASE_URL/api/moments" \
  -H "Content-Type: application/json" \
  -d "$create_payload")
echo "Create: $create_response"

moment_id=$(python3 - <<PY
import json
print(json.loads('''$create_response''')["id"])
PY
)

nearby_response=$(curl -s -D /tmp/momentpin_headers.txt "$BASE_URL/api/moments/nearby?lat=30.6570&lng=104.0800&radius_m=3000&visibility=public_anonymous")
echo "Nearby: $nearby_response"
echo "Headers: $(grep -i '^X-Request-Id:' /tmp/momentpin_headers.txt | tr -d '\r')"

moment_response=$(curl -s "$BASE_URL/api/moments/$moment_id")
echo "Moment: $moment_response"

reaction_response=$(curl -s -X POST "$BASE_URL/api/moments/$moment_id/reactions" \
  -H "Content-Type: application/json" \
  -d '{"type":"heart"}')
echo "Reaction: $reaction_response"

reply_response=$(curl -s -X POST "$BASE_URL/api/moments/$moment_id/template-replies" \
  -H "Content-Type: application/json" \
  -d '{"reply_id":"A01","user_id":"user_demo"}')
echo "Reply: $reply_response"

render_response=$(curl -s -X POST "$BASE_URL/api/dev/moments/$moment_id/render" \
  -H "Content-Type: application/json" \
  -d '{"status":"ready","preview_url":"https://example.com/assets/preview_ready.jpg"}')
echo "Render: $render_response"

bottle_response=$(curl -s -X POST "$BASE_URL/api/bottles" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user_demo","moment_ids":["'$moment_id'"],"open_at":1700000000000}')
echo "Bottle: $bottle_response"

bottle_id=$(python3 - <<PY
import json
print(json.loads('''$bottle_response''')["id"])
PY
)

open_response=$(curl -s -X POST "$BASE_URL/api/bottles/$bottle_id/open")
echo "Open bottle: $open_response"

notifications_response=$(curl -s "$BASE_URL/api/me/notifications?user_id=user_demo")
echo "Notifications: $notifications_response"
