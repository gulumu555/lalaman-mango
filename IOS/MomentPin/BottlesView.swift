import SwiftUI

struct BottlesView: View {
    private let items = [
        "在漂流中 · 2025-02-01",
        "已靠岸 · 2024-12-31",
        "已捡起 · 2024-08-08"
    ]

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
                    .padding(.vertical, 6)
            }
        }
        .navigationTitle("漂流瓶")
        .navigationBarTitleDisplayMode(.inline)
    }
}
