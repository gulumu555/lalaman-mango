import SwiftUI

struct CreateView: View {
    var presetZoneName: String? = nil
    var onPublished: () -> Void = {}
    enum Step: Int, CaseIterable {
        case photo = 1
        case style = 2
        case voice = 3
    }

    @State private var step: Step = .photo
    @State private var isPublic = false
    @State private var includeBottle = false
    @State private var showDetail = false
    @State private var showGenerating = false
    @State private var showPublished = false
    @State private var showPublishSheet = false
    private let previewMoment = Moment.sample.first!
    @State private var draftStyle = "治愈A"
    @State private var hasVoice = false
    @State private var hasPhoto = false

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(step: step)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            StepDots(step: step)
                .padding(.top, 8)

            TabView(selection: $step) {
                PhotoStep(hasPhoto: $hasPhoto)
                    .tag(Step.photo)
                StyleStep(selectedStyle: $draftStyle)
                    .tag(Step.style)
                VoiceStep(hasVoice: $hasVoice)
                    .tag(Step.voice)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Text("发布时可设置可见性/漂流瓶")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            StepControls(
                step: $step,
                canProceed: canProceed,
                onPublish: {
                showPublishSheet = true
            })
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
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
                    Text("失败会自动降级为静图+声波")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("资源说明：照片 + 语音 + 动效模板")
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
        case .photo:
            return hasPhoto
        case .style:
            return true
        case .voice:
            return hasVoice
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
            Text("Step \(step.rawValue)/3")
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
                        Text(Date(), style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
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

private struct PhotoStep: View {
    @Binding var hasPhoto: Bool
    @State private var photoHint = "未选择照片"
    @State private var cameraAuthorized = false
    @State private var albumAuthorized = false

    var body: some View {
        VStack(spacing: 16) {
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
                .frame(height: 240)
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
            HStack(spacing: 12) {
                Button("裁切") {}
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Button("旋转") {}
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                    .cornerRadius(999)
            }
            HStack(spacing: 12) {
                Button("移除") {
                    hasPhoto = false
                    photoHint = "未选择照片"
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
                .disabled(!hasPhoto)
                Text(photoHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if !cameraAuthorized || !albumAuthorized {
                Text("需要相机/相册权限（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
    }
}

private struct StyleStep: View {
    private let styles = ["治愈A", "治愈B", "治愈C", "治愈D"]
    @State private var rotationHint = "模板：T02_Cloud"
    @Binding var selectedStyle: String

    var body: some View {
        VStack(spacing: 16) {
            Text("选择风格")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(rotationHint)
                .font(.caption)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 180)
                .cornerRadius(16)
                .overlay(
                    Text("风格预览（占位）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                ForEach(styles, id: \.self) { style in
                    Button {
                        selectedStyle = style
                        rotationHint = "模板：\(style)"
                    } label: {
                        Text(style)
                            .font(.caption)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(selectedStyle == style ? Color.black.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            Toggle("马年小马同框", isOn: .constant(true))
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .padding(.top, 8)
            Text("默认开启，可切换姿态（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)

            Button("再来一个") {
                rotationHint = "模板：T0\(Int.random(in: 1...8))_Random"
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
        }
        .padding(20)
    }
}

private struct VoiceStep: View {
    @Binding var hasVoice: Bool
    @State private var recordHint = "未录音"
    @State private var isRecording = false
    @State private var micAuthorized = false

    var body: some View {
        VStack(spacing: 16) {
            Text("录一段语音（3-8秒）")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("建议 3–8 秒，上限 15 秒")
                .font(.caption)
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
                .fill(Color.gray.opacity(0.15))
                .frame(height: 180)
                .cornerRadius(16)
                .overlay(
                    Text(isRecording ? "声波录制中..." : "声波占位")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
            Button(isRecording ? "停止录音" : "开始录音") {
                if isRecording {
                    isRecording = false
                    hasVoice = true
                    recordHint = "已录 0:08"
                } else {
                    micAuthorized = true
                    isRecording = true
                }
            }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
            HStack(spacing: 12) {
                Button("试听") {}
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
                Button("重录") {
                    hasVoice = false
                    isRecording = false
                    recordHint = "未录音"
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
            }
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

private struct PublishSettings: View {
    @Binding var isPublic: Bool
    @Binding var includeBottle: Bool
    let presetZoneName: String?
    @State private var showDatePicker = false
    @State private var openDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var hideLocation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("发布设置")
                .font(.headline)
            Text("隐私")
                .font(.subheadline)
            Toggle("匿名公开", isOn: $isPublic)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Toggle("隐藏位置", isOn: $hideLocation)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Text(isPublic ? "匿名公开可互动" : "默认仅自己可见（占位）")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("开启隐藏后仅显示商圈/区域级位置")
                .font(.caption2)
                .foregroundColor(.secondary)

            Divider().padding(.vertical, 4)

            Text("漂流瓶")
                .font(.subheadline)
            Toggle("放进漂流瓶", isOn: $includeBottle)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            VStack(alignment: .leading, spacing: 12) {
                if includeBottle {
                    Text("靠岸时间到期后会通知你回听")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let presetZoneName {
                    Text("地点：\(presetZoneName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
                    }
                    Button("3个月后") {
                        openDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? openDate
                    }
                    Button("自定义") {
                        showDatePicker.toggle()
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)
                if showDatePicker {
                    DatePicker(
                        "选择日期",
                        selection: $openDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
            }
            .opacity(includeBottle ? 1.0 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: includeBottle)
            .allowsHitTesting(includeBottle)
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

private struct StepControls: View {
    @Binding var step: CreateView.Step
    var canProceed: Bool = true
    var onPublish: () -> Void = {}

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
            .disabled(step == .photo)

            Button(step == .voice ? "发布" : "下一步") {
                if step == .voice {
                    onPublish()
                } else if let next = CreateView.Step(rawValue: step.rawValue + 1) {
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
            .disabled(!canProceed)
        }
    }
}
