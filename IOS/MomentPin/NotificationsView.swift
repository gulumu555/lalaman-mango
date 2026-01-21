import SwiftUI

struct NotificationsView: View {
    private let notifications = [
        "你有一个漂流瓶靠岸了 🎁",
        "你在「太古里附近」留下的那段声音，可以打开回听了",
        "系统通知：新版本上线（占位）"
    ]
    @State private var readStates: [Int: Bool] = [:]

    var body: some View {
        List {
            ForEach(Array(notifications.enumerated()), id: \.offset) { index, item in
                NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(readStates[index] == true ? Color.clear : Color.red)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item)
                                .font(.subheadline)
                            Text(readStates[index] == true ? "已读 · 占位" : "未读 · 占位")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .onAppear {
                    if readStates[index] == nil {
                        readStates[index] = false
                    }
                }
                .onTapGesture {
                    readStates[index] = true
                }
            }
        }
        .navigationTitle("通知中心")
        .navigationBarTitleDisplayMode(.inline)
    }
}
