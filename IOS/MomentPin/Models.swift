import Foundation
import CoreLocation

struct Moment: Identifiable {
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

enum RenderState: String, CaseIterable {
    case uploaded
    case processing
    case rendered
    case publishable
    case published
    case failed
}
