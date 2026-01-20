import SwiftUI
import MapKit

struct NearbyView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0800),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    private let moments: [Moment] = Moment.sample

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: moments) { moment in
                MapAnnotation(coordinate: moment.coordinate) {
                    Text("\(moment.count)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(6)
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
                MoodCard()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(moments) { moment in
                            MomentCard(moment: moment)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 90)
        }
    }
}

private struct MoodCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("情绪天气")
                .font(.headline)
            HStack(spacing: 12) {
                MoodChip(emoji: "😮‍💨", label: "疲惫 45%")
                MoodChip(emoji: "🙂", label: "轻松 30%")
                MoodChip(emoji: "🥲", label: "emo 25%")
            }
            Button("去听听") {}
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

    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
            Text(label)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(999)
        .overlay(
            RoundedRectangle(cornerRadius: 999)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct MomentCard: View {
    let moment: Moment

    var body: some View {
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
        .padding(14)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct Moment: Identifiable {
    let id = UUID()
    let title: String
    let moodEmoji: String
    let zoneName: String
    let coordinate: CLLocationCoordinate2D
    let count: Int

    static let sample: [Moment] = [
        Moment(title: "在这儿停一下", moodEmoji: "🫧", zoneName: "太古里附近", coordinate: .init(latitude: 30.6570, longitude: 104.0800), count: 8),
        Moment(title: "桥上有风", moodEmoji: "🫧", zoneName: "九眼桥附近", coordinate: .init(latitude: 30.6395, longitude: 104.0920), count: 4),
        Moment(title: "巷子里的灯", moodEmoji: "✨", zoneName: "宽窄巷子", coordinate: .init(latitude: 30.6708, longitude: 104.0517), count: 6),
    ]
}
