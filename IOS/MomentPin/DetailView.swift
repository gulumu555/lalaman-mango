import SwiftUI

struct DetailView: View {
    let moment: Moment

    @State private var isPublic = true
    @State private var selectedReaction: String? = nil
    @State private var selectedTemplate: String? = nil
    @State private var showFeedback = false
    @State private var feedbackText = "已发送"
    @State private var showModerationSheet = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss
    @State private var isInteractive = true
    @State private var visibilityHint = "仅匿名公开可互动（占位）"
    @State private var allowReplies = true
    @State private var isPlaying = false
    @State private var showAuthorControls = false
    @State private var showModerationOptions = false
    @State private var playbackRate: Double = 1.0
    @State private var isMuted = false
    @State private var hasRepliedToday = false
    @State private var hasReactedToday = false
    @State private var didEcho = false
    @State private var showEchoPulse = false
    @State private var echoCount = 12
    @State private var isSaved = false
    @State private var showEchoCreateSheet = false
    @State private var showEchoMapHint = false
    @State private var isPublished = true
    @State private var saveCount = 24
    @State private var echoCooldownHint = "不需要时冷却 30 天（占位）"
    @State private var renderStatus = "ready"
    @State private var renderHint = "已生成"
    @State private var motionLevel = "轻"
    @State private var usePolishedCaption = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 280)
                            .cornerRadius(16)
                        Button {
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .disabled(renderStatus != "ready")
                        .opacity(renderStatus == "ready" ? 1 : 0.4)
                        .accessibilityLabel(isPlaying ? "暂停" : "播放")
                        if renderStatus == "rendering" {
                            StatusOverlay(text: "渲染中...")
                        } else if renderStatus == "failed" {
                            StatusOverlay(text: "渲染失败")
                        }
                    }
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 4)
                        Text("0:00 / 0:08")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("字幕跟随语音 · 占位")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(isPlaying ? "播放中" : "已暂停")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("播放不影响互动（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("语音时长：8s（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("语音默认开启（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("可静音播放（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("字幕 1：这一刻有点像礼物")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("字幕 2：我把它留在这里")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("字幕模式：语义分段滚动")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("不逐字跳（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("字幕必保留（无声波）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Toggle("润色字幕（占位）", isOn: $usePolishedCaption)
                            .toggleStyle(SwitchToggleStyle(tint: .black))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                RenderStatusCard(renderStatus: $renderStatus, renderHint: $renderHint)

                PlaybackControls(
                    playbackRate: $playbackRate,
                    isMuted: $isMuted,
                    isPlaying: $isPlaying
                )
                MotionEffectCard(motionLevel: $motionLevel)
                Text("动效模板：T02_Cloud（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("轻动效不影响语音（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("渲染完成才可发布（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("未渲染禁用互动（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("视频为语音容器（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("镜头语言模板化（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("不做大幅切镜头（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("不做强情绪特效（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(moment.moodEmoji) \(moment.title)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text("AI 在场 · 静默")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    Text("发布于 \(moment.zoneName) · 仅展示商圈级位置")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("位置已模糊（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("首屏到播放 ≤ 2 次点击（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("匿名展示，不显示身份（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("AI 不常驻对话（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("互动只保留轻量卡（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("不提供私聊入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("举报/屏蔽入口在更多（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        Image(systemName: isPublished ? "checkmark.seal.fill" : "clock.fill")
                            .font(.caption2)
                        Text(isPublished ? "已发布" : "未发布")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Text(isPublic ? "匿名公开" : "仅自己")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        Text("治愈 A")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        Text("轻松")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        Text("小马同框")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        Text("天使开启")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        Text("马年足迹")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        Text("可见性可切换")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                    .onChange(of: isPublic) { value in
                        visibilityHint = value ? "匿名公开可互动" : "仅自己，互动关闭"
                        isInteractive = value
                    }
                    HStack(spacing: 12) {
                        Label("商圈：\(moment.zoneName)", systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("今日 09:12", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("位置已模糊", systemImage: "shield")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        Text("情绪")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("🙂 轻松")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(999)
                        Text("✨ 小确幸")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(999)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                InteractionNotice(isPublic: isPublic, allowReplies: allowReplies, isInteractive: isInteractive)
                Text("私密内容不进入微展/回声（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声卡每天最多 1 次（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("点“不需要”后冷却 30 天（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动仅三件套（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("我也来过触发光点（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声不进入私聊（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("收藏只对自己可见（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("举报仅公开显示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("屏蔽后不再出现（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声卡仅显示匿名（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声卡不提供聊天（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("收藏不展示给他人（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("点赞不显示身份（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("举报入口在更多（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("屏蔽入口在更多（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("匿名公开才可互动（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("模板回应每日一次（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("共鸣触发轻震动（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("共鸣触发光点扩散（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("共鸣不暴露身份（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声仅链接片刻（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声不做强匹配（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("回声可一键关闭（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("举报后不再显示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("屏蔽后不再推荐（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不提示私信（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示头像（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示实名（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示社交账号（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示联系方式（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示交易入口（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示群聊入口（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示分享入口（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示外链（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示广告（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示昵称（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示距离（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示关注关系（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不引导聊天（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示私信入口（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示评论区（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示关系链（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动仅展示内容（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示标签追踪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示定位详情（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示真实姓名（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示手机号（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示邮箱（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示社交账号（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示学校/公司（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示精确地址（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示路线轨迹（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示设备信息（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示实名（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("互动不展示头像（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("天使设置（占位）")
                        .font(.headline)
                    Text("微展：允许 · 回声：允许 · 时间胶囊：开启")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(16)

                Text("轻互动")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Button {
                                guard !didEcho else { return }
                                triggerLightHaptic()
                                didEcho = true
                                echoCount += 1
                                feedbackText = "共鸣已送达"
                                showFeedback = true
                                showEchoPulse = true
                                showEchoMapHint = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    showEchoPulse = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    showEchoMapHint = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showFeedback = false
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                    Text(didEcho ? "已共鸣" : "我也来过")
                                }
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                                    .scaleEffect(showEchoPulse ? 1.4 : 0.2)
                                    .opacity(showEchoPulse ? 0 : 1)
                                    .animation(.easeOut(duration: 0.6), value: showEchoPulse)
                            )
                            .disabled(didEcho || !isInteractive || !isPublic)
                            Text("共鸣 \(echoCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Button {
                            triggerLightHaptic()
                            isSaved.toggle()
                            if isSaved {
                                saveCount += 1
                            } else {
                                saveCount = max(0, saveCount - 1)
                            }
                            feedbackText = isSaved ? "已收藏" : "取消收藏"
                            showFeedback = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showFeedback = false
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                Text(isSaved ? "已收藏" : "收藏")
                            }
                            .font(.caption)
                            .frame(width: 120)
                            .padding(.vertical, 10)
                        }
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(999)
                        .disabled(!isInteractive || !isPublic)
                        Text("收藏 \(saveCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        if isSaved {
                            Text("已收藏，可在“我”查看（占位）")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text("收藏不触发通知（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("共鸣一次 / 日（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(echoCooldownHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if showEchoMapHint {
                        Text("地图光点已点亮（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if !isInteractive {
                        Text("互动已关闭（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if !isPublic {
                        Text("仅匿名公开可互动（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                Text("回声匹配：同地点/同情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("仅轻互动，无长评论（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("回声为一次性卡片（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("回声可在设置中关闭（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        showEchoCreateSheet = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("送回声")
                                    .font(.headline)
                                Text("生成一条同地片刻")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.horizontal, 14)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .disabled(!isInteractive || !isPublic)
                    if !isInteractive || !isPublic {
                        Text("公开且互动开启后可送回声（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.06))
                .cornerRadius(16)

                ReactionRow(
                    selectedReaction: $selectedReaction,
                    isEnabled: isInteractive && isPublic && !hasReactedToday
                ) {
                    feedbackText = "反应已发送"
                    showFeedback = true
                    hasReactedToday = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showFeedback = false
                    }
                }
                Text("反应 1 秒内完成（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("私密内容不展示反应（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if hasReactedToday {
                    Text("今日已反应")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text("反应仅记录本日（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                TemplateReplies(
                    selectedTemplate: $selectedTemplate,
                    isEnabled: isInteractive && isPublic && allowReplies && !hasRepliedToday
                ) {
                    feedbackText = "模板回复已发送"
                    showFeedback = true
                    hasRepliedToday = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showFeedback = false
                    }
                }
                Text("模板回应：每日最多 1 条 · 无评论区（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("模板回复不弹键盘（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("模板回复点按即发（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("模板回复不可编辑（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if !allowReplies {
                    Text("已关闭回复")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                BottleSection()

                ShareRetrySection()

                DisclosureGroup(isExpanded: $showAuthorControls) {
                    AuthorActions(isPublic: $isPublic, allowReplies: $allowReplies, showTitle: false) {
                        showDeleteConfirm = true
                    }
                } label: {
                    Text("作者控制")
                        .font(.headline)
                }
                .padding(16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(16)

                DisclosureGroup(isExpanded: $showModerationOptions) {
                    ModerationSection(showTitle: false) {
                        showModerationSheet = true
                    }
                } label: {
                    Text("风控与举报")
                        .font(.headline)
                }
                .padding(16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(16)

                Text(visibilityHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if showFeedback {
                    Text(feedbackText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Toggle("互动开关（占位）", isOn: $isInteractive)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("离开页面自动暂停播放（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .navigationTitle("片刻")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEchoCreateSheet) {
            CreateView(presetZoneName: moment.zoneName)
        }
        .alert("风控", isPresented: $showModerationSheet) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("举报/屏蔽/拉黑占位，后续接入逻辑")
        }
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) {
                dismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后不可恢复（占位）")
        }
    }

    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

private struct ReactionRow: View {
    @Binding var selectedReaction: String?
    var isEnabled: Bool = true
    var onReact: () -> Void = {}

    private let reactions = ["🫶", "🥺", "🙂", "😮‍💨", "✨", "👏"]
    @State private var counts: [String: Int] = [
        "🫶": 12, "🥺": 6, "🙂": 18, "😮‍💨": 9, "✨": 7, "👏": 4
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("反应")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(reactions, id: \.self) { emoji in
                    Button {
                        guard isEnabled else { return }
                        selectedReaction = emoji
                        counts[emoji, default: 0] += 1
                        onReact()
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.title2)
                            Text("\(counts[emoji, default: 0])")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 44, height: 54)
                        .background(selectedReaction == emoji ? Color.black.opacity(0.1) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .opacity(isEnabled ? 1 : 0.4)
                }
            }
            Text("反应 1 秒内完成（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PlaybackControls: View {
    @Binding var playbackRate: Double
    @Binding var isMuted: Bool
    @Binding var isPlaying: Bool

    private let rates: [Double] = [0.8, 1.0, 1.2]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("播放控制")
                .font(.headline)
            HStack(spacing: 12) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                }
                .foregroundColor(.black)
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                    Text(isMuted ? "已静音" : "音量正常")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(999)
                .onTapGesture {
                    isMuted.toggle()
                }
                Spacer()
                HStack(spacing: 6) {
                    ForEach(rates, id: \.self) { rate in
                        Button("\(rate, specifier: "%.1fx")") {
                            playbackRate = rate
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(playbackRate == rate ? Color.black.opacity(0.1) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                        .cornerRadius(999)
                    }
                }
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                Capsule()
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 4)
                Text("可拖动进度（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StatusOverlay: View {
    let text: String

    var body: some View {
        VStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
            Text("可在下方重试")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

private struct MotionEffectCard: View {
    @Binding var motionLevel: String
    private let levels = ["轻", "中", "静"]
    @State private var motionTemplate = "T02_Cloud"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("动效")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(levels, id: \.self) { level in
                    Button(level) {
                        motionLevel = level
                    }
                    .font(.caption2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(motionLevel == level ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
                }
                Spacer()
                Button("换模板") {
                    motionTemplate = "T0\(Int.random(in: 1...8))_Random"
                }
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(999)
            }
            Text("模板：\(motionTemplate)")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("轻动效模板占位（安全动效）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

private struct RenderStatusCard: View {
    @Binding var renderStatus: String
    @Binding var renderHint: String

    private let statuses: [String] = ["ready", "rendering", "failed"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("渲染状态")
                    .font(.headline)
                Spacer()
                Picker("状态", selection: $renderStatus) {
                    ForEach(statuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                .pickerStyle(.menu)
            }
            Text(renderHintText)
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button("重试渲染") {
                    renderHint = "已触发重试"
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
                .disabled(renderStatus == "rendering")
                Button("查看日志") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
            }
            if renderStatus == "failed" {
                Text("失败原因：render_failed（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("失败兜底：静帧 + 字幕 MP4")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
        .onChange(of: renderStatus) { value in
            switch value {
            case "ready":
                renderHint = "已生成，可播放"
            case "rendering":
                renderHint = "渲染中..."
            case "failed":
                renderHint = "渲染失败，可重试"
            default:
                renderHint = "未知状态"
            }
        }
    }

    private var renderHintText: String {
        renderHint
    }
}

private struct TemplateReplies: View {
    @Binding var selectedTemplate: String?
    var isEnabled: Bool = true
    var onSend: () -> Void = {}
    private let templates = [
        "抱抱你", "今天也很棒", "慢慢来", "给你一点好运", "辛苦啦", "再试一次"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("模板回应")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                ForEach(templates, id: \.self) { text in
                    Button {
                        guard isEnabled else { return }
                        selectedTemplate = text
                        onSend()
                    } label: {
                        Text(text)
                            .font(.caption2)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(selectedTemplate == text ? Color.black.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                            .cornerRadius(12)
                    }
                    .opacity(isEnabled ? 1 : 0.4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InteractionNotice: View {
    let isPublic: Bool
    let allowReplies: Bool
    let isInteractive: Bool

    var body: some View {
        if isPublic && allowReplies && isInteractive {
            HStack(spacing: 8) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.caption)
                Text("匿名公开可互动（占位）")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        } else {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("互动已关闭")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(12)
        }
    }
}

private struct AuthorActions: View {
    @Binding var isPublic: Bool
    @Binding var allowReplies: Bool
    var showTitle: Bool = true
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                Text("作者控制")
                    .font(.headline)
            }
            Toggle("允许回复", isOn: $allowReplies)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Text(isPublic ? "匿名公开可互动" : "仅自己时互动将关闭")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack {
                Text("可见性")
                Spacer()
                Button(isPublic ? "匿名公开" : "仅自己") {
                    isPublic.toggle()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
            }
            HStack {
                Text("删除片刻")
                Spacer()
                Button("删除") {
                    onDelete()
                }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(999)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ModerationSection: View {
    var showTitle: Bool = true
    var onOpen: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                Text("风控")
                    .font(.headline)
            }
            HStack(spacing: 12) {
                Button("举报") {
                    onOpen()
                }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Button("屏蔽") {
                    onOpen()
                }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Button("拉黑") {
                    onOpen()
                }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
            }
            Text("占位：后续接入举报/屏蔽/拉黑逻辑")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("举报会屏蔽对方内容（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("屏蔽后不再出现同源内容（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("拉黑后不再收到互动（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BottleSection: View {
    @State private var showDatePicker = false
    @State private var openDate = Date().addingTimeInterval(60 * 60 * 24 * 365)
    @State private var quickHint = "快捷时间未选择"
    @State private var includeBottle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("漂流瓶")
                .font(.headline)
            Toggle("放进漂流瓶", isOn: $includeBottle)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Text("到期通知：你有一个漂流瓶靠岸了 🎁")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("回访节奏：3天/30天/1年（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("漂流瓶不参与微展/回声（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可关闭回访提醒（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if includeBottle {
                HStack {
                    Text("靠岸时间")
                    Spacer()
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        Text(openDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                HStack(spacing: 8) {
                    Button("明年春节") {
                        openDate = Calendar.current.date(byAdding: .day, value: 365, to: Date()) ?? openDate
                        quickHint = "已选：明年春节"
                    }
                    Button("3个月后") {
                        openDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? openDate
                        quickHint = "已选：3个月后"
                    }
                    Button("自定义") {
                        showDatePicker.toggle()
                        quickHint = "已选：自定义"
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)
                Text(quickHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if showDatePicker {
                    DatePicker("选择日期", selection: $openDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
            } else {
                Text("默认关闭，可在创作时开启")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: includeBottle)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

private struct ShareRetrySection: View {
    @State private var canShare = true
    @State private var canRetry = true
    @State private var showShareHint = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("导出与重试")
                .font(.headline)
            HStack(spacing: 12) {
                Button("导出/分享") {
                    showShareHint = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showShareHint = false
                    }
                }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                    .opacity(canShare ? 1 : 0.4)
                    .disabled(!canShare)
                Text(canShare ? "可用" : "不可用")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("分享到朋友圈") {
                    showShareHint = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showShareHint = false
                    }
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.1))
                .foregroundColor(.black)
                .cornerRadius(999)
                Button("再试一次") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                    .opacity(canRetry ? 1 : 0.4)
                    .disabled(!canRetry)
                Text(canRetry ? "可用" : "不可用")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("失败时仅重试渲染，不重复创建")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("分享仅对公开内容可用（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("分享链接可复制（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("导出后可在相册查看（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可选静音导出（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("静音仅影响导出，不影响播放（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if showShareHint {
                Text("系统分享（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
