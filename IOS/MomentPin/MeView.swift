import SwiftUI

struct MeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    NavigationLink(destination: MyMomentsView()) {
                        SectionCard(title: "我的片刻", items: [
                            "私密 2",
                            "匿名公开 1"
                        ])
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: BottlesView()) {
                        SectionCard(title: "漂流瓶", items: [
                            "在漂流中 2",
                            "已靠岸 2",
                            "已捡起 0"
                        ])
                    }
                    .buttonStyle(.plain)

                    SectionCard(title: "设置", items: [
                        "定位权限",
                        "隐私与安全",
                        "举报记录"
                    ])
                    NavigationLink(destination: NotificationsView()) {
                        SectionCard(title: "通知中心", items: [
                            "漂流瓶到期提醒 1",
                            "系统通知 1"
                        ])
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("我")
            .navigationBarTitleDisplayMode(.inline)
        }
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
