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
    private let pickedItems: [String] = []

    var body: some View {
        List {
            Section("在漂流中") {
                ForEach(floatingItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item)
                                    .font(.subheadline)
                                Text("靠岸倒计时 · 12 天")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("漂流中")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.12))
                                .cornerRadius(999)
                        }
                        .padding(.vertical, 6)
                    }
                }
                Text("漂流中内容不在地图展示（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可修改靠岸时间（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可随时取消漂流瓶（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("取消需要确认（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("靠岸后红点提醒（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("漂流瓶默认私密（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("漂流瓶可编辑内容（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Section("已靠岸") {
                ForEach(openedItems, id: \.self) { item in
                    NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item)
                                    .font(.subheadline)
                                Text("已靠岸 · 可回听")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("已靠岸")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(999)
                        }
                        .padding(.vertical, 6)
                    }
                }
                Text("已靠岸可再次设置时间（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("已靠岸可一键回听（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可再次放回漂流（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Section("已捡起") {
                if pickedItems.isEmpty {
                    Text("暂无捡起记录")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                Text("漂流瓶到期仅站内提醒（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("可设置静默 7 天（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("捡起后可回听（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("捡起后可再次漂流（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("捡起后可删除（占位）")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                    ForEach(pickedItems, id: \.self) { item in
                        NavigationLink(destination: DetailView(moment: Moment.sample.first!)) {
                            Text(item)
                                .font(.subheadline)
                                .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
        .navigationTitle("漂流瓶")
        .navigationBarTitleDisplayMode(.inline)
    }
}
