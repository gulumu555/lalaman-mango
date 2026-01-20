import SwiftUI

struct RootView: View {
    enum Tab {
        case nearby
        case create
        case me
    }

    @State private var selectedTab: Tab = .nearby

    var body: some View {
        ZStack {
            switch selectedTab {
            case .nearby:
                NearbyView()
            case .create:
                CreateView(onPublished: {
                    selectedTab = .nearby
                })
            case .me:
                MeView()
            }

            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: [.bottom])
    }
}

private struct BottomBar: View {
    @Binding var selectedTab: RootView.Tab

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
                selectedTab = .create
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

private struct MeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("我的")
                .font(.title2)
            Text("片刻 / 漂流瓶 / 设置")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
