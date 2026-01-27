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
            Section("汇总") {
                Text("私密 \(privateItems.count) · 匿名公开 \(publicItems.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("默认仅自己可见（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可按私密/公开筛选（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可搜索标题（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
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
                Text("草稿可继续完善（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("私密内容不参与微展/回声（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("私密内容可删除（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
                Text("可在详情页切换公开/私密（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("公开内容可参与回声/微展（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("公开内容可分享（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("导出功能后置（占位）")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .navigationTitle("我的片刻")
        .navigationBarTitleDisplayMode(.inline)
    }
}
