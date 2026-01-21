import SwiftUI

struct MyMomentsView: View {
    private let items = [
        "私密 · 在这儿停一下",
        "匿名公开 · 桥上有风",
        "私密 · 给未来的我"
    ]

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                    Text(item)
                        .font(.subheadline)
                        .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("我的片刻")
        .navigationBarTitleDisplayMode(.inline)
    }
}
