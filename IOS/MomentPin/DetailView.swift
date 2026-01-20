import SwiftUI

struct DetailView: View {
    let moment: Moment

    @State private var isPublic = true
    @State private var selectedReaction: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 280)
                    .cornerRadius(16)
                    .overlay(
                        Text("视频播放区 (MP4 + 声波)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(moment.moodEmoji) \(moment.title)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(moment.zoneName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("2025-春节前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ReactionRow(selectedReaction: $selectedReaction)

                TemplateReplies()

                ShareRetrySection()

                AuthorActions(isPublic: $isPublic)

                ModerationSection()
            }
            .padding(20)
        }
        .navigationTitle("片刻")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ReactionRow: View {
    @Binding var selectedReaction: String?

    private let reactions = ["🫶", "🥺", "🙂", "😮‍💨", "✨", "👏"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("反应")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(reactions, id: \.self) { emoji in
                    Button {
                        selectedReaction = emoji
                    } label: {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 48, height: 48)
                            .background(selectedReaction == emoji ? Color.black.opacity(0.1) : Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TemplateReplies: View {
    private let templates = [
        "抱抱你", "今天也很棒", "慢慢来", "给你一点好运", "辛苦啦", "再试一次"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("模板回应")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                ForEach(templates, id: \.self) { text in
                    Button(text) {}
                        .font(.caption)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AuthorActions: View {
    @Binding var isPublic: Bool

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
                Button("删除") {}
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("风控")
                .font(.headline)
            HStack(spacing: 12) {
                Button("举报") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Button("屏蔽") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Button("拉黑") {}
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

private struct ShareRetrySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("导出与重试")
                .font(.headline)
            HStack(spacing: 12) {
                Button("导出/分享") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
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
            }
            Text("失败时仅重试渲染，不重复创建")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
