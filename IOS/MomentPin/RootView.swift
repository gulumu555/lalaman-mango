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
                    Text("AI 默认隐身，轻互动替代评论区（占位）")
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
