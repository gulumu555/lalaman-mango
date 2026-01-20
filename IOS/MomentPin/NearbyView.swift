import SwiftUI
import MapKit

struct NearbyView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0800),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    @State private var showPlaceSheet = false
    @State private var selectedMoment: Moment? = nil
    @State private var selectedZoneName: String? = nil
    @State private var showCreate = false
    @State private var moodFilter: MoodFilter? = nil

    private let moments: [Moment] = Moment.sample
    private var filteredMoments: [Moment] {
        guard let moodFilter else { return moments }
        return moments.filter { moodFilter.match(emoji: $0.moodEmoji) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: filteredMoments) { moment in
                    MapAnnotation(coordinate: moment.coordinate) {
                        Button {
                            selectedMoment = moment
                            showPlaceSheet = true
                        } label: {
                            Text("\(moment.count)")
                                .font(.caption2)
                                .foregroundColor(.black)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(6)
                        }
                    }
                }
                .ignoresSafeArea()

                LinearGradient(
                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.55), Color.white.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    MoodCard(selectedFilter: $moodFilter)
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredMoments) { moment in
                                MomentCard(moment: moment) {
                                    selectedMoment = moment
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .sheet(isPresented: $showPlaceSheet) {
                    PlaceSheet(
                        title: selectedMoment?.zoneName ?? "附近片刻",
                        items: filteredMoments,
                        onSelect: { moment in
                            showPlaceSheet = false
                            selectedMoment = moment
                        },
                        onCreate: {
                            showPlaceSheet = false
                            selectedZoneName = selectedMoment?.zoneName
                            showCreate = true
                        }
                    )
                }
                .fullScreenCover(isPresented: $showCreate) {
                    CreateView(presetZoneName: selectedZoneName)
                }
            }
            .navigationDestination(item: $selectedMoment) { moment in
                DetailView(moment: moment)
            }
        }
    }
}

private enum MoodFilter {
    case tired
    case light
    case emo

    func match(emoji: String) -> Bool {
        switch self {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("情绪天气")
                .font(.headline)
            HStack(spacing: 12) {
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
                selectedFilter = nil
            }
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(999)
        }
        .padding(16)
        .background(Color.white.opacity(0.95))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
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
            .background(isSelected ? Color.black.opacity(0.1) : Color.white)
            .cornerRadius(999)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MomentCard: View {
    let moment: Moment
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
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct PlaceSheet: View {
    let title: String
    let items: [Moment]
    let onSelect: (Moment) -> Void
    let onCreate: () -> Void
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
        .padding(14)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct PlaceSheet: View {
    let title: String
    let items: [Moment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("共 \(items.count) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("刷新") {}
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
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Button("在这里留一句") {
                onCreate()
            }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(999)
        }
        .padding(20)
    }
}
