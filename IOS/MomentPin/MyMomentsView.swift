import SwiftUI

struct MyMomentsView: View {
    private let privateItems = [
        "在这儿停一下",
        "给未来的我"
    ]
    private let publicItems = [
        "桥上有风"
    ]

    var body: some View {
        List {
            Section("私密") {
                ForEach(privateItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        Text(item)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                    }
                }
            }
            Section("匿名公开") {
                ForEach(publicItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        Text(item)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("我的片刻")
        .navigationBarTitleDisplayMode(.inline)
    }
}
