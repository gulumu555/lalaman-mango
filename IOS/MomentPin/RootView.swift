import SwiftUI

struct RootView: View {
    enum Tab {
        case nearby
        case create
        case me
    }

    @State private var selectedTab: Tab = .nearby
    @State private var showCreate = false

    var body: some View {
        ZStack {
            switch selectedTab {
            case .nearby:
                NearbyView()
            case .create:
                NearbyView()
            case .me:
                MeView()
            }

            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab) {
                    showCreate = true
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 6) {
                    Text("首页地图为背景 · 中间 + 开始创作")
                    Text("底部仅三栏：附近 / + / 我（占位）")
                    Text("进入创作即进入主流程（占位）")
                    Text("不显示聊天入口（占位）")
                    Text("地图默认 3km（占位）")
                    Text("地图为默认背景层（占位）")
                    Text("点位可进入详情（占位）")
                    Text("隐私优先（占位）")
                    Text("共鸣触发光点反馈（占位）")
                    Text("共鸣触发轻震动（占位）")
                    Text("发布后才可公开（占位）")
                    Text("未渲染不可发布（占位）")
                    Text("AI 默认隐身（占位）")
                    Text("AI 卡片一次性出现（占位）")
                    Text("8 秒无操作自动退场（占位）")
                    Text("底部按钮不打断地图（占位）")
                    Text("轻互动替代评论区（占位）")
                    Text("不提供私信入口（占位）")
                    Text("隐私优先于网络效应（占位）")
                    Text("地图不展示私密内容（占位）")
                    Text("地图不展示漂流瓶（占位）")
                    Text("GIF 仅导出选项（占位）")
                    Text("最终形态 MP4（占位）")
                    Text("语音为最高价值（占位）")
                    Text("AI 不抢戏（占位）")
                    Text("克制胜过炫技（占位）")
                    Text("内容以真实语音为核（占位）")
                    Text("不做强社交（占位）")
                    Text("不做长评论（占位）")
                    Text("轻互动替代评论区（占位）")
                    Text("仅三种互动（占位）")
                    Text("AI 卡片不常驻（占位）")
                    Text("AI 不主动私聊（占位）")
                    Text("地图层不过度信息（占位）")
                    Text("内容不做外部推荐（占位）")
                    Text("地图层不显示敏感（占位）")
                    Text("地图层不显示私密（占位）")
                    Text("地图层不显示漂流瓶（占位）")
                    Text("地图层仅匿名（占位）")
                    Text("地图层仅短内容（占位）")
                    Text("地图层仅轻互动（占位）")
                    Text("地图层仅低频提示（占位）")
                    Text("地图层不打断流程（占位）")
                    Text("地图层不展示私信（占位）")
                    Text("地图层不展示评论（占位）")
                    Text("地图层不展示关注（占位）")
                    Text("地图层不展示头像（占位）")
                    Text("地图层不展示昵称（占位）")
                    Text("地图层不展示距离（占位）")
                    Text("地图层不展示关系链（占位）")
                    Text("地图层不展示外链（占位）")
                    Text("地图层不展示评论区（占位）")
                    Text("地图层不展示私信（占位）")
                    Text("地图层不展示关注（占位）")
                    Text("地图层不展示粉丝（占位）")
                    Text("地图层不展示点赞（占位）")
                    Text("地图层不展示分享（占位）")
                    Text("地图层不展示转发（占位）")
                    Text("地图层不展示广告（占位）")
                    Text("地图层不展示波形（占位）")
                    Text("地图层不展示聊天入口（占位）")
                    Text("地图层不展示评论入口（占位）")
                    Text("地图层不展示私聊入口（占位）")
                    Text("地图层不展示关注入口（占位）")
                    Text("地图层不展示分享入口（占位）")
                    Text("地图层不展示转发入口（占位）")
                    Text("地图层不展示点赞入口（占位）")
                    Text("地图层不展示收藏入口（占位）")
                    Text("地图层不展示举报入口（占位）")
                    Text("地图层不展示拉黑入口（占位）")
                    Text("地图层不展示活动入口（占位）")
                    Text("地图层不展示交易入口（占位）")
                    Text("地图层不展示外链入口（占位）")
                    Text("地图层不展示群聊入口（占位）")
                    Text("地图层不展示分享按钮（占位）")
                    Text("地图层不展示认证入口（占位）")
                    Text("地图层不展示实名入口（占位）")
                    Text("地图层不展示位置入口（占位）")
                    Text("地图层不展示轨迹入口（占位）")
                    Text("地图层不展示认证入口（占位）")
                    Text("地图层不展示实名入口（占位）")
                    Text("地图层不展示设备入口（占位）")
                    Text("地图层不展示身份入口（占位）")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .padding(.bottom, 110)
            }
        }
        .ignoresSafeArea(edges: [.bottom])
        .fullScreenCover(isPresented: $showCreate) {
            CreateView(onPublished: {
                showCreate = false
                selectedTab = .nearby
            })
        }
    }
}

private struct BottomBar: View {
    @Binding var selectedTab: RootView.Tab
    var onCreate: () -> Void = {}

    var body: some View {
        HStack(spacing: 24) {
            Button {
                selectedTab = .nearby
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
            }

            Button {
                onCreate()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .bold))
                    .frame(width: 76, height: 76)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 8)
            }

            Button {
                selectedTab = .me
            } label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 28)
    }
}
