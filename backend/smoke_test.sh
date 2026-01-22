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

seedream_response=$(curl -s -X POST "$BASE_URL/api/dev/render/seedream" \
  -H "Content-Type: application/json" \
  -d '{"moment_id":"'$moment_id'","prompt":"demo prompt"}')
echo "Seedream render: $seedream_response"

moment_after_seedream=$(curl -s "$BASE_URL/api/moments/$moment_id")
echo "Moment after seedream: $moment_after_seedream"

seedream_ready_response=$(curl -s -X POST "$BASE_URL/api/dev/render/seedream/ready" \
  -H "Content-Type: application/json" \
  -d '{"moment_id":"'$moment_id'","image_urls":["https://example.com/assets/preview_ready.jpg"]}')
echo "Seedream ready: $seedream_ready_response"

moment_after_ready=$(curl -s "$BASE_URL/api/moments/$moment_id")
echo "Moment after ready: $moment_after_ready"

python3 - <<PY
import json
data = json.loads('''$moment_after_ready''')
status = data["moment"]["render"]["status"]
if status != "ready":
    raise SystemExit(f"Expected render status ready, got {status}")
PY

invalid_template_response=$(curl -s -X POST "$BASE_URL/api/moments" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "'"$USER_ID"'",
    "title": "非法模板测试",
    "mood_code": "light",
    "visibility": "public_anonymous",
    "geo": {"lat": 30.6570, "lng": 104.0800, "zone_name": "成都", "radius_m": 3000},
    "motion_template_id": "T99_Invalid",
    "pony": false,
    "assets": {
      "photo_url": "https://example.com/assets/test_photo.jpg",
      "audio_url": "https://example.com/assets/test_audio.mp3",
      "mp4_url": null,
      "thumb_url": null,
      "duration_s": 4.0
    }
  }')
echo "Invalid template create: $invalid_template_response"

python3 - <<PY
import json
data = json.loads('''$invalid_template_response''')
detail = data.get("detail", "")
if detail != "Invalid motion template":
    raise SystemExit(f"Expected invalid template error, got {detail}")
PY

reaction_response=$(curl -s -X POST "$BASE_URL/api/moments/$moment_id/reactions" \
  -H "Content-Type: application/json" \
  -d '{"type":"heart"}')
echo "Reaction: $reaction_response"

reply_response=$(curl -s -X POST "$BASE_URL/api/moments/$moment_id/template-replies" \
  -H "Content-Type: application/json" \
  -d '{"reply_id":"A01","user_id":"user_demo"}')
echo "Reply: $reply_response"

visibility_response=$(curl -s -X POST "$BASE_URL/api/moments/$moment_id/visibility" \
  -H "Content-Type: application/json" \
  -d '{"visibility":"private"}')
echo "Visibility: $visibility_response"

report_response=$(curl -s -X POST "$BASE_URL/api/moderation/report" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user_demo","target_type":"moment","target_id":"'$moment_id'","reason":"spam"}')
echo "Report: $report_response"

block_response=$(curl -s -X POST "$BASE_URL/api/moderation/block" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user_demo","target_user_id":"user_spam"}')
echo "Block: $block_response"

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

delete_response=$(curl -s -X DELETE "$BASE_URL/api/moments/$moment_id")
echo "Delete moment: $delete_response"

if [[ "${LOCAL_RENDER:-0}" == "1" ]]; then
  if command -v ffmpeg >/dev/null 2>&1; then
    echo "Local render: generating temp assets..."
    ffmpeg -y -f lavfi -i color=c=skyblue:s=1080x1440:d=1 -frames:v 1 -update 1 /tmp/momentpin_photo.jpg >/dev/null 2>&1
    python3 - <<'PY'
import base64
from pathlib import Path
b64 = (
    "UklGRngAAABXQVZFZm10IBAAAAABAAEAgD4AAAB9AAACABAAZGF0YVQAAABhYWFh"
    "YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh"
)
Path('/tmp/momentpin_sine.wav').write_bytes(base64.b64decode(b64))
PY
    local_create_payload=$(cat <<JSON
{
  "user_id": "$USER_ID",
  "title": "本地渲染测试",
  "mood_code": "light",
  "visibility": "public_anonymous",
  "geo": {"lat": 30.6570, "lng": 104.0800, "zone_name": "成都", "radius_m": 3000},
  "motion_template_id": "T02_Cloud",
  "pony": false,
  "assets": {
    "photo_url": "file:///tmp/momentpin_photo.jpg",
    "audio_url": "file:///tmp/momentpin_sine.wav",
    "mp4_url": null,
    "thumb_url": null,
    "duration_s": 6.0
  }
}
JSON
)
    local_create_response=$(curl -s -X POST "$BASE_URL/api/moments" \
      -H "Content-Type: application/json" \
      -d "$local_create_payload")
    echo "Local create: $local_create_response"
    local_moment_id=$(python3 - <<PY
import json
print(json.loads('''$local_create_response''')["id"])
PY
)
    local_render_response=$(curl -s -X POST "$BASE_URL/api/dev/render/local" \
      -H "Content-Type: application/json" \
      -d '{"moment_id":"'$local_moment_id'"}')
    echo "Local render: $local_render_response"
    python3 - <<PY
import json,urllib.request
data = json.loads('''$local_render_response''')
if not data.get("ok"):
    raise SystemExit("Local render failed")
mp4_url = data.get("mp4_url")
with urllib.request.urlopen("$BASE_URL" + mp4_url) as resp:
    if resp.status != 200:
        raise SystemExit("MP4 not reachable")
print("Local render ok:", mp4_url)
PY
  else
    echo "Local render: skipped (ffmpeg not found)"
  fi
fi
