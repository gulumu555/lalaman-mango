import SwiftUI

struct MeView: View {
    @State private var showAngelSettings = false
    @State private var notificationCount = 0
    @State private var angelCardCount = 0
    @State private var angelStatusLabel = "天使模式：关闭"
    @State private var horseStatusLabel = "马年足迹：关闭"
    @State private var notificationUpdatedLabel = "通知更新时间：—"
    @State private var angelUpdatedLabel = "天使更新时间：—"
    private let apiClient = APIClient()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    NavigationLink(destination: MyMomentsView()) {
                        SectionCard(title: "我的片刻", items: [
                            "私密 2",
                            "匿名公开 1",
                            "地图足迹（占位）"
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
                    Text("AI 仅做桥梁，不常驻聊天（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("隐私优先于网络效应（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("黑名单管理后置（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("天使默认关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("定位权限影响附近内容（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("隐私设置可随时调整（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("设置项将逐步完善（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("AI 卡片不会常驻（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("仅动作卡，不做聊天（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("隐私设置优先级最高（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容才可被看见（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("私密内容仅自己可见（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("漂流瓶默认不展示地图（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("时间胶囊可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("天使频控每日一次（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("AI 只在必要时出现（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("隐私设置覆盖所有行为（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("发布后可随时改权限（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("收藏仅自己可见（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("回声可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("时间胶囊可静默（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("退出活动即隐藏足迹（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("账号迁移需手动确认（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("数据仅用于本产品（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("语音默认不做公开索引（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地理信息可隐藏（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("匿名公开不显示身份（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("回声不显示距离（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("回声可手动关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展可手动关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("内容默认私密（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开需手动开启（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("发布后可改可见性（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("音频可选择保留（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("字幕可关闭显示（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("历史记录可导出（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("历史记录可删除（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("隐私政策可查看（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("使用协议可查看（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("权限变更需确认（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("定位权限可随时撤回（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("音频保存可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("字幕默认开启（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("字幕可手动修正（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被回声（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("私密内容不被回声（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("私密内容不被微展（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("私密内容不被时间胶囊提醒（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被微展（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被回声（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被时间胶囊（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被收藏（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("公开内容可被共鸣（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button {
                        showAngelSettings = true
                    } label: {
                        SectionCard(title: "天使 / 马年设置", items: [
                            angelStatusLabel,
                            "回声 / 微展 / 时间胶囊",
                            horseStatusLabel
                        ])
                    }
                    .buttonStyle(.plain)
                    NavigationLink(destination: NotificationsView()) {
                        SectionCard(title: "通知中心", items: [
                            "通知 \(notificationCount)",
                            "天使卡片 \(angelCardCount)",
                            notificationUpdatedLabel,
                            angelUpdatedLabel
                        ])
                    }
                    .buttonStyle(.plain)
                    Text("红点仅站内提示（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("通知可手动刷新（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("通知不推送系统提醒（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("仅站内查看通知（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("版本号：0.1.0（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(20)
            }
            .navigationTitle("我")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.white)
        .sheet(isPresented: $showAngelSettings) {
            AngelSettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userSettingsUpdated)) { _ in
            apiClient.fetchUserSettings { payload in
                angelStatusLabel = payload.allowAngel ? "天使模式：开启" : "天使模式：关闭"
                horseStatusLabel = payload.horseTrailEnabled ? "马年足迹：开启" : "马年足迹：关闭"
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationsUpdated)) { notification in
            if let count = notification.userInfo?["count"] as? Int {
                notificationCount = count
            }
            notificationUpdatedLabel = "通知更新时间：\(currentTimeString())"
        }
        .onReceive(NotificationCenter.default.publisher(for: .angelCardsUpdated)) { notification in
            if let count = notification.userInfo?["count"] as? Int {
                angelCardCount = count
            }
            angelUpdatedLabel = "天使更新时间：\(currentTimeString())"
        }
        .onAppear {
            apiClient.fetchNotifications { items in
                notificationCount = items.count
                notificationUpdatedLabel = "通知更新时间：\(currentTimeString())"
            }
            apiClient.fetchAngelCards { cards in
                angelCardCount = cards.count
                angelUpdatedLabel = "天使更新时间：\(currentTimeString())"
            }
            apiClient.fetchUserSettings { payload in
                angelStatusLabel = payload.allowAngel ? "天使模式：开启" : "天使模式：关闭"
                horseStatusLabel = payload.horseTrailEnabled ? "马年足迹：开启" : "马年足迹：关闭"
            }
        }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
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

private struct AngelSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allowAngel = false
    @State private var allowMicrocuration = false
    @State private var allowEcho = false
    @State private var allowTimecapsule = true
    @State private var horseTrailEnabled = false
    @State private var horseWitnessEnabled = false
    @State private var saveHint = ""
    private let apiClient = APIClient()
    @State private var settingsLoaded = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("天使系统")
                    .font(.headline)
                Toggle("让天使偶尔路过", isOn: $allowAngel)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("允许微展收录", isOn: $allowMicrocuration)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .disabled(!allowAngel)
                Toggle("允许回声共鸣", isOn: $allowEcho)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .disabled(!allowAngel)
                Toggle("允许时间胶囊回访", isOn: $allowTimecapsule)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .disabled(!allowAngel)

                Divider()

                Text("马年活动")
                    .font(.headline)
                Toggle("加入马年足迹", isOn: $horseTrailEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Toggle("马年见证", isOn: $horseWitnessEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                Text("天使模式默认关闭（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("微展/回声需逐条授权（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("时间胶囊默认开启（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("天使强度仅低档（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("每日最多一次天使卡（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("点空白处 8 秒退场（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("关闭后不再触发（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("设置仅对当前账号生效（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("设置保存为占位，后续接入 API")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if !saveHint.isEmpty {
                    Text(saveHint)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Button("保存设置") {
                    saveHint = "正在保存..."
                    apiClient.saveUserSettings(
                        payload: UserSettingsPayload(
                            allowMicrocuration: allowMicrocuration,
                            allowEcho: allowEcho,
                            allowTimecapsule: allowTimecapsule,
                            allowAngel: allowAngel,
                            horseTrailEnabled: horseTrailEnabled,
                            horseWitnessEnabled: horseWitnessEnabled
                        )
                    ) { result in
                        switch result {
                        case .success:
                            saveHint = "已保存（占位）"
                            NotificationCenter.default.post(name: .userSettingsUpdated, object: nil)
                        case .failure:
                            saveHint = "保存失败（占位）"
                        }
                    }
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)

                Spacer()
            }
            .padding(20)
            .navigationTitle("天使与马年")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                        .font(.caption)
                }
            }
            .onAppear {
                guard !settingsLoaded else { return }
                settingsLoaded = true
                apiClient.fetchUserSettings { payload in
                    allowAngel = payload.allowAngel
                    allowMicrocuration = payload.allowMicrocuration
                    allowEcho = payload.allowEcho
                    allowTimecapsule = payload.allowTimecapsule
                    horseTrailEnabled = payload.horseTrailEnabled
                    horseWitnessEnabled = payload.horseWitnessEnabled
                }
            }
        }
    }
}
