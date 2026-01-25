# API & Data Spec — 在么 MomentPin MVP

> 说明：先按“最小后端/云函数/本地mock”设计。若当前项目是纯小程序，也可先用本地JSON模拟接口，后续再接后端。

## 1) 数据结构（推荐字段）
### 1.1 Moment（内容单元）
- id: string
- user_id: string | null   // public_anonymous 可为 null
- title: string | null
- mood_code: string        // e.g. "healing", "tired", "light", "luck", "emo"
- mood_emoji: string       // e.g. "🫧"
- mood_bucket: "A" | "B" | "C" | null   // A开心/轻松 B治愈/平静 C疲惫/Emo
- visibility: "public_anonymous" | "private"
- geo:
  - lat: number
  - lng: number
  - geohash: string | null
  - zone_name: string | null   // e.g. "太古里附近"
  - radius_m: number | null    // 模糊半径
  - hidden: boolean | null     // 是否隐藏位置
- assets:
  - photo_url: string
  - audio_url: string
  - mp4_url: string | null   // MVP 可为空或占位
  - thumb_url: string | null
  - duration_s: number
- motion_template_id: string    // e.g. "T02_Cloud"
- pony: boolean                 // 是否马年小马主题
- allow_replies: boolean        // 是否允许模板回复
- allow_map_display: boolean    // 是否允许地图展示
- angel:
  - enabled: boolean            // 是否开启天使模式
  - mode: string | null         // low | med | high（MVP只做low）
  - allow_microcuration: boolean
  - allow_echo: boolean
  - allow_timecapsule: boolean
- horse:
  - trail_enabled: boolean      // 是否加入马年足迹
  - witness_enabled: boolean    // 是否允许马年见证
- model:
  - type: string | null         // "image_to_image" | "image_to_video"
  - id: string | null           // 后台可选模型ID
- style_key: string | null      // 风格：ghibli / shinkai / pixar / disney / jimmy / china_a / china_b
- ref_image_urls: string[] | null // 参考图（前端1张，后端可选2-4张）
- ip_character:
  - id: string | null
  - pose: string | null
- render:
  - status: string | null    // pending | rendering | ready | failed
  - error: string | null
  - preview_url: string | null
- transcript_text: string | null
- caption_segments: string[] | null
- task:
  - step: string | null      // style | pony | voice | video
  - status: string | null    // pending | running | done | failed
  - updated_at: number (ms) | null
- created_at: number (ms)
- updated_at: number (ms)

### 1.2 Reaction
- moment_id: string
- type: string   // e.g. "like","heart","hug","sigh","sparkle"
- count: number

### 1.3 TemplateReply（模板回复）
- id: string
- moment_id: string
- reply_id: string        // template id
- text: string
- mood_tag: string | null // optional
- created_at: number (ms)

### 1.4 Bottle（漂流瓶）
- id: string
- user_id: string
- moment_ids: string[]
- open_at: number (ms)
- status: "floating" | "opened"
- created_at: number (ms)

### 1.5 Notification（站内通知）
- id: string
- user_id: string
- type: "bottle_opened" | "system"
- payload: object          // e.g. { bottle_id, moment_ids }
- read: boolean
- created_at: number (ms)

### 1.6 AngelEvent（天使事件）
- id: string
- user_id: string
- moment_id: string | null
- type: "microcuration" | "echo" | "timecapsule"
- state: "pending" | "triggered" | "dismissed" | "completed"
- scheduled_time: number (ms) | null
- delivered_channel: "in_app"
- cooldown_until: number (ms) | null
- payload: object | null
- created_at: number (ms)

### 1.7 UserSettings（用户级开关）
- user_id: string
- allow_microcuration: boolean
- allow_echo: boolean
- allow_timecapsule: boolean
- allow_angel: boolean
- horse_trail_enabled: boolean
- horse_witness_enabled: boolean

### 1.8 MoodWeather（情绪天气）
- center_lat: number
- center_lng: number
- radius_m: number
- summary: Array<{ mood_code: string, mood_emoji: string, percent: number }>
- updated_at: number (ms)

