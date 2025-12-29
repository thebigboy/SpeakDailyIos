import SwiftUI

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all = "全部"
    case favorites = "收藏"

    var id: String { rawValue }
}

struct HistoryScreen: View {
    @StateObject private var store = HistoryStore.shared
    @State private var searchText: String = ""
    @State private var filter: HistoryFilter = .all
    @State private var disabledPlayIDs: Set<UUID> = []
    private let tts = TTSService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("筛选", selection: $filter) {
                    ForEach(HistoryFilter.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                List {
                    ForEach(filteredItems) { item in
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(formattedTime(item.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if item.isFavorite {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                                Spacer()
                            }

                            Text(item.cn)
                                .font(.body)

                            Text(item.en)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(action: { play(item) }) {
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundStyle(disabledPlayIDs.contains(item.id) ? .gray : .blue)
                                .frame(width: 52, height: 52)
                        }
                        .disabled(disabledPlayIDs.contains(item.id))
                    }
                    .padding(.vertical, 6)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.remove(id: item.id)
                        } label: {
                            Text("删除")
                        }
                        .tint(.red.opacity(0.75))
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            _ = store.toggleFavorite(id: item.id)
                        } label: {
                            Text(item.isFavorite ? "取消收藏" : "收藏")
                        }
                        .tint(item.isFavorite ? .gray : .orange)
                    }
                    }
                }
            }
            .navigationTitle("历史记录")
            .searchable(text: $searchText, prompt: "搜索中文或英文")
        }
    }

    private var filteredItems: [HistoryEntry] {
        let base = filter == .favorites ? store.items.filter { $0.isFavorite } : store.items
        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.cn.localizedCaseInsensitiveContains(searchText) ||
            $0.en.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }

    private func play(_ item: HistoryEntry) {
        guard !disabledPlayIDs.contains(item.id) else { return }
        disabledPlayIDs.insert(item.id)
        tts.speakEnglish(item.en)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            disabledPlayIDs.remove(item.id)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let ids = offsets.compactMap { filteredItems[$0].id }
        ids.forEach { store.remove(id: $0) }
    }
}
