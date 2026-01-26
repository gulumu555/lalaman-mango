import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [NotificationSummary] = []
    @State private var angelCards: [AngelCardSummary] = []
    @State private var readStates: [String: Bool] = [:]
    @State private var angelReadStates: [String: Bool] = [:]
    @State private var showAngelCards = true
    @State private var showClearAngelConfirm = false
    @State private var angelStatusHint = ""
    @State private var angelLoading = false
    @State private var angelLastUpdated = "—"
    @State private var showClearNotificationsConfirm = false
    @State private var notificationStatusHint = ""
    @State private var notificationLoading = false
    @State private var notificationLastUpdated = "—"
    @State private var filterEchoOnly = false
    private let apiClient = APIClient()

    var body: some View {
        List {
            Section {
                HStack {
                    Text("未读：\(unreadCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("更新：\(notificationLastUpdated)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("刷新") {
                        notificationLoading = true
                        notificationStatusHint = "刷新中..."
                        apiClient.fetchNotifications { items in
                            notifications = items
                            for item in items where readStates[item.id] == nil {
                                readStates[item.id] = false
                            }
                            notificationLoading = false
                            notificationLastUpdated = currentTimeString()
                            notificationStatusHint = "已刷新（占位）"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                notificationStatusHint = ""
                            }
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    Button("清空") {
                        showClearNotificationsConfirm = true
                    }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if notificationLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("通知加载中...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if !notificationStatusHint.isEmpty {
                Text(notificationStatusHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if notifications.isEmpty {
                VStack(spacing: 8) {
                    Text("暂无通知")
                        .font(.subheadline)
                    Text("漂流瓶靠岸后会在这里提醒")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("重新拉取") {
                        notificationLoading = true
                        notificationStatusHint = "刷新中..."
                        apiClient.fetchNotifications { items in
                            notifications = items
                            for item in items where readStates[item.id] == nil {
                                readStates[item.id] = false
                            }
                            notificationLoading = false
                            notificationLastUpdated = currentTimeString()
                            notificationStatusHint = "已刷新（占位）"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                notificationStatusHint = ""
                            }
                        }
                    }
                    .font(.caption2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowSeparator(.hidden)
            } else {
                ForEach(Array(notifications.enumerated()), id: \.offset) { index, item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(readStates[item.id] == true ? Color.clear : Color.red)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.subheadline)
                                Text(notificationTypeLabel(for: item.type))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(readStates[item.id] == true ? "已读 · 占位" : "未读 · 占位")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("打开回听")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(item.timeText)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .onAppear {
                        if readStates[item.id] == nil {
                            readStates[item.id] = false
                        }
                    }
                    .onTapGesture {
                        readStates[item.id] = true
                    }
                }
            }
            Section {
                HStack {
                    Text("天使卡片")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("未读：\(angelUnreadCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("更新：\(angelLastUpdated)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(filterEchoOnly ? "显示全部" : "只看回声") {
                        filterEchoOnly.toggle()
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    Button("全读") {
                        for card in angelCards {
                            angelReadStates[card.id] = true
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    Button("刷新") {
                        angelLoading = true
                        angelStatusHint = "刷新中..."
                        apiClient.fetchAngelCards { cards in
                            angelCards = cards
                            angelLoading = false
                            angelLastUpdated = currentTimeString()
                            angelStatusHint = "已刷新（占位）"
                            NotificationCenter.default.post(
                                name: .angelCardsUpdated,
                                object: nil,
                                userInfo: ["count": cards.count]
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                angelStatusHint = ""
                            }
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    Button("清空") {
                        showClearAngelConfirm = true
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    Button(showAngelCards ? "收起" : "展开") {
                        showAngelCards.toggle()
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            if showAngelCards {
                if angelLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("加载中...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                if filterEchoOnly {
                    Text("筛选：仅回声卡")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                if !angelStatusHint.isEmpty {
                    Text(angelStatusHint)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                if displayedAngelCards.isEmpty && !angelLoading {
                    VStack(spacing: 6) {
                        Text("暂无天使卡片")
                            .font(.subheadline)
                        Text(filterEchoOnly ? "当前仅看回声卡，暂无匹配" : "开启天使模式后，回声/微展会出现在这里")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button("重新拉取") {
                            angelLoading = true
                            angelStatusHint = "刷新中..."
                            apiClient.fetchAngelCards { cards in
                                angelCards = cards
                                angelLoading = false
                                angelLastUpdated = currentTimeString()
                                angelStatusHint = "已刷新（占位）"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    angelStatusHint = ""
                                }
                            }
                        }
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(999)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowSeparator(.hidden)
                }
                ForEach(Array(displayedAngelCards.enumerated()), id: \.offset) { index, item in
                    NavigationLink(destination: AngelCardDetailView(title: item.title, type: item.type)) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(angelReadStates[item.id] == true ? Color.clear : Color.blue)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.subheadline)
                                Text(typeLabel(for: item.type))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(angelReadStates[item.id] == true ? "已读 · 占位" : "未读 · 占位")
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
                        if angelReadStates[item.id] == nil {
                            angelReadStates[item.id] = false
                        }
                    }
                    .onTapGesture {
                        angelReadStates[item.id] = true
                    }
                }
            }
        }
        .navigationTitle("通知中心")
        .navigationBarTitleDisplayMode(.inline)
        .alert("清空天使卡片？", isPresented: $showClearAngelConfirm) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                angelCards.removeAll()
            }
        } message: {
            Text("该操作只清空占位列表，可稍后重新拉取。")
        }
        .alert("清空通知？", isPresented: $showClearNotificationsConfirm) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                notifications.removeAll()
                readStates.removeAll()
            }
        } message: {
            Text("该操作只清空占位通知列表。")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("全部已读") {
                    for item in notifications {
                        readStates[item.id] = true
                    }
                    for card in angelCards {
                        angelReadStates[card.id] = true
                    }
                }
                .font(.caption)
            }
        }
        .onAppear {
            notificationLoading = true
            apiClient.fetchNotifications { items in
                notifications = items
                for item in items where readStates[item.id] == nil {
                    readStates[item.id] = false
                }
                notificationLoading = false
                notificationLastUpdated = currentTimeString()
            }
            angelLoading = true
            apiClient.fetchAngelCards { cards in
                angelCards = cards
                angelLoading = false
                angelLastUpdated = currentTimeString()
                NotificationCenter.default.post(
                    name: .angelCardsUpdated,
                    object: nil,
                    userInfo: ["count": cards.count]
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    angelStatusHint = ""
                }
            }
        }
    }

    private var unreadCount: Int {
        notifications.filter { readStates[$0.id] != true }.count
    }

    private var angelUnreadCount: Int {
        angelCards.filter { angelReadStates[$0.id] != true }.count
    }

    private func notificationTypeLabel(for type: String) -> String {
        switch type {
        case "bottle":
            return "漂流瓶通知"
        case "system":
            return "系统通知"
        default:
            return "通知"
        }
    }

    private var displayedAngelCards: [AngelCardSummary] {
        if filterEchoOnly {
            return angelCards.filter { $0.type == "echo" }
        }
        return angelCards
    }

    private func typeLabel(for type: String) -> String {
        switch type {
        case "echo":
            return "回声卡"
        case "microcuration":
            return "附近微展"
        case "timecapsule":
            return "时间胶囊"
        default:
            return "天使卡片"
        }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

private struct AngelCardDetailView: View {
    let title: String
    let type: String
    @State private var actionHint = ""
    private let apiClient = APIClient()
    @State private var showCreate = false
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text("这是一个天使卡片占位页")
                .font(.caption)
                .foregroundColor(.secondary)
            if !actionHint.isEmpty {
                Text(actionHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Divider()
            if type == "echo" {
                Text("回声：你的片刻与 TA 的片刻共鸣（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("收下这份回声") {
                    actionHint = "正在收下回声..."
                    apiClient.createEchoCard { result in
                        switch result {
                        case .success:
                            actionHint = "回声已收下（占位）"
                            showDetail = true
                        case .failure:
                            actionHint = "回声保存失败（占位）"
                        }
                    }
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
                Button("不需要/别再推类似回声") {}
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        actionHint = "正在降低推荐..."
                        apiClient.dismissEchoCard { result in
                            switch result {
                            case .success:
                                actionHint = "已降低类似回声推荐（占位）"
                            case .failure:
                                actionHint = "操作失败（占位）"
                            }
                        }
                    }
            } else if type == "microcuration" {
                Text("附近微展：可浏览片刻列表（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button("去看看微展") {
                    showDetail = true
                }
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
                Button("打开回看") {
                    actionHint = "已打开回看（占位）"
                    showDetail = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
                Button("今天不看/别再提醒这条") {
                    actionHint = "正在关闭提醒..."
                    apiClient.updateTimecapsule(enabled: false) { result in
                        switch result {
                        case .success:
                            actionHint = "已关闭该条提醒（占位）"
                        case .failure:
                            actionHint = "关闭失败（占位）"
                        }
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                Button("我也想再做一条") {
                    showCreate = true
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .navigationTitle("天使卡片")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCreate) {
            CreateView()
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                DetailView(moment: Moment.sample.first!)
            }
        }
    }
}
