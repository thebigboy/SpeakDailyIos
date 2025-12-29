import Foundation

struct StoredSummary: Codable {
    var summary: SummaryResult
    var answers: [String: Int]
}

@MainActor
final class SummaryStore: ObservableObject {
    static let shared = SummaryStore()

    @Published private(set) var summaries: [String: StoredSummary] = [:] {
        didSet { persist() }
    }

    private let storageKey = "summary.byDay.v1"

    private init() {
        load()
    }

    func summary(for dayKey: String) -> SummaryResult? {
        summaries[dayKey]?.summary
    }

    func answers(for dayKey: String) -> [String: Int] {
        summaries[dayKey]?.answers ?? [:]
    }

    func saveSummary(_ summary: SummaryResult, for dayKey: String) {
        let existing = summaries[dayKey]
        let answers = existing?.answers ?? [:]
        summaries[dayKey] = StoredSummary(summary: summary, answers: answers)
    }

    func updateAnswer(dayKey: String, question: String, selectedIndex: Int) {
        guard var record = summaries[dayKey] else { return }
        record.answers[question] = selectedIndex
        summaries[dayKey] = record
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            summaries = try JSONDecoder().decode([String: StoredSummary].self, from: data)
        } catch {
            summaries = [:]
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(summaries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore persistence errors.
        }
    }
}
