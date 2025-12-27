import Foundation

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let cn: String
    var en: String
    var isFavorite: Bool

    init(id: UUID = UUID(), createdAt: Date = Date(), cn: String, en: String, isFavorite: Bool = false) {
        self.id = id
        self.createdAt = createdAt
        self.cn = cn
        self.en = en
        self.isFavorite = isFavorite
    }
}
