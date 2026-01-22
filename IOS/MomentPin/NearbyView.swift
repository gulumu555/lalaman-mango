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
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
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
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black)
                                        .cornerRadius(999)
                                }
                            }
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
                }
                .overlay(alignment: .bottom) {
                    Text("地图点位为示例，后续接入真实数据")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
            }
        }
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

    var body: some View {
        NavigationView {
            List {
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
