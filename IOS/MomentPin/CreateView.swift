import SwiftUI

struct CreateView: View {
    var presetZoneName: String? = nil
    var onPublished: () -> Void = {}

    enum Step: Int, CaseIterable {
        case style = 1
        case pony = 2
        case voice = 3
        case video = 4
    }

    @State private var step: Step = .style
    @State private var isPublic = false
    @State private var includeBottle = false
    @State private var showDetail = false
    @State private var showGenerating = false
    @State private var showPublished = false
    @State private var showPublishSheet = false
    @State private var draftStyle = "治愈手绘A"
    @State private var hasVoice = false
    @State private var hasPhoto = false
    @State private var autoSaveHint = "已自动保存草稿"
    @State private var ponyEnabled = false
    @State private var ponyPlacement = "右侧合影"
    @State private var hookText = "今天的我有点___"
    @State private var subtitleText = "（字幕占位）"
    @State private var recentTaskHint = "最近任务：风格已完成，小马合成中"
    @State private var totalDurationHint = "预计 20-30 秒完成（占位）"
    @State private var publishHint = "生成完成后可下载/发布"
    @State private var failoverHint = "任何步骤失败都会有兜底（占位）"
    @State private var metricHint = "指标：风格选中率/小马开启率/语音完成率"
    @State private var costHint = "成本可控：风格/融合/视频均可降级"
    @State private var privacyHint = "默认仅自己可见，可在发布时调整"
    @State private var audioHint = "语音原声默认开启（可选静音导出）"
    @State private var moodHint = "情绪标签：默认轻松/治愈（占位）"
    @State private var recoveryHint = "中断后可在我的片刻继续（占位）"
    @State private var selectedMood = "轻松"
    @State private var hideMood = false
    private let moodOptions = ["轻松", "治愈", "emo"]
    @State private var angelEnabled = false
    @State private var allowMicrocuration = false
    @State private var allowEcho = false
    @State private var allowTimecapsule = true
    @State private var horseTrailEnabled = false
    @State private var horseWitnessEnabled = false
    @State private var shareToMoments = false
    @State private var publishSummary = ""
    @State private var publishStatusHint = ""
    @State private var publishFailed = false
    private let apiClient = APIClient()
    @State private var settingsLoaded = false

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(step: step)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            StepDots(step: step)
                .padding(.top, 8)
            Text(stepSubtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            Text("默认输出 MP4 · 字幕保留 · 小马可选")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            Text("无声波展示（已取消）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            Text("风格数量固定 3-4 个")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            Text("马年活动：小马可见证（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            Text("默认情绪：轻松（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)

            TabView(selection: $step) {
                StyleStep(hasPhoto: $hasPhoto, selectedStyle: $draftStyle)
                    .tag(Step.style)
                PonyStep(
                    ponyEnabled: $ponyEnabled,
                    ponyPlacement: $ponyPlacement,
                    selectedStyle: $draftStyle
                )
                .tag(Step.pony)
                VoiceStep(
                    hasVoice: $hasVoice,
                    hookText: $hookText,
                    subtitleText: $subtitleText,
                    selectedMood: $selectedMood,
                    hideMood: $hideMood
                )
                .tag(Step.voice)
                VideoStep(
                    ponyEnabled: $ponyEnabled,
                    selectedStyle: $draftStyle,
                    subtitleText: $subtitleText,
                    selectedMood: $selectedMood,
                    hideMood: $hideMood,
                    onPublish: { showPublishSheet = true }
                )
                .tag(Step.video)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Text("发布时可设置可见性/漂流瓶")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("发布后才出现天使/马年开关")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("发布后可创建同主题片刻（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("发布后可生成回声卡（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("发布后可进入微展浏览（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("发布后可回访旧片刻（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            Text("微展范围：500m / 1km（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            StepControls(
                step: $step,
                canProceed: canProceed
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            Text(autoSaveHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            Text(recentTaskHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
            Text(totalDurationHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(publishHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(failoverHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(metricHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(costHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(privacyHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(audioHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("语音建议 6-10 秒，最多 15 秒")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(moodHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(hideMood ? "当前情绪：隐藏" : "当前情绪：\(moodEmoji) \(selectedMood)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("情绪可用于地图筛选（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("情绪会进入情绪天气统计（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("情绪可在发布时修改（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("情绪可用于推荐同主题片刻（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("情绪可在“我”中修改（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text(recoveryHint)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("发布后可在地图微展被看见（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("回声/微展均可随时关闭（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("时间胶囊到期会提醒回访（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("可在“我”查看漂流瓶进度（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("公开内容可被收藏（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .sheet(isPresented: $showPublishSheet) {
            PublishSheet(
                isPublic: $isPublic,
                includeBottle: $includeBottle,
                angelEnabled: $angelEnabled,
                allowMicrocuration: $allowMicrocuration,
                allowEcho: $allowEcho,
                allowTimecapsule: $allowTimecapsule,
                horseTrailEnabled: $horseTrailEnabled,
                horseWitnessEnabled: $horseWitnessEnabled,
                shareToMoments: $shareToMoments,
                selectedMood: $selectedMood,
                hideMood: $hideMood,
                presetZoneName: presetZoneName,
                onCancel: {
                    showPublishSheet = false
                },
                onConfirm: {
                    showPublishSheet = false
                    showGenerating = true
                    publishStatusHint = "正在保存发布设置..."
                    publishSummary = buildPublishSummary()
                    let payload = PublishPayload(
                        isPublic: isPublic,
                        includeBottle: includeBottle,
                        moodCode: moodCode,
                        hideMood: hideMood,
                        settings: PublishSettings(
                            allowMicrocuration: allowMicrocuration,
                            allowEcho: allowEcho,
                            allowTimecapsule: allowTimecapsule,
                            angelEnabled: angelEnabled,
                            horseTrailEnabled: horseTrailEnabled,
                            horseWitnessEnabled: horseWitnessEnabled
                        )
                    )
                    apiClient.publish(payload: payload) { result in
                        switch result {
                        case .success:
                            publishStatusHint = "发布设置已保存（占位）"
                            publishFailed = false
                        case .failure:
                            publishStatusHint = "发布设置保存失败（占位）"
                            publishFailed = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showGenerating = false
                        showPublished = true
                        showDetail = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            publishStatusHint = ""
                        }
                    }
                }
            )
        }
        .overlay {
            if showGenerating {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("生成中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !publishStatusHint.isEmpty {
                        Text(publishStatusHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Text("成功率 95%（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("失败会自动降级为静帧字幕 MP4")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("资源说明：照片 + 字幕 + 微动模板")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
            } else if showPublished {
                VStack(spacing: 8) {
            Text("已发布")
                .font(.headline)
            Text("片刻已发布，可在附近查看")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("天使系统已记录偏好（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if !publishSummary.isEmpty {
                Text(publishSummary)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("完成后可返回附近（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("发布后可在“我”查看记录（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪已记录（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪已同步到天气统计（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if publishFailed {
                Text("发布设置保存失败，可重试（占位）")
                    .font(.caption2)
                    .foregroundColor(.red)
                        Button("重试保存") {
                            publishStatusHint = "正在重试保存..."
                            apiClient.publish(
                            payload: PublishPayload(
                                isPublic: isPublic,
                                includeBottle: includeBottle,
                                moodCode: moodCode,
                                hideMood: hideMood,
                                settings: PublishSettings(
                                    allowMicrocuration: allowMicrocuration,
                                    allowEcho: allowEcho,
                                        allowTimecapsule: allowTimecapsule,
                                        angelEnabled: angelEnabled,
                                        horseTrailEnabled: horseTrailEnabled,
                                        horseWitnessEnabled: horseWitnessEnabled
                                    )
                                )
                            ) { result in
                                switch result {
                                case .success:
                                    publishFailed = false
                                    publishStatusHint = "发布设置已保存（占位）"
                                case .failure:
                                    publishStatusHint = "发布设置保存失败（占位）"
                                }
                            }
                        }
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(999)
                    }
                    Text("天使/马年设置已同步（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("去附近看看") {
                        showPublished = false
                        onPublished()
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                    Button("再次创作") {
                        showPublished = false
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.15))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        showPublished = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            NavigationView {
                DetailView(moment: previewMoment)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("完成") {
                                showDetail = false
                                hasVoice = false
                                onPublished()
                            }
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userSettingsUpdated)) { _ in
            apiClient.fetchUserSettings { payload in
                angelEnabled = payload.allowAngel
                allowMicrocuration = payload.allowMicrocuration
                allowEcho = payload.allowEcho
                allowTimecapsule = payload.allowTimecapsule
                horseTrailEnabled = payload.horseTrailEnabled
                horseWitnessEnabled = payload.horseWitnessEnabled
            }
        }
        .onAppear {
            guard !settingsLoaded else { return }
            settingsLoaded = true
            apiClient.fetchUserSettings { payload in
                angelEnabled = payload.allowAngel
                allowMicrocuration = payload.allowMicrocuration
                allowEcho = payload.allowEcho
                allowTimecapsule = payload.allowTimecapsule
                horseTrailEnabled = payload.horseTrailEnabled
                horseWitnessEnabled = payload.horseWitnessEnabled
            }
        }
    }

    private var canProceed: Bool {
        switch step {
        case .style:
            return hasPhoto
        case .pony:
            return true
        case .voice:
            return hasVoice
        case .video:
            return true
        }
    }

    private var stepSubtitle: String {
        switch step {
        case .style:
            return "选择照片 + 3-4 个治愈风格"
        case .pony:
            return "小马同框（资产合成 + 融合）"
        case .voice:
            return "语音钩子 + 字幕滚动"
        case .video:
            return "默认生成微动 MP4"
        }
    }

    private var moodCode: String {
        switch selectedMood {
        case "治愈":
            return "healing"
        case "emo":
            return "emo"
        default:
            return "light"
        }
    }

    private var moodEmoji: String {
        switch selectedMood {
        case "治愈":
            return "🫧"
        case "emo":
            return "🥲"
        default:
            return "🙂"
        }
    }

    private var previewMoment: Moment {
        let base = Moment.sample.first!
        let emoji = hideMood ? "—" : moodEmoji
        return Moment(
            title: base.title,
            moodEmoji: emoji,
            zoneName: base.zoneName,
            coordinate: base.coordinate,
            count: base.count
        )
    }

    private func moodLabel(_ mood: String) -> String {
        switch mood {
        case "治愈":
            return "🫧 治愈"
        case "emo":
            return "🥲 emo"
        default:
            return "🙂 轻松"
        }
    }

    private func moodLabel(_ mood: String) -> String {
        switch mood {
        case "治愈":
            return "🫧 治愈"
        case "emo":
            return "🥲 emo"
        default:
            return "🙂 轻松"
        }
    }

    private func buildPublishSummary() -> String {
        var items: [String] = []
        items.append(isPublic ? "匿名公开" : "仅自己可见")
        if includeBottle {
            items.append("漂流瓶")
        }
        if angelEnabled {
            items.append("天使开启")
        }
        if allowMicrocuration {
            items.append("微展")
        }
        if allowEcho {
            items.append("回声")
        }
        if allowTimecapsule {
            items.append("时间胶囊")
        }
        if horseTrailEnabled {
            items.append("马年足迹")
        }
        if horseWitnessEnabled {
            items.append("马年见证")
        }
        if shareToMoments {
            items.append("朋友圈")
        }
        if !selectedMood.isEmpty {
            items.append(hideMood ? "情绪隐藏" : "情绪：\(selectedMood)")
        }
        return items.isEmpty ? "" : "发布设置：" + items.joined(separator: " · ")
    }
}

private struct StepHeader: View {
    let step: CreateView.Step

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("做一条片刻")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Step \(step.rawValue)/4")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PublishSheet: View {
    @Binding var isPublic: Bool
    @Binding var includeBottle: Bool
    @Binding var angelEnabled: Bool
    @Binding var allowMicrocuration: Bool
    @Binding var allowEcho: Bool
    @Binding var allowTimecapsule: Bool
    @Binding var horseTrailEnabled: Bool
    @Binding var horseWitnessEnabled: Bool
    @Binding var shareToMoments: Bool
    @Binding var selectedMood: String
    @Binding var hideMood: Bool
    var presetZoneName: String? = nil
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}
    @State private var hideLocation = false
    @State private var openDate = Date().addingTimeInterval(60 * 60 * 24 * 90)
    private let moodOptions = ["轻松", "治愈", "emo"]

    private var moodEmoji: String {
        switch selectedMood {
        case "治愈":
            return "🫧"
        case "emo":
            return "🥲"
        default:
            return "🙂"
        }
    }
    private let moodOptions = ["轻松", "治愈", "emo"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("取消") {
                    onCancel()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                Spacer()
                Text("发布")
                    .font(.headline)
                Spacer()
                Button("草稿") {}
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("发布权限与天使设置可随时调整")
                .font(.caption2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("发布到")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    CapsuleLabel(text: isPublic ? "匿名公开" : "仅自己", isPrimary: true)
                    CapsuleLabel(text: hideLocation ? "隐藏位置" : "显示位置", isPrimary: false)
                    if includeBottle {
                        CapsuleLabel(text: "漂流瓶", isPrimary: false)
                    }
                    if angelEnabled {
                        CapsuleLabel(text: "天使已开启", isPrimary: false)
                    }
                    if horseTrailEnabled {
                        CapsuleLabel(text: "马年足迹", isPrimary: false)
                    }
                    if shareToMoments {
                        CapsuleLabel(text: "朋友圈", isPrimary: false)
                    }
                    if !selectedMood.isEmpty {
                        CapsuleLabel(
                            text: hideMood ? "情绪·隐藏" : "情绪·\(moodEmoji) \(selectedMood)",
                            isPrimary: false
                        )
                    }
                }
                Text("情绪标签用于微展/回声（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪可用于情绪天气统计（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪可用于微展标题（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪可影响附近浏览排序（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    ForEach(moodOptions, id: \.self) { mood in
                        Button(moodLabel(mood)) {
                            selectedMood = mood
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(selectedMood == mood ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    }
                }
                .disabled(hideMood)
                Text(hideMood ? "已隐藏情绪，发布页不展示" : "可在此调整情绪")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("默认继承创作情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可选择不展示情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("推荐情绪：轻松/治愈/emo（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Toggle("匿名公开", isOn: $isPublic)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("公开默认为匿名（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("隐藏位置", isOn: $hideLocation)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("地图展示：公开默认允许（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("位置默认模糊到商圈/区域（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("情绪会展示在播放页（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("发布页可调整情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("私密内容不展示情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("隐藏情绪", isOn: $hideMood)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("放进漂流瓶", isOn: $includeBottle)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("漂流瓶默认不在地图展示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("同步到朋友圈（占位）", isOn: $shareToMoments)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("朋友圈分享为可选（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("发布权限可随时调整（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if includeBottle {
                    HStack {
                        Text("靠岸时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(openDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        Button("明年春节") {
                            openDate = Calendar.current.date(byAdding: .day, value: 365, to: Date()) ?? openDate
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                        Button("3个月后") {
                            openDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? openDate
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                        Button("自定义") {
                            openDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? openDate
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    }
                    Text("到期站内通知（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("可设置自定义日期（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("提醒可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(16)

            VStack(spacing: 12) {
                Text("发布后 AI 桥梁（天使系统）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("让天使偶尔路过（默认关）", isOn: $angelEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("强度：低（MVP）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("频控：每天最多一次天使卡（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("天使仅在你同意后触发（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("每条片刻最多触发一次（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("允许微展收录", isOn: $allowMicrocuration)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .disabled(!angelEnabled || !isPublic)
                Text("微展默认关，用户可手动开启（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Toggle("允许回声共鸣", isOn: $allowEcho)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .disabled(!angelEnabled || !isPublic)
            Text("回声为轻卡片，不做对话（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("点“不需要”后冷却 30 天（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("每日最多一次回声卡（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可举报/屏蔽（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("对方信息匿名展示（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪可能影响回声匹配（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Toggle("允许时间胶囊回访", isOn: $allowTimecapsule)
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .disabled(!angelEnabled)
            Text("回访节奏：3天 / 30天 / 1年（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("触达方式：站内卡片（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可设置静默 7 天（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("仅自己可见内容仅用于时间胶囊（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(isPublic ? "公开内容才可进入微展/回声" : "私密内容不进入微展/回声")
                .font(.caption2)
                .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("默认不打扰，可随时关闭（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(16)

            VStack(spacing: 12) {
                Toggle("加入马年足迹（默认关）", isOn: $horseTrailEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("马年见证（默认关）", isOn: $horseWitnessEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("里程碑触发：第1地点/第7条/首漂流瓶（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("活动入口：马年合影（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("马年足迹仅公开展示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("退出活动后对外隐藏足迹（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(16)

            Toggle("同步到朋友圈（占位）", isOn: $shareToMoments)
                .toggleStyle(SwitchToggleStyle(tint: .black))

            Button("确认发布") {
                onConfirm()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
        }
        .padding(20)
    }
}

private struct CapsuleLabel: View {
    let text: String
    var isPrimary: Bool = false

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isPrimary ? Color.black.opacity(0.1) : Color.gray.opacity(0.12))
            .cornerRadius(999)
    }
}

private struct StepDots: View {
    let step: CreateView.Step

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CreateView.Step.allCases, id: \.rawValue) { item in
                Circle()
                    .fill(item == step ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: item == step ? 10 : 8, height: item == step ? 10 : 8)
            }
        }
    }
}

private struct StyleStep: View {
    @Binding var hasPhoto: Bool
    @Binding var selectedStyle: String
    @State private var photoHint = "未选择照片"
    @State private var cameraAuthorized = false
    @State private var albumAuthorized = false
    private let styles = ["治愈手绘A", "治愈手绘B", "动画电影感", "漫画治愈"]
    @State private var styleStatus = "生成中"
    private let styleStatuses = ["生成中", "可选", "失败"]
    @State private var styleProgress: CGFloat = 0.4
    @State private var styleHint = "并行生成 3-4 张（≤15s）"
    @State private var selectedStyleId = "style_heal_a"
    @State private var selectHint = "已选风格将进入下一步"
    @State private var styleGuideHint = "风格一致：线条/色彩/质感保持稳定"
    @State private var downloadHint = "可下载也可单选继续"
    @State private var nextStepHint = "下一步：小马同框（可跳过）"
    @State private var retryHint = "风格失败可点此重试"

    var body: some View {
        VStack(spacing: 16) {
            Text("Step 1/4 · 风格转绘")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                Text("权限")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(cameraAuthorized ? "相机已授权" : "相机未授权")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(999)
                Text(albumAuthorized ? "相册已授权" : "相册未授权")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(999)
            }
            HStack(spacing: 12) {
                Button("拍照") {
                    cameraAuthorized = true
                    hasPhoto = true
                    photoHint = "已选择 1 张（拍照）"
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
                Button("相册") {
                    albumAuthorized = true
                    hasPhoto = true
                    photoHint = "已选择 1 张（相册）"
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .cornerRadius(999)
            }
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 200)
                .cornerRadius(16)
                .overlay(
                    Text(hasPhoto ? "图片预览（已选）" : "图片预览（占位）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
            Text("支持裁切与旋转（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("构图保持一致（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("输出封面将用于地图点位（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Button(hasPhoto ? "更换照片" : "选择照片") {
                if !albumAuthorized {
                    albumAuthorized = true
                }
                hasPhoto = true
                photoHint = "已选择 1 张（占位）"
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            if hasPhoto {
                HStack(spacing: 12) {
                    Text("画幅")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("1:1") {}
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    Button("4:5") {}
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    Button("9:16") {}
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    Text(photoHint)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Text("失败兜底：原图直出")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("静帧可下载（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("首屏示例将引导去听听（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("生成超时可重试（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("失败也能继续后续步骤（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("风格生成支持并行（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("风格结果默认缓存（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 8) {
            Text("风格候选（3-4张）")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("同构图输出，主体不跑（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("主推：治愈手绘A（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("风格选择会影响小马资产（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("候选图一屏展示（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                    Text("状态：\(styleStatus)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    ForEach(styleStatuses, id: \.self) { status in
                        Button(status) {
                            styleStatus = status
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(styleStatus == status ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    }
                }
                if styleStatus == "失败" {
                    Text("风格失败：回退原图并提示重试")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text("成功率目标 ≥95%（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        Capsule()
                            .fill(Color.black)
                            .frame(width: proxy.size.width * styleProgress, height: 6)
                    }
                }
                .frame(height: 6)
                .onChange(of: styleStatus) { value in
                    switch value {
                    case "生成中":
                        styleProgress = 0.4
                    case "可选":
                        styleProgress = 1.0
                    case "失败":
                        styleProgress = 0.2
                    default:
                        styleProgress = 0.4
                    }
                }
                Text("提示：风格固定 3-4 个（强治愈）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(styleHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("动效在视频阶段默认生成（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("失败可降级为原图（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("当前风格ID：\(selectedStyleId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(selectHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(downloadHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(nextStepHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("下载不影响继续选择（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(styleGuideHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("重试生成") {}
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(999)
                Text(retryHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(styles, id: \.self) { style in
                        VStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 120)
                                .cornerRadius(12)
                                .overlay(
                                    Text(style)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                )
                            HStack(spacing: 8) {
                                Button("下载") {}
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.12))
                                    .cornerRadius(999)
                                Button(selectedStyle == style ? "已选" : "选中") {
                                    selectedStyle = style
                                    if style == "治愈手绘A" {
                                        selectedStyleId = "style_heal_a"
                                    } else if style == "治愈手绘B" {
                                        selectedStyleId = "style_heal_b"
                                    } else if style == "动画电影感" {
                                        selectedStyleId = "style_pixar"
                                    } else {
                                        selectedStyleId = "style_comic"
                                    }
                                    selectHint = "已选：\(style)"
                                }
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(selectedStyle == style ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                                .cornerRadius(999)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
    }
}

private struct PonyStep: View {
    @Binding var ponyEnabled: Bool
    @Binding var ponyPlacement: String
    @Binding var selectedStyle: String
    private let placements = ["左侧合影", "右侧合影", "肩旁合影"]
    @State private var fusionStatus = "融合中"
    private let fusionStatuses = ["融合中", "完成", "失败"]
    @State private var fusionProgress: CGFloat = 0.5
    @State private var fusionHint = "合成+融合 ≤ 10s（占位）"
    @State private var fusionRetryHint = "融合失败可重试或关闭小马"

    var body: some View {
        VStack(spacing: 16) {
            Text("Step 2/4 · 小马主题")
                .font(.caption)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 180)
                .cornerRadius(16)
                .overlay(
                    VStack(spacing: 8) {
                        Text("合影预览（占位）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ponyEnabled ? "小马：\(ponyPlacement)" : "未开启小马主题")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                )
            Toggle("开启小马主题", isOn: $ponyEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .padding(.top, 8)
            Text("默认关闭，可选开启")
                .font(.caption2)
                .foregroundColor(.secondary)
            if ponyEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("站位候选（随机性）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("每次合成可能略有不同（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("小马为资产合成，不由 AI 生成（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("可切姿态与表情（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(placements, id: \.self) { placement in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.12))
                                    .frame(width: 90, height: 60)
                                    .cornerRadius(10)
                                Text(placement)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach(placements, id: \.self) { placement in
                            Button(placement) {
                                ponyPlacement = placement
                            }
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(ponyPlacement == placement ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                            .cornerRadius(999)
                        }
                        Button("随机站位") {
                            ponyPlacement = placements.randomElement() ?? ponyPlacement
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    }
                    Text("风格ID：\(selectedStyle)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("小马资产按风格匹配（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("融合仅修饰，不重画小马（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Text("融合说明")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("光影/色调/质感/边缘统一")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        Text("融合状态")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        ForEach(fusionStatuses, id: \.self) { status in
                            Button(status) {
                                fusionStatus = status
                            }
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(fusionStatus == status ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                            .cornerRadius(999)
                        }
                    }
                    if fusionStatus == "失败" {
                        Text("融合失败：仅贴图合成或关闭小马")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Text(fusionHint)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("重试融合") {}
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    Text(fusionRetryHint)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.black)
                                .frame(width: proxy.size.width * fusionProgress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .onChange(of: fusionStatus) { value in
                        switch value {
                        case "融合中":
                            fusionProgress = 0.5
                        case "完成":
                            fusionProgress = 1.0
                        case "失败":
                            fusionProgress = 0.2
                        default:
                            fusionProgress = 0.5
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("资产命名示例")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("pony/{style_id}/wave_happy.png")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("pony/{style_id}/heart_healing.png")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("pony/{style_id}/sit_cool.png")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Button("随机换一组站位") {
                        ponyPlacement = placements.randomElement() ?? ponyPlacement
                    }
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                    Button("下载合影静帧") {}
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                        )
                        .cornerRadius(999)
                }
            }
        }
        .padding(20)
    }
}

private struct VoiceStep: View {
    @Binding var hasVoice: Bool
    @Binding var hookText: String
    @Binding var subtitleText: String
    @Binding var selectedMood: String
    @Binding var hideMood: Bool
    @State private var recordHint = "未录音"
    @State private var isRecording = false
    @State private var micAuthorized = false
    private let subtitleSegments = [
        "今天有点累",
        "但我想记住这刻",
        "希望明天会更好"
    ]
    private let hooks = [
        "今天的我有点___",
        "我想把这一刻留给___",
        "如果这张照片会说话，它会说___",
        "我希望明天会更___"
    ]
    private let moodOptions = ["轻松", "治愈", "emo"]
    @State private var asrStatus = "识别中"
    private let asrStatuses = ["识别中", "已完成", "失败"]
    @State private var asrProgress: CGFloat = 0.4
    @State private var asrHint = "ASR ≤ 2s（占位）"

    private var moodEmoji: String {
        switch selectedMood {
        case "治愈":
            return "🫧"
        case "emo":
            return "🥲"
        default:
            return "🙂"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Step 3/4 · 语音输入")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("点选钩子再开口")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("建议 6–10 秒，上限 15 秒")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("钩子帮助降低开口门槛（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Text("情绪标签（可选）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    ForEach(moodOptions, id: \.self) { mood in
                        Button(moodLabel(mood)) {
                            selectedMood = mood
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedMood == mood ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                        .cornerRadius(999)
                    }
                }
                Button("清除情绪") {
                    selectedMood = "轻松"
                }
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(999)
                Text("未选则默认轻松（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("情绪与语音文案一起展示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("点按即可切换情绪（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("不选也可继续发布（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 10)], spacing: 10) {
                ForEach(hooks, id: \.self) { hook in
                    Button(hook) {
                        hookText = hook
                    }
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(hookText == hook ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                    .cornerRadius(12)
                }
            }
            Text("也可随机一个钩子（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack {
                Text("当前时长")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(hasVoice ? "0:08" : "0:00")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 140)
                .cornerRadius(16)
                .overlay(
                    Text(isRecording ? "录音中..." : "字幕预览占位")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                )
            Text("字幕：\(subtitleText)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(hideMood ? "情绪：隐藏" : "情绪：\(moodEmoji) \(selectedMood)")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕跟随语音滚动（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕为轻润色或原话（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("敏感词过滤后置（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕生成失败可手动输入（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                Text("识别状态")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach(asrStatuses, id: \.self) { status in
                    Button(status) {
                        asrStatus = status
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(asrStatus == status ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
                }
            }
            Text("识别失败可手动输入字幕（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.black)
                        .frame(width: proxy.size.width * asrProgress, height: 6)
                }
            }
            .frame(height: 6)
            .onChange(of: asrStatus) { value in
                switch value {
                case "识别中":
                    asrProgress = 0.4
                case "已完成":
                    asrProgress = 1.0
                case "失败":
                    asrProgress = 0.2
                default:
                    asrProgress = 0.4
                }
            }
            Text(asrHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("字幕分段预览")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach(subtitleSegments, id: \.self) { line in
                    Text(line)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text("字幕默认 1-2 行显示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 8) {
                Text("段落长度")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("8–16 字/段")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("滚动逻辑：按语义分段，不逐字跳")
                .font(.caption2)
                .foregroundColor(.secondary)
            Button(isRecording ? "停止录音" : "开始录音") {
                if isRecording {
                    isRecording = false
                    hasVoice = true
                    recordHint = "已录 0:08"
                    subtitleText = "如果这张照片会说话，它会说今天很安静"
                    asrStatus = "已完成"
                } else {
                    micAuthorized = true
                    isRecording = true
                    subtitleText = "（ASR 转写中...）"
                    asrStatus = "识别中"
                }
            }
            .onLongPressGesture(minimumDuration: 0.1) {
                hookText = hooks.randomElement() ?? hookText
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            Text("录音完成可试听（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("建议 6–10 秒，最长 15 秒")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可重录直到满意（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button("原话版") {
                    subtitleText = "今天的我有点累，但很想记住此刻"
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .cornerRadius(999)
                .disabled(!hasVoice)
                Button("润色版") {
                    subtitleText = "今天有点累，但这刻很温柔"
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .cornerRadius(999)
                .disabled(!hasVoice)
            }
            Button("手动输入字幕") {
                subtitleText = "（手动输入占位）"
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(999)
            Button("重录") {
                hasVoice = false
                isRecording = false
                recordHint = "未录音"
                subtitleText = "（字幕占位）"
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(999)
            Text(recordHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("ASR 失败可手动补一句字幕（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if !micAuthorized {
                Text("需要麦克风权限（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
    }
}

private struct VideoStep: View {
    @Binding var ponyEnabled: Bool
    @Binding var selectedStyle: String
    @Binding var subtitleText: String
    @Binding var selectedMood: String
    @Binding var hideMood: Bool
    var onPublish: () -> Void = {}
    @State private var subtitleStyle = "默认白字"
    private let subtitleStyles = ["默认白字", "薄雾底条"]
    @State private var renderStatus = "生成中"
    private let renderStatuses = ["生成中", "已完成", "失败"]
    @State private var renderProgress: CGFloat = 0.5
    @State private var renderHint = "MP4 ≤ 12s（占位）"
    @State private var coverHint = "封面取首帧或合成图（占位）"
    @State private var previewHint = "可下载 MP4 与静帧（占位）"
    @State private var exportHint = "MP4 含原声 + 字幕滚动（占位）"
    @State private var shareHint = "发布后可分享链接（占位）"
    @State private var renderRetryHint = "渲染失败可重试（占位）"

    private var moodEmoji: String {
        switch selectedMood {
        case "治愈":
            return "🫧"
        case "emo":
            return "🥲"
        default:
            return "🙂"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Step 4/4 · 生成视频 MP4")
                .font(.caption)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 220)
                .cornerRadius(16)
                .overlay(
                    VStack(spacing: 8) {
                        Text("微动 MP4 预览（占位）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("字幕滚动：\(subtitleText)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(hideMood ? "情绪：隐藏" : "情绪：\(moodEmoji) \(selectedMood)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("情绪标签随播放展示（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("字幕样式：\(subtitleStyle)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                )
            HStack(spacing: 8) {
                Text("生成状态")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach(renderStatuses, id: \.self) { status in
                    Button(status) {
                        renderStatus = status
                    }
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(renderStatus == status ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
                }
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.black)
                        .frame(width: proxy.size.width * renderProgress, height: 6)
                }
            }
            .frame(height: 6)
            .onChange(of: renderStatus) { value in
                switch value {
                case "生成中":
                    renderProgress = 0.5
                case "已完成":
                    renderProgress = 1.0
                case "失败":
                    renderProgress = 0.2
                default:
                    renderProgress = 0.5
                }
            }
            Text(renderHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(previewHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(exportHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(shareHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("默认包含原声（可静音导出）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Button("重试渲染") {}
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(999)
            Text(renderRetryHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            if renderStatus == "失败" {
            Text("失败兜底：静帧字幕 MP4")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("失败不影响继续发布（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("失败后可直接下载静帧（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
            HStack(spacing: 8) {
                Text("字幕样式")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach(subtitleStyles, id: \.self) { style in
                    Button(style) {
                        subtitleStyle = style
                    }
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(subtitleStyle == style ? Color.black.opacity(0.12) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
                }
            }
            Text("字幕默认白字，必要时启用薄雾底条")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕不允许贴纸/边框（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕不遮脸（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("默认交付 MP4（无需手动让它动起来）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("微动方式：轻推拉 / 轻漂移 / 光感呼吸（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("主体不漂移、不变形（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("不做 AR / 实时预览（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("镜头推拉极轻（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("默认使用安全动效模板（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可选：静音导出（后续）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("静音导出不含原声（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕滚动：语义分段 8–16 字/段（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕不遮挡主体，必要时启用薄雾底条")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕仅 1-2 行展示（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("字幕节奏与语音对齐（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪标签展示在角落（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(coverHint)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("封面可手动更换（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("封面可用合影静帧（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("失败重试：仅重新渲染，不重复创建")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("渲染完成可直接分享（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button("下载 MP4") {}
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                Button("下载静帧") {}
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                    .cornerRadius(999)
            }
            Text("下载不影响后续发布（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可先下载再发布（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("静帧与 MP4 可独立下载（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Button("发布") {
                onPublish()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            Text("公开/漂流瓶/仅自己 · 按旧规则")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("发布成功后可生成分享链接（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("发布后可出现在附近地图（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("可分享给好友查看（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                Text("兜底策略")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("风格失败：回退原图 · 小马失败：仅贴图合成 · 视频失败：静帧字幕 MP4")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("输出文件")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("momentpin.mp4 / cover.jpg")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("渲染完成自动保存到“我的片刻”（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可在“我”里管理片刻（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("情绪随片刻保存（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
    }
}

private struct StepControls: View {
    @Binding var step: CreateView.Step
    var canProceed: Bool = true
    @State private var stepHint = "完成当前步骤后进入下一步"

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                if !canProceed {
                    Text("请完成当前步骤")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                }
                Button("上一步") {
                    if let prev = CreateView.Step(rawValue: step.rawValue - 1) {
                        step = prev
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(999)
                .disabled(step == .style)

                Button(step == .video ? "完成" : "下一步") {
                    if let next = CreateView.Step(rawValue: step.rawValue + 1) {
                        step = next
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
                .opacity(canProceed ? 1 : 0.4)
                .disabled(!canProceed || step == .video)
            }
            Text(stepHint)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
