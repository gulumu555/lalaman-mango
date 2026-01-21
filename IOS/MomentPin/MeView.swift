import SwiftUI

struct MeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(title: "我的片刻", items: [
                    "私密（占位）",
                    "匿名公开（占位）"
                ])
                SectionCard(title: "漂流瓶", items: [
                    "在漂流中（占位）",
                    "已靠岸（占位）",
                    "已捡起（占位）"
                ])
                SectionCard(title: "设置", items: [
                    "定位权限（占位）",
                    "隐私与安全（占位）",
                    "举报记录（占位）"
                ])
                SectionCard(title: "通知中心", items: [
                    "漂流瓶到期提醒（占位）",
                    "系统通知（占位）"
                ])
            }
            .padding(20)
        }
        .navigationTitle("我")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}

private struct SectionCard: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}
