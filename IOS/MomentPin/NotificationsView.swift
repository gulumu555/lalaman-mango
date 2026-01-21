import SwiftUI

struct NotificationsView: View {
    private let notifications = [
        "你有一个漂流瓶靠岸了 🎁",
        "你在「太古里附近」留下的那段声音，可以打开回听了",
        "系统通知：新版本上线（占位）"
    ]

    var body: some View {
        List {
            ForEach(notifications, id: \.self) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item)
                        .font(.subheadline)
                    Text("刚刚 · 占位")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("通知中心")
        .navigationBarTitleDisplayMode(.inline)
    }
}
