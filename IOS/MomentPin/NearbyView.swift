import SwiftUI
import MapKit

struct NearbyView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0800),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    @State private var showPlaceSheet = false
    @State private var selectedMoment: Moment? = nil
    @State private var selectedMomentId: UUID? = nil
    @State private var selectedZoneName: String? = nil
    @State private var showCreate = false
    @State private var showDetail = false
    @State private var moodFilter: MoodFilter? = nil
    @State private var showMoodSheet = false
    @State private var showListSheet = false
    @State private var showMoodCard = true
    @State private var showLocationHint = false
    @State private var locationHintText = "已定位"
    @State private var locationStatus = "定位中..."
    @State private var showAngelSheet = false
    @State private var showExhibitSheet = false
    @State private var exhibits: [ExhibitSummary] = []
    private let apiClient = APIClient()
    @State private var exhibitHint = ""
    @State private var angelHint = ""
    @State private var angelCardCount = 0

    private let moments: [Moment] = Moment.sample
    private var filteredMoments: [Moment] {
        guard let moodFilter else { return moments }
        if moodFilter == .all { return moments }
        return moments.filter { moodFilter.match(emoji: $0.moodEmoji) }
    }
    private var bubbleMoments: [Moment] {
        Array(filteredMoments.prefix(3))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: filteredMoments) { moment in
                MapAnnotation(coordinate: moment.coordinate) {
                    Button {
                        selectedMoment = moment
                        selectedZoneName = moment.zoneName
                        selectedMomentId = moment.id
                        showPlaceSheet = true
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    } label: {
                        Text("\(moment.count)")
                            .font(.caption2)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(999)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 3)
                    }
                }
            }
                .ignoresSafeArea()

                LinearGradient(
                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.45), Color.white.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Text("附近 3km · \(locationStatus)")
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(999)
                        Spacer()
                        Button {
                            locationHintText = "已定位"
                            showLocationHint = true
                            locationStatus = "已定位"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showLocationHint = false
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.footnote)
                                Text("定位")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(999)
                        }
                        Button("刷新") {
                            locationHintText = "已刷新"
                            showLocationHint = true
                            locationStatus = "已定位"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                showLocationHint = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                locationStatus = "已定位"
                            }
                        }
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(999)
                    }
                    Text("地图为底图背景（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("刷新会重新拉取附近数据（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("默认展示公开片刻（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("漂流瓶不在地图展示（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展入口在地图层（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位聚合展示数量（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("共鸣会触发光点反馈（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("共鸣触发轻震动（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图不做聊天入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层支持马年足迹（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图仅展示匿名公开（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("AI 只在卡片出现（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位为轻量交互入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("情绪天气非强运营（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅显示聚合（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位列表可下拉（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位抽屉为轻量（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位点击进入详情（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图不展示私密（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图不展示漂流瓶（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图可隐藏位置（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图入口不打断（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展卡片可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("回声卡片可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("附近微展可手动打开（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展不做强推荐（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图仅展示近 3km（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位为轻量入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位列表最多 12 条（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层支持情绪过滤（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层支持刷新（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层不显示私密（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层不显示漂流瓶（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层仅公开内容（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层支持轻反馈（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层不做聊天入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图层仅匿名展示（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不过度密集（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位按主题聚合（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位按时间过滤（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅展示预览（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不显示头像（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不显示昵称（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不显示距离（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不显示评论（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位轻量卡片（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不引导聊天（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位可关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位支持刷新（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位支持过滤（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示评论（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示点赞（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示转发（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示关注（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示私信（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示评论区（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示收藏（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示分享（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示举报（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示拉黑（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅展示片刻标题（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅展示情绪标签（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅展示时长（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位仅展示时间（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示声音波形（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示头像昵称（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示评论入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示私信入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示关注入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示分享入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示转发入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示点赞入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示收藏入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示举报入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示拉黑入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示广告入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示活动入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示外链入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示交易入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示群聊入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示认证入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示实名入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示位置入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示轨迹入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示认证入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示实名入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示设备入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示身份入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示认证入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示实名入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示位置入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示轨迹入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图点位不展示设备入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if !bubbleMoments.isEmpty {
                        HStack(spacing: 8) {
                            Text("点位")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ForEach(bubbleMoments) { moment in
                                Button {
                                    selectedMoment = moment
                                    selectedZoneName = moment.zoneName
                                    selectedMomentId = moment.id
                                    showPlaceSheet = true
                                } label: {
                                    Text("\(moment.count)")
                                        .font(.caption2)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Color.white)
                                        .cornerRadius(999)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 999)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                        )
                            }
                        }
                    }
                    if bubbleMoments.isEmpty {
                        Text("附近暂无点位（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(16)
                    }
                if showMoodCard {
                    MoodCard(selectedFilter: $moodFilter, onBrowse: {
                        showMoodSheet = true
                    }, onCollapse: {
                        showMoodCard = false
                    })
                } else {
                    Button("展开情绪天气") {
                        showMoodCard = true
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(999)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
                if !showMoodCard {
                    Text("情绪卡已收起（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                    HStack(spacing: 12) {
                        Button("按情绪浏览") {
                            showMoodSheet = true
                        }
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(999)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        Text("AI 静默在场（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button {
                            showListSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "list.bullet")
                                    .font(.footnote)
                                Text("列表")
                                    .font(.footnote)
                                Text("\(filteredMoments.count)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(999)
                        }
                        .buttonStyle(.plain)
                    }
                    Text("默认范围：3km（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位聚合显示（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("首屏 2 秒内可点击入口（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("点位点击打开地点抽屉（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("地图刷新不影响草稿（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                    Button(angelButtonLabel) {
                        showAngelSheet = true
                        angelHint = "已打开天使卡片（占位）"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            angelHint = ""
                        }
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(999)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    Text("天使卡默认关闭（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Button("附近微展") {
                        apiClient.fetchExhibits { titles in
                            exhibits = titles
                            exhibitHint = "已加载微展（占位）"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                exhibitHint = ""
                            }
                            showExhibitSheet = true
                        }
                    }
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(999)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                    }
                    Text("入口：点位气泡 / 列表 / 随机听听")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("列表点击进入播放（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展包含 6–12 条片刻（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展推荐每日最多一次（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展基于 500m/1km（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("共鸣触发地图波纹（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("微展标题自动生成（占位）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if !exhibitHint.isEmpty {
                        Text(exhibitHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if !angelHint.isEmpty {
                        Text(angelHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Button("随机听听") {
                        selectedMoment = filteredMoments.first ?? moments.first
                        showDetail = true
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .sheet(isPresented: $showAngelSheet) {
                    NavigationView {
                        NotificationsView()
                            .navigationTitle("天使卡片")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .sheet(isPresented: $showExhibitSheet) {
                    NavigationView {
                        ExhibitListView(exhibits: exhibits)
                            .navigationTitle("附近微展")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .sheet(isPresented: $showPlaceSheet) {
                    PlaceSheet(
                        title: selectedZoneName ?? "附近片刻",
                        items: filteredMoments,
                        onSelect: { moment in
                            showPlaceSheet = false
                            selectedMoment = moment
                            selectedZoneName = moment.zoneName
                            showDetail = true
                        },
                        onCreate: {
                            showPlaceSheet = false
                            showCreate = true
                        }
                    )
                }
                .fullScreenCover(isPresented: $showCreate) {
                    CreateView(presetZoneName: selectedZoneName)
                }
                .sheet(isPresented: $showListSheet) {
                    MomentsListSheet(
                        items: filteredMoments,
                        onSelect: { moment in
                            showListSheet = false
                            selectedMoment = moment
                            selectedMomentId = moment.id
                            showDetail = true
                        }
                    )
                }
                .overlay(alignment: .top) {
                    if showLocationHint {
                        Text(locationHintText)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .padding(.top, 12)
                    }
                    if locationStatus == "定位中..." {
                        Text("定位中，请稍候（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 48)
                    }
                    if locationStatus == "定位失败" {
                        Text("定位失败，请稍后重试（占位）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 48)
                    }
                }
                .overlay(alignment: .bottom) {
                    HStack(spacing: 8) {
                        Text("地图点位为示例，后续接入真实数据")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button("了解") {}
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(999)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.bottom, 110)
                }
            }
            .background(
                NavigationLink(
                    destination: DetailView(moment: selectedMoment ?? moments.first!),
                    isActive: $showDetail
                ) {
                    EmptyView()
                }
            )
            .sheet(isPresented: $showMoodSheet) {
                MoodBrowseSheet(selectedFilter: $moodFilter) {
                    showMoodSheet = false
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    locationStatus = "已定位"
                }
                apiClient.fetchAngelCards { cards in
                    angelCardCount = cards.count
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .angelCardsUpdated)) { notification in
                if let count = notification.userInfo?["count"] as? Int {
                    angelCardCount = count
                }
            }
        }
    }

    private var angelButtonLabel: String {
        angelCardCount > 0 ? "天使卡片 \(angelCardCount)" : "天使卡片"
    }
}

private enum MoodFilter {
    case all
    case tired
    case light
    case emo

    func match(emoji: String) -> Bool {
        switch self {
        case .all:
            return true
        case .tired:
            return emoji == "😮‍💨"
        case .light:
            return emoji == "🙂"
        case .emo:
            return emoji == "🥲"
        }
    }
}

private struct MoodCard: View {
    @Binding var selectedFilter: MoodFilter?
    var onBrowse: () -> Void = {}
    var onCollapse: () -> Void = {}
    @State private var hintText = "去听听"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("情绪天气")
                    .font(.headline)
                Spacer()
                Button("收起") {
                    onCollapse()
                }
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                    .background(Color.black.opacity(0.08))
                    .cornerRadius(8)
                Text("Top3")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(8)
            }
            Text("可随时收起（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                MoodChip(
                    emoji: "😮‍💨",
                    label: "疲惫 45%",
                    isSelected: selectedFilter == .tired
                ) {
                    selectedFilter = .tired
                }
                MoodChip(
                    emoji: "🙂",
                    label: "轻松 30%",
                    isSelected: selectedFilter == .light
                ) {
                    selectedFilter = .light
                }
                MoodChip(
                    emoji: "🥲",
                    label: "emo 25%",
                    isSelected: selectedFilter == .emo
                ) {
                    selectedFilter = .emo
                }
            }
            Button(selectedFilter == nil ? "去听听" : "清除筛选") {
                if selectedFilter == nil {
                    onBrowse()
                    hintText = "正在打开情绪浏览..."
                } else {
                    selectedFilter = nil
                    hintText = "去听听"
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            Text(hintText)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("默认情绪：轻松/治愈（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("情绪浏览以标签切换（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("点击情绪进入浏览（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white.opacity(0.95))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
        .onChange(of: selectedFilter) { value in
            if value != nil {
                hintText = "已应用筛选"
            } else {
                hintText = "去听听"
            }
        }
    }
}

private struct MoodBrowseSheet: View {
    @Binding var selectedFilter: MoodFilter?
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            Text("按情绪浏览")
                .font(.headline)
            Text(statusHint)
                .font(.caption)
                .foregroundColor(.secondary)
            Picker("情绪", selection: Binding(get: {
                selectedFilter ?? .light
            }, set: { value in
                selectedFilter = value
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onClose()
                }
            })) {
                Text("全部").tag(MoodFilter.all)
                Text("轻松").tag(MoodFilter.light)
                Text("疲惫").tag(MoodFilter.tired)
                Text("emo").tag(MoodFilter.emo)
            }
            .pickerStyle(.segmented)
            Button("清除筛选") {
                selectedFilter = nil
                onClose()
            }
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            Spacer()
        }
        .padding(20)
    }

    private var statusHint: String {
        switch selectedFilter {
        case .none:
            return "当前：全部"
        case .some(.all):
            return "当前：全部"
        case .some(.light):
            return "当前：轻松"
        case .some(.tired):
            return "当前：疲惫"
        case .some(.emo):
            return "当前：emo"
        }
    }
}

private struct MomentsListSheet: View {
    let items: [Moment]
    let onSelect: (Moment) -> Void
    @State private var filterHint = "全部"

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("筛选：\(filterHint)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("清除筛选") {
                            filterHint = "全部"
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
                if items.isEmpty {
                    Text("暂无片刻")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(items) { moment in
                        Button {
                            onSelect(moment)
                        } label: {
                            HStack(spacing: 12) {
                                Text(moment.moodEmoji)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(moment.title)
                                        .font(.subheadline)
                                    Text(moment.zoneName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    HStack(spacing: 6) {
                                        Text("治愈")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.12))
                                            .cornerRadius(6)
                                        Text("回应 3")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text("0:08")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("片刻列表")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
private struct MoodChip: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(emoji)
                Text(label)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.black.opacity(0.12) : Color.white)
            .cornerRadius(999)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(isSelected ? Color.black.opacity(0.2) : Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MomentCard: View {
    let moment: Moment
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                    .cornerRadius(14)
                    .overlay(
                        Text("MP4 预览")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    )
                HStack {
                    Text("\(moment.moodEmoji) \(moment.title)")
                        .font(.headline)
                    Spacer()
                    Text(moment.zoneName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(isSelected ? Color.black.opacity(0.08) : Color.white.opacity(0.95))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.black.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct PlaceSheet: View {
    let title: String
    let items: [Moment]
    let onSelect: (Moment) -> Void
    let onCreate: () -> Void

    @State private var actionHint: String
    @State private var subHint = "发布后会回到此地点"
    @State private var sortMode = "最新"

    init(
        title: String,
        items: [Moment],
        onSelect: @escaping (Moment) -> Void,
        onCreate: @escaping () -> Void
    ) {
        self.title = title
        self.items = items
        self.onSelect = onSelect
        self.onCreate = onCreate
        _actionHint = State(initialValue: items.isEmpty ? "成为第一条" : "在这里留一句")
    }

    private var baseActionTitle: String {
        items.isEmpty ? "成为第一条" : "在这里留一句"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("共 \(items.count) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("刷新") {
                    actionHint = "已刷新"
                }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
            }
            HStack(spacing: 8) {
                Text("位置已模糊到商圈")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Button("最新") { sortMode = "最新" }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sortMode == "最新" ? Color.black.opacity(0.1) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
                Button("热门") { sortMode = "热门" }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sortMode == "热门" ? Color.black.opacity(0.1) : Color.gray.opacity(0.12))
                    .cornerRadius(999)
            }
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items) { moment in
                        Button {
                            onSelect(moment)
                        } label: {
                            HStack(spacing: 12) {
                                Text(moment.moodEmoji)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(moment.title)
                                        .font(.subheadline)
                                    Text(moment.zoneName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("回应 3")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("0:08")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if items.isEmpty {
                Text("附近还没有片刻，先留一句吧")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Button(actionHint) {
                onCreate()
                actionHint = "已进入创建"
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
            Text(subHint)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onChange(of: actionHint) { _ in
            if actionHint == "已刷新" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    actionHint = baseActionTitle
                }
            }
            if actionHint == "已进入创建" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    actionHint = baseActionTitle
                }
            }
        }
        .padding(20)
    }
}

private struct ExhibitListView: View {
    let exhibits: [ExhibitSummary]

    var body: some View {
        List {
            if exhibits.isEmpty {
                VStack(spacing: 8) {
                    Text("暂无微展")
                        .font(.subheadline)
                    Text("公开且允许收录的内容会出现在这里")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowSeparator(.hidden)
            } else {
                ForEach(exhibits, id: \.id) { exhibit in
                    NavigationLink(destination: ExhibitDetailView(exhibit: exhibit)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exhibit.title)
                                    .font(.subheadline)
                                Text("情绪：\(exhibit.moodCode)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(exhibit.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
    }
}

private struct ExhibitDetailView: View {
    let exhibit: ExhibitSummary
    @State private var showCreate = false
    var onCreate: (() -> Void)? = nil
    @State private var actionHint = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exhibit.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text("情绪：\(exhibit.moodCode)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("条目数：\(exhibit.count)（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
            if !actionHint.isEmpty {
                Text(actionHint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Divider()
            List {
                ForEach(0..<min(6, exhibit.count), id: \.self) { index in
                    HStack {
                        Text("片刻 \(index + 1)")
                            .font(.subheadline)
                        Spacer()
                        Text("查看")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            Button("我也想生成一个同主题片刻") {
                actionHint = "已创建同主题入口（占位）"
                showCreate = true
                onCreate?()
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
        }
        .padding(20)
        .fullScreenCover(isPresented: $showCreate) {
            CreateView()
        }
    }
}
