import SwiftUI

struct MeView: View {
    @State private var showAngelSettings = false
    @State private var notificationCount = 0
    @State private var angelCardCount = 0
    @State private var angelStatusLabel = "天使模式：关闭"
    @State private var horseStatusLabel = "马年足迹：关闭"
    private let apiClient = APIClient()

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
                            "天使卡片 \(angelCardCount)"
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
        .sheet(isPresented: $showAngelSettings) {
            AngelSettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userSettingsUpdated)) { _ in
            apiClient.fetchUserSettings { payload in
                angelStatusLabel = payload.allowAngel ? "天使模式：开启" : "天使模式：关闭"
                horseStatusLabel = payload.horseTrailEnabled ? "马年足迹：开启" : "马年足迹：关闭"
            }
        }
        .onAppear {
            apiClient.fetchNotifications { items in
                notificationCount = items.count
            }
            apiClient.fetchAngelCards { cards in
                angelCardCount = cards.count
            }
            apiClient.fetchUserSettings { payload in
                angelStatusLabel = payload.allowAngel ? "天使模式：开启" : "天使模式：关闭"
                horseStatusLabel = payload.horseTrailEnabled ? "马年足迹：开启" : "马年足迹：关闭"
            }
        }
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
