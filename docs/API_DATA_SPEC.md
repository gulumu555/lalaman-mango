# API & Data Spec — 在么 MomentPin MVP

> 说明：先按“最小后端/云函数/本地mock”设计。若当前项目是纯小程序，也可先用本地JSON模拟接口，后续再接后端。

## 1) 数据结构（推荐字段）
### 1.1 Moment（内容单元）
- id: string
- user_id: string | null   // public_anonymous 可为 null
- title: string | null
- mood_code: string        // e.g. "healing", "tired", "light", "luck", "emo"
- mood_emoji: string       // e.g. "🫧"
- visibility: "public_anonymous" | "private"
- geo:
  - lat: number
  - lng: number
  - geohash: string | null
  - zone_name: string | null   // e.g. "太古里附近"
  - radius_m: number | null    // 模糊半径
- assets:
  - photo_url: string
  - audio_url: string
  - mp4_url: string
  - thumb_url: string | null
  - duration_s: number
- motion_template_id: string    // e.g. "T02_Cloud"
- pony: boolean                 // 是否马年小马主题
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

### 1.6 MoodWeather（情绪天气）
- center_lat: number
- center_lng: number
- radius_m: number
- summary: Array<{ mood_code: string, mood_emoji: string, percent: number }>
- updated_at: number (ms)

## 2) 接口列表（MVP）
> REST风格示例；也可用小程序云函数映射同名 action。

### 2.1 Nearby Moments（地图/列表）
GET /api/moments/nearby?lat=&lng=&radius_m=3000&visibility=public_anonymous
Response:
- clusters: [{ id, lat, lng, count }]
- items: Moment[] (可分页)
- mood_weather: MoodWeather

### 2.2 Moment详情
GET /api/moments/:id
Response: Moment + reactions + template_replies_preview(optional)

### 2.3 Create Moment（发布）
POST /api/moments
Body:
- title?
- mood_code
- visibility
- geo {lat,lng,zone_name?,radius_m?}
- motion_template_id
- pony
- assets {photo_url,audio_url,mp4_url,thumb_url?,duration_s}
Response: { id }

### 2.4 Reaction
POST /api/moments/:id/reactions
Body: { type }
Response: { ok: true, counts: Reaction[] }

### 2.5 Template Reply
POST /api/moments/:id/template-replies
Body: { reply_id }
Response: { ok: true }

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

### 2.8 Notifications
GET /api/me/notifications
Response: Notification[]

POST /api/me/notifications/:id/read
Response: { ok: true }

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

### 创建流程
- 资产上传（如果有）：photo/audio/mp4 上传到对象存储（或本地mock）
- POST /moments 发布

### 漂流瓶页
- GET /me/bottles
- GET /me/notifications

## 4) 冷启动数据（Seed）
- docs/DEMO_SEEDS_CHENGDU.md 作为内容源
- 建议导出为：/seed/chengdu_moments.json（由Codex生成）