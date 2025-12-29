import Foundation

enum DeepSeekError: Error, LocalizedError {
    case missingAPIKey
    case badResponse
    case invalidJSON
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "未配置 DEEPSEEK_API_KEY"
        case .badResponse: return "DeepSeek 返回异常"
        case .invalidJSON: return "解析 DeepSeek JSON 失败"
        case .apiError(let msg): return "DeepSeek 错误：\(msg)"
        }
    }
}

struct TranslationResult: Codable {
    var english: String
    var alternatives: [String]
    var keywords: [String]
    var grammar: [String]
}

final class DeepSeekService {
    private let endpoint = URL(string: "https://api.deepseek.com/chat/completions")!

    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String
    }

    func translateToEnglish(chinese: String) async throws -> TranslationResult {
        let key = apiKey
        guard let key, !key.isEmpty else { throw DeepSeekError.missingAPIKey }

        let userPrompt = PromptTemplates.translationUserPrompt(chinese: chinese)
        let systemPrompt = PromptTemplates.translationSystemPrompt

        let content = try await chatCompletion(apiKey: key, systemPrompt: systemPrompt, userPrompt: userPrompt)
        let jsonString = extractFirstJSONObject(from: content) ?? content
        guard let data = jsonString.data(using: .utf8) else { throw DeepSeekError.invalidJSON }
        return try JSONDecoder().decode(TranslationResult.self, from: data)
    }

    func summarizeConversation(_ messages: [ConversationMessage]) async throws -> SummaryResult {
        let key = apiKey
        guard let key, !key.isEmpty else { throw DeepSeekError.missingAPIKey }

        let userPrompt = PromptTemplates.summaryUserPrompt(messages: messages)
        let systemPrompt = PromptTemplates.summarySystemPrompt

        print("🧩 Summary: messages count =", messages.count)
        print("🧩 Summary: system prompt len =", systemPrompt.count)
        print("🧩 Summary: user prompt len =", userPrompt.count)

        let content = try await chatCompletion(apiKey: key, systemPrompt: systemPrompt, userPrompt: userPrompt)
        print("🧩 Summary raw content:", content)
        let jsonString = extractFirstJSONObject(from: content) ?? content
        print("🧩 Summary extracted JSON:", jsonString)
        guard let data = jsonString.data(using: .utf8) else { throw DeepSeekError.invalidJSON }
        return try JSONDecoder().decode(SummaryResult.self, from: data)
    }

    private func chatCompletion(apiKey: String, systemPrompt: String, userPrompt: String) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "deepseek-chat",
            "temperature": 0.3,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw DeepSeekError.apiError(msg)
            }
            throw DeepSeekError.badResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String
        guard let content else { throw DeepSeekError.badResponse }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractFirstJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{") else { return nil }
        var depth = 0
        var idx = start
        while idx < text.endIndex {
            let ch = text[idx]
            if ch == "{" { depth += 1 }
            if ch == "}" { depth -= 1 }
            if depth == 0 {
                let end = idx
                return String(text[start...end])
            }
            idx = text.index(after: idx)
        }
        return nil
    }
}
