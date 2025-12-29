import Foundation

struct SummaryResult: Codable {
    var topic: String
    var stats: SummaryStats
    var vocab: [VocabItem]
    var grammar: [GrammarItem]
    var quiz: [QuizItem]
}

struct SummaryStats: Codable {
    var vocabCount: Int
    var grammarCount: Int
    var expressionsCount: Int
}

struct VocabItem: Codable, Identifiable {
    var id = UUID()
    var word: String
    var meaning: String
    var example: String

    private enum CodingKeys: String, CodingKey {
        case word, meaning, example
    }
}

struct GrammarItem: Codable, Identifiable {
    var id = UUID()
    var title: String
    var explanation: String
    var example: String

    private enum CodingKeys: String, CodingKey {
        case title, explanation, example
    }
}

struct QuizItem: Codable, Identifiable {
    var id = UUID()
    var question: String
    var options: [String]
    var answerIndex: Int

    private enum CodingKeys: String, CodingKey {
        case question, options, answerIndex
    }
}
