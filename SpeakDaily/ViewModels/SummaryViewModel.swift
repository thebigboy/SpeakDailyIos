import Foundation

struct SummarySection: Identifiable {
    let id: String
    let date: Date
    let entries: [HistoryEntry]
    var summary: SummaryResult?
    var isLoading: Bool
    var errorMessage: String?
}

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published var sections: [SummarySection] = []

    private let historyStore = HistoryStore.shared
    private let summaryStore = SummaryStore.shared
    private let deepseek = DeepSeekService()

    func load() {
        buildSections()
    }

    private func buildSections() {
        let grouped = Dictionary(grouping: historyStore.items) { entry in
            Calendar.current.startOfDay(for: entry.createdAt)
        }
        let sortedDates = grouped.keys.sorted(by: >)

        sections = sortedDates.map { date in
            let dayKey = dayKey(for: date)
            let entries = grouped[date]?.sorted(by: { $0.createdAt < $1.createdAt }) ?? []
            let summary = summaryStore.summary(for: dayKey)
            return SummarySection(
                id: dayKey,
                date: date,
                entries: entries,
                summary: summary,
                isLoading: false,
                errorMessage: nil
            )
        }
    }

    func generateSummary(for sectionID: String) async {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return }
        guard !sections[index].entries.isEmpty else {
            sections[index].errorMessage = "暂无可总结的对话"
            return
        }
        sections[index].isLoading = true
        sections[index].errorMessage = nil
        let messages = buildMessages(from: sections[index].entries)
        guard !messages.isEmpty else {
            sections[index].isLoading = false
            sections[index].errorMessage = "暂无可总结的对话"
            return
        }
        do {
            let summary = try await deepseek.summarizeConversation(messages)
            let limited = clampSummary(summary)
            summaryStore.saveSummary(limited, for: sections[index].id)
            sections[index].summary = limited
        } catch {
            sections[index].errorMessage = error.localizedDescription
        }
        sections[index].isLoading = false
    }

    private func buildMessages(from entries: [HistoryEntry]) -> [ConversationMessage] {
        var messages: [ConversationMessage] = []
        for entry in entries {
            if !entry.cn.isEmpty {
                messages.append(ConversationMessage(role: .user, content: entry.cn))
            }
            if !entry.en.isEmpty {
                messages.append(ConversationMessage(role: .assistant, content: entry.en))
            }
        }
        return messages
    }

    private func clampSummary(_ summary: SummaryResult) -> SummaryResult {
        var limited = summary
        limited.vocab = Array(limited.vocab.prefix(10))
        limited.grammar = Array(limited.grammar.prefix(10))
        limited.quiz = Array(limited.quiz.prefix(10))
        limited.stats = SummaryStats(
            vocabCount: limited.vocab.count,
            grammarCount: limited.grammar.count,
            expressionsCount: limited.stats.expressionsCount
        )
        return limited
    }

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func displayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}
