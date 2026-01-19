# Motion Templates — 安全动效模板库（MVP）

## 1. 设计目标
- 100%不尴尬：宁可“全局轻动效”也不要“局部乱动”
- 可配置：模板以 JSON 配置描述，便于扩展
- 可降级：动效失败→静图+声波+语音仍可出MP4

## 2. 模板列表（MVP至少8个）
T01_Wave
- 类型：全局折射/水波（轻微）
- 适用：河边/公园/夜景
- 风险：低

T02_Cloud
- 类型：云雾缓慢漂移（全局透明层）
- 风险：低

T03_Neon
- 类型：霓虹呼吸光（边缘光晕/全局微闪）
- 风险：低

T04_LightLeak
- 类型：漏光扫过（低频）
- 风险：低

T05_Flag
- 类型：预设局部“旗帜/小物飘动”
- MVP建议：先不用智能识别；只在少量PGC种子中用“已知素材/固定mask”
- 风险：中

T06_Wind
- 类型：风粒子/落叶（全局轻粒子）
- 风险：低

T07_Sparkle
- 类型：星点闪烁（全局）
- 风险：低

T08_Bokeh
- 类型：虚化光斑漂浮（全局）
- 风险：低

## 2.1 统一参数约束（MVP）
- intensity: 0.2-0.6（默认 0.35）
- speed: 0.6-1.2（默认 0.9）
- loop: true
- safe_mask: "full" | "edge" | "fixed"
- max_duration_s: 15

## 3. 模板选择策略
- 默认：T02_Cloud（最安全）
- “再来一个”：随机换一个低风险模板（避开 T05_Flag）
- 若用户是马年主题 pony=true：优先 T07_Sparkle / T04_LightLeak

## 4. JSON配置建议（示例结构）
- templates.json
  - id, name, risk_level, overlay_type, intensity, duration_s, params

风险分级：
- low：全局/轻
- mid：局部/依赖mask
- high：智能识别（MVP不启用）

## 4.1 示例配置（单条）
```json
{
  "id": "T02_Cloud",
  "name": "云雾漂移",
  "risk_level": "low",
  "overlay_type": "alpha_layer",
  "intensity": 0.35,
  "speed": 0.9,
  "loop": true,
  "safe_mask": "full",
  "max_duration_s": 15,
  "params": {
    "opacity": 0.4,
    "drift": "slow"
  }
}
```

## 5. 失败降级策略（必须实现）
- 模板渲染失败：输出静图+声波+语音 MP4
- 声波渲染失败：输出静图+语音 MP4
- 语音缺失：禁止发布（必须有语音）

## 6. MVP 后端行为
- 模板列表以本文档为准，MVP 先不落库
- 后端仅做模板 id 校验 + 原样返回，渲染留到下一阶段

## 7. 渲染兜底验收
- 任一模板渲染失败不影响播放链路
- 播放页始终有可播放 MP4（可为降级版本）
- 失败提示不打断用户流程（允许重试或“再来一个”）
