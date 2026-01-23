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
    private let previewMoment = Moment.sample.first!
    @State private var draftStyle = "治愈手绘A"
    @State private var hasVoice = false
    @State private var hasPhoto = false
    @State private var autoSaveHint = "已自动保存草稿"
    @State private var ponyEnabled = false
    @State private var ponyPlacement = "右侧合影"
    @State private var hookText = "今天的我有点___"
    @State private var subtitleText = "（字幕占位）"

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(step: step)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            StepDots(step: step)
                .padding(.top, 8)

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
                    subtitleText: $subtitleText
                )
                .tag(Step.voice)
                VideoStep(
                    ponyEnabled: $ponyEnabled,
                    selectedStyle: $draftStyle,
                    subtitleText: $subtitleText,
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
        }
        .background(Color.white)
        .sheet(isPresented: $showPublishSheet) {
            PublishSheet(
                isPublic: $isPublic,
                includeBottle: $includeBottle,
                presetZoneName: presetZoneName,
                onCancel: {
                    showPublishSheet = false
                },
                onConfirm: {
                    showPublishSheet = false
                    showGenerating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showGenerating = false
                        showPublished = true
                        showDetail = true
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
    var presetZoneName: String? = nil
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}
    @State private var shareToMoments = false
    @State private var hideLocation = false
    @State private var openDate = Date().addingTimeInterval(60 * 60 * 24 * 90)

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
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Toggle("匿名公开", isOn: $isPublic)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("隐藏位置", isOn: $hideLocation)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("放进漂流瓶", isOn: $includeBottle)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
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
                }
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
            VStack(alignment: .leading, spacing: 8) {
                Text("风格候选（3-4张）")
                    .font(.caption)
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
            if ponyEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("站位候选（随机性）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
                    }
                    Text("风格ID：\(selectedStyle)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("随机换一组站位") {
                        ponyPlacement = placements.randomElement() ?? ponyPlacement
                    }
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
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
    @State private var recordHint = "未录音"
    @State private var isRecording = false
    @State private var micAuthorized = false
    private let hooks = [
        "今天的我有点___",
        "我想把这一刻留给___",
        "如果这张照片会说话，它会说___",
        "我希望明天会更___"
    ]

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
            Button(isRecording ? "停止录音" : "开始录音") {
                if isRecording {
                    isRecording = false
                    hasVoice = true
                    recordHint = "已录 0:08"
                    subtitleText = "如果这张照片会说话，它会说今天很安静"
                } else {
                    micAuthorized = true
                    isRecording = true
                    subtitleText = "（ASR 转写中...）"
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
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
    var onPublish: () -> Void = {}

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
                    }
                )
            Text("默认交付 MP4（无需手动让它动起来）")
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
            Button("发布") {
                onPublish()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            VStack(alignment: .leading, spacing: 6) {
                Text("兜底策略")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("风格失败：回退原图 · 小马失败：仅贴图合成 · 视频失败：静帧字幕 MP4")
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

    var body: some View {
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
    }
}
