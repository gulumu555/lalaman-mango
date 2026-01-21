import SwiftUI

struct BottlesView: View {
    private let floatingItems = [
        "2025-02-01 · 成都",
        "2025-05-20 · 宽窄巷子"
    ]
    private let openedItems = [
        "2024-12-31 · 太古里",
        "2024-08-08 · 九眼桥"
    ]

    var body: some View {
        List {
            Section("在漂流中") {
                ForEach(floatingItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        Text(item)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                    }
                }
            }
            Section("已靠岸") {
                ForEach(openedItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        Text(item)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("漂流瓶")
        .navigationBarTitleDisplayMode(.inline)
    }
}
