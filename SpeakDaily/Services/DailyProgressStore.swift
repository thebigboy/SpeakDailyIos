import Foundation

@MainActor
final class DailyProgressStore: ObservableObject {
    static let shared = DailyProgressStore()

    @Published private(set) var count: Int = 0
    let target: Int = 12

    private let countKey = "daily.translation.count"
    private let dateKey = "daily.translation.date"

    private init() {
        load()
    }

    func increment() {
        resetIfNeeded()
        count = min(count + 1, target)
        persist()
    }

    private func load() {
        let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date
        if let savedDate, Calendar.current.isDateInToday(savedDate) {
            count = UserDefaults.standard.integer(forKey: countKey)
        } else {
            count = 0
            persist()
        }
    }

    private func resetIfNeeded() {
        let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date
        if savedDate == nil || !Calendar.current.isDateInToday(savedDate!) {
            count = 0
        }
    }

    private func persist() {
        UserDefaults.standard.set(count, forKey: countKey)
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
}
