import SwiftUI

struct MyMomentsView: View {
    private let privateItems = [
        "在这儿停一下",
        "给未来的我",
        "深夜地铁口"
    ]
    private let publicItems = [
        "桥上有风",
        "河边的安静"
    ]

    var body: some View {
        List {
            Section("私密") {
                ForEach(privateItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item)
                                    .font(.subheadline)
                                Text("仅自己可见 · 0:08")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("未生成")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.12))
                                .cornerRadius(999)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            Section("匿名公开") {
                ForEach(publicItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item)
                                    .font(.subheadline)
                                Text("匿名公开 · 0:08")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("已发布")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(999)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("我的片刻")
        .navigationBarTitleDisplayMode(.inline)
    }
}