## 2) 接口列表（MVP）
> REST风格示例；也可用小程序云函数映射同名 action。

### 2.0 约定（MVP）
- 后端：FastAPI + SQLite（本地/测试），后续可切 Postgres
- 鉴权：MVP 可匿名，user_id 允许为空；如需传递可用 uuid
- 返回结构：先用简单 JSON，后续再统一 code/message 包装
- 默认值：visibility=private，mood_bucket=A，allow_replies=true

### 2.1 Nearby Moments（地图/列表）
GET /api/moments/nearby?lat=&lng=&radius_m=3000&visibility=public_anonymous&horse_only=false
Response:
- clusters: [{ id, lat, lng, count }]
- items: Moment[] (可分页)
- mood_weather: MoodWeather
Note:
- MVP 使用 bounding box 做附近过滤（lat/lng + radius_m），先不做复杂地理索引
- 若 geo.hidden=true，仅返回 zone_name 或置空（前端不展示精确坐标）
- horse_only=true 时，仅返回马年足迹标记内容

### 2.1.1 Nearby Exhibits（微展，占位）
GET /api/moments/exhibits?lat=&lng=&radius_m=1000&window_hours=24
Response:
- exhibits: Array<{ id, title, mood_code, items: Moment[] }>
Notes:
- 仅返回 allow_microcuration=1 且 allow_map_display=1 的公开内容

### 2.2 Moment详情
GET /api/moments/:id
Response: Moment + reactions + template_replies_preview(optional)

### 2.2.1 Moment 可见性/删除
POST /api/moments/:id/visibility
Body: { visibility: "public_anonymous" | "private" }
Response: { ok: true }

POST /api/moments/:id/timecapsule
Body: { allow_timecapsule: boolean }
Response: { ok: true }

POST /api/moments/:id/horse
Body: { horse_trail_enabled: boolean, horse_witness_enabled: boolean }
Response: { ok: true }

DELETE /api/moments/:id
Response: { ok: true }

### 2.3 Create Moment（发布）
POST /api/moments
Body:
- title?
- mood_code?
- mood_bucket?
- visibility? (default private)
- geo {lat,lng,zone_name?,radius_m?,hidden?}
- motion_template_id
- pony
- allow_replies?
- allow_map_display?
- angel_enabled?
- angel_mode?
- allow_microcuration?
- allow_echo?
- allow_timecapsule?
- horse_trail_enabled?
- horse_witness_enabled?
- model_type?                 // image_to_image | image_to_video
- model_id?
- style_key?
- ref_image_urls?             // string[]
- ip_character_id?
- ip_pose?
- render_status?
- render_error?
- preview_url?
- transcript_text?
- caption_segments?          // string[]
- task_step?                 // style | pony | voice | video
- task_status?               // pending | running | done | failed
- assets {photo_url,audio_url,mp4_url,thumb_url?,duration_s}
Response: { id }
Notes:
- geo.hidden=true 时，前端展示需隐藏位置

### 2.4 Reaction
POST /api/moments/:id/reactions
Body: { type }
Response: { ok: true, counts: Reaction[] }

### 2.5 Template Reply
POST /api/moments/:id/template-replies
Body: { reply_id }
Response: { ok: true }
Note:
- 限频：同一用户对同一条片刻每天最多 1 条模板回应

### 2.6 My Moments
GET /api/me/moments
Response: Moment[]

### 2.7 Bottle
POST /api/bottles
Body: { moment_ids: string[], open_at: number }
Response: { id }

GET /api/me/bottles
Response:
- floating: Bottle[]
- opened: Bottle[]

POST /api/bottles/:id/open (dev only optional)
Response: { ok: true }

### 2.8 User Settings（用户开关）
GET /api/me/settings
Response: UserSettings

POST /api/me/settings
Body: { allow_microcuration?, allow_echo?, allow_timecapsule?, allow_angel?, horse_trail_enabled?, horse_witness_enabled? }
Response: { ok: true }
Notes:
- horse_trail_enabled: 地图马年足迹总开关
- horse_witness_enabled: 马年见证开关

