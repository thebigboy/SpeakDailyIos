import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var items: [HistoryEntry] = [] {
        didSet { persist() }
    }

    private let storageKey = "history.entries.v1"

    private init() {
        load()
    }

    func addEntry(cn: String, en: String) -> HistoryEntry {
        let entry = HistoryEntry(cn: cn, en: en)
        items.insert(entry, at: 0)
        return entry
    }

    func startEntry() -> HistoryEntry {
        let entry = HistoryEntry(cn: "", en: "")
        items.insert(entry, at: 0)
        return entry
    }

    func toggleFavorite(id: UUID) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return false }
        items[index].isFavorite.toggle()
        return items[index].isFavorite
    }

    func updateEnglish(id: UUID, en: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].en = en
    }

    func updateChinese(id: UUID, cn: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].cn = cn
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            items = try JSONDecoder().decode([HistoryEntry].self, from: data)
        } catch {
            items = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore persistence errors to avoid breaking UI updates.
        }
    }
}
