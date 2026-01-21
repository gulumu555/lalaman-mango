import SwiftUI

struct DetailView: View {
    let moment: Moment

    @State private var isPublic = true
    @State private var selectedReaction: String? = nil
    @State private var selectedTemplate: String? = nil
    @State private var showFeedback = false
    @State private var showModerationSheet = false
    @State private var showDeleteConfirm = false
    @State private var isInteractive = true
    @State private var visibilityHint = "仅匿名公开可互动（占位）"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 280)
                        .cornerRadius(16)
                        .overlay(
                            Text("视频播放区 (MP4 + 声波)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                    HStack {
                        Text("声波占位")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("时长 0:08")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(moment.moodEmoji) \(moment.title)")
                        .font(.title3)
                        .fontWeight(.semibold)
                Text(isPublic ? "匿名公开" : "仅自己")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                    .onChange(of: isPublic) { value in
                        visibilityHint = value ? "匿名公开可互动" : "仅自己，互动关闭"
                        isInteractive = value
                    }
                    Text(moment.zoneName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("2025-春节前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ReactionRow(selectedReaction: $selectedReaction, isEnabled: isInteractive && isPublic) {
                    showFeedback = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showFeedback = false
                    }
                }

                TemplateReplies(selectedTemplate: $selectedTemplate, isEnabled: isInteractive && isPublic) {
                    showFeedback = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showFeedback = false
                    }
                }
                Text("模板回应：每日最多 1 条（占位）")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("仅模板回应（无评论区）")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ShareRetrySection()

                BottleSection()

                AuthorActions(isPublic: $isPublic) {
                    showDeleteConfirm = true
                }

                ModerationSection {
                    showModerationSheet = true
                }

                Text(visibilityHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if showFeedback {
                    Text("已发送")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Toggle("互动开关（占位）", isOn: $isInteractive)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
            }
            .padding(20)
        }
        .navigationTitle("片刻")
        .navigationBarTitleDisplayMode(.inline)
        .alert("风控", isPresented: $showModerationSheet) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("举报/屏蔽/拉黑占位，后续接入逻辑")
        }
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) {}
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后不可恢复（占位）")
        }
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
                        .frame(width: 52, height: 60)
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
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                            .font(.caption)
                            .padding(.vertical, 8)
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

private struct AuthorActions: View {
    @Binding var isPublic: Bool
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("作者控制")
                .font(.headline)
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
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

private struct ModerationSection: View {
    var onOpen: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("风控")
                .font(.headline)
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
            if includeBottle {
                HStack {
                    Text("靠岸时间")
                    Spacer()
                    Button(openDate, style: .date) {
                        showDatePicker.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            if showShareHint {
                Text("系统分享（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