### 2.9 Angel Events（天使卡片）
GET /api/me/angel-events
Response: AngelEvent[]

POST /api/me/angel-events
Body: { user_id, moment_id?, type, state, scheduled_time?, payload? }
Response: { id }

POST /api/me/echo-cards
Body: { user_id, moment_id, peer_moment_id, bridge_text?, payload? }
Response: { id }
Notes:
- 作为 echo 类型的天使卡片占位
Errors:
- 404 Moment not found
- 403 angel_disabled | not_public | echo_disabled | angel_user_disabled | echo_user_disabled

POST /api/me/angel-events/:id/state
Body: { state }
Response: { ok: true }
Notes:
- state=dismissed 时会设置冷却期（MVP默认30天）

POST /api/moments/:id/angel-events
Body: { user_id?, type, scheduled_time?, payload? }
Response: { id }
Errors:
- 404 Moment not found
- 403 angel_disabled | not_public | microcuration_disabled | map_display_disabled | echo_disabled | timecapsule_disabled
- 400 missing_user_id
- 429 angel_rate_limited
- 403 angel_user_disabled

### 2.10 Notifications
GET /api/me/notifications
Response: Notification[]

POST /api/me/notifications/:id/read
Response: { ok: true }

### 2.11 Moderation（stub）
POST /api/moderation/report
Body: { user_id?, target_type: "moment" | "user", target_id, reason?, note? }
Response: { ok: true, id }

POST /api/moderation/block
Body: { user_id, target_user_id, note? }
Response: { ok: true, id }

### 2.12 Seed（dev only）
POST /api/dev/seed/chengdu
Response: { ok: true, count: number }

### 2.13 Render Status（dev only）
POST /api/dev/moments/:id/render
Body: { status: "pending" | "rendering" | "ready" | "failed", preview_url?, error? }
Response: { ok: true }

### 2.13.1 Local Render（dev only）
POST /api/dev/render/local
Body: { moment_id: string, duration_s? }
Response: { ok: true, mp4_url } | { ok: false, error }
Notes:
- 本地 ffmpeg 生成 MP4，输出保存到 /static/renders
- 会更新 moments.mp4_url / render_status / preview_url

### 2.13.2 Seedream Render（dev only）
POST /api/dev/render/seedream
Body: { moment_id: string, prompt?, image_urls? }
Response: { ok: true, status: "rendering" } | { ok: false, error }
Errors:
- 404 Moment not found
- 400 seedream_payload_missing（prompt 与 image_urls 均为空）
- seedream_not_configured（返回 ok:false）
Notes:
- /api/dev/render/seedream/ready 可将 render_status 置为 ready

### 2.14 Render 状态流转（说明）
- pending → rendering → ready
- pending → failed
- rendering → failed
Notes:
- preview_url 仅在 ready 时返回/保存
- failed 需附带 error 用于前端降级提示

### 2.15 External Render (reserved)
- 预留给外部渲染/生成服务（不在仓库内记录接口细节）

## 3) 页面 × 接口映射
### 首页地图（附近3km）
- GET /moments/nearby (clusters + list + mood_weather)

### 点位列表抽屉
- 同 GET /moments/nearby（可带 filter: mood_code）

### 播放页
- GET /moments/:id
- POST /moments/:id/reactions
- POST /moments/:id/template-replies
- POST /bottles（从播放页加入漂流瓶）
- 导出/分享：客户端本地能力（不新增后端接口）
- 失败重试：客户端重新触发渲染（dev 用 /api/dev/moments/:id/render）

### 创建流程
- 资产上传（如果有）：photo/audio/mp4 上传到对象存储（或本地mock）
- POST /moments 发布

### 漂流瓶页
- GET /me/bottles
- GET /me/notifications

## 4) 冷启动数据（Seed）
- docs/DEMO_SEEDS_CHENGDU.md 作为内容源
- 建议导出为：/seed/chengdu_moments.json（由Codex生成）
