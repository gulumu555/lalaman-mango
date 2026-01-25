import SwiftUI

struct NotificationsView: View {
    private let notifications = [
        "你有一个漂流瓶靠岸了 🎁",
        "你在「太古里附近」留下的那段声音，可以打开回听了",
        "系统通知：新版本上线（占位）"
    ]
    private let angelCards = [
        "附近有一个小展：雨天慢下来",
        "回声卡：有人也在「下班路上」说了一句",
        "时间胶囊：三天前的你想对现在说"
    ]
    @State private var readStates: [Int: Bool] = [:]
    @State private var angelReadStates: [Int: Bool] = [:]
    @State private var showAngelCards = true

    var body: some View {
        List {
            Section {
                HStack {
                    Text("未读：\(unreadCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("清空") {}
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if notifications.isEmpty {
                VStack(spacing: 8) {
                    Text("暂无通知")
                        .font(.subheadline)
                    Text("漂流瓶靠岸后会在这里提醒")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowSeparator(.hidden)
            } else {
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
                                Text("打开回听")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("09:30")
                                .font(.caption2)
                                .foregroundColor(.secondary)
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
            Section {
                HStack {
                    Text("天使卡片")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(showAngelCards ? "收起" : "展开") {
                        showAngelCards.toggle()
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if showAngelCards {
                ForEach(Array(angelCards.enumerated()), id: \.offset) { index, item in
                    NavigationLink(destination: AngelCardDetailView(title: item)) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(angelReadStates[index] == true ? Color.clear : Color.blue)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item)
                                    .font(.subheadline)
                                Text(angelReadStates[index] == true ? "已读 · 占位" : "未读 · 占位")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("查看详情")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("10:10")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .onAppear {
                        if angelReadStates[index] == nil {
                            angelReadStates[index] = false
                        }
                    }
                    .onTapGesture {
                        angelReadStates[index] = true
                    }
                }
            }
        }
        .navigationTitle("通知中心")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("全部已读") {
                    for index in notifications.indices {
                        readStates[index] = true
                    }
                }
                .font(.caption)
            }
        }
    }

    private var unreadCount: Int {
        notifications.indices.filter { readStates[$0] != true }.count
    }
}

private struct AngelCardDetailView: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text("这是一个天使卡片占位页")
                .font(.caption)
                .foregroundColor(.secondary)
            Divider()
            if title.contains("回声卡") {
                Text("回声：你的片刻与 TA 的片刻共鸣（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("收下这份回声") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                Button("不需要/别再推类似回声") {}
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if title.contains("小展") {
                Text("附近微展：可浏览片刻列表（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("去看看微展") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
            } else {
                Text("时间胶囊：回访提醒（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("打开回看") {}
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
            }
            Spacer()
        }
        .padding(20)
        .navigationTitle("天使卡片")
        .navigationBarTitleDisplayMode(.inline)
    }
}
