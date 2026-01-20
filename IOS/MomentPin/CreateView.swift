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
    private let previewMoment = Moment.sample.first!

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(step: step)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            TabView(selection: $step) {
                PhotoStep()
                    .tag(Step.photo)
                StyleStep()
                    .tag(Step.style)
                VoiceStep()
                    .tag(Step.voice)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PublishSettings(isPublic: $isPublic, includeBottle: $includeBottle, presetZoneName: presetZoneName)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            StepControls(step: $step, onPublish: {
                showGenerating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showGenerating = false
                    showDetail = true
                }
            })
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
        }
        .background(Color.white)
        .overlay {
            if showGenerating {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("生成中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            NavigationStack {
                DetailView(moment: previewMoment)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("完成") {
                                showDetail = false
                                onPublished()
                            }
                        }
                    }
            }
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

private struct PhotoStep: View {
    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 240)
                .cornerRadius(16)
                .overlay(
                    Text("选择照片 / 拍照（占位）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
            Button("选择照片") {}
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

private struct StyleStep: View {
    private let styles = ["治愈A", "治愈B", "治愈C", "治愈D"]
    @State private var rotationHint = "模板：T02_Cloud"

    var body: some View {
        VStack(spacing: 16) {
            Text("选择风格")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(rotationHint)
                .font(.caption)
                .foregroundColor(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                ForEach(styles, id: \.self) { style in
                    Text(style)
                        .font(.caption)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            Toggle("马年小马同框", isOn: .constant(true))
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .padding(.top, 8)

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
    var body: some View {
        VStack(spacing: 16) {
            Text("录一段语音（3-8秒）")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 180)
                .cornerRadius(16)
                .overlay(
                    Text("语音录制占位")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
            Button("按住录音") {}
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

private struct PublishSettings: View {
    @Binding var isPublic: Bool
    @Binding var includeBottle: Bool
    let presetZoneName: String?
    @State private var showDatePicker = false
    @State private var openDate = Date().addingTimeInterval(60 * 60 * 24 * 30)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("发布设置")
                .font(.headline)
            Toggle("匿名公开", isOn: $isPublic)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Toggle("放进漂流瓶", isOn: $includeBottle)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            if let presetZoneName {
                Text("地点：\(presetZoneName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("靠岸时间")
                Spacer()
                Button(openDate, style: .date) {
                    showDatePicker.toggle()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            if showDatePicker {
                DatePicker(
                    "选择日期",
                    selection: $openDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

private struct StepControls: View {
    @Binding var step: CreateView.Step
    var onPublish: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
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
        }
    }
}
