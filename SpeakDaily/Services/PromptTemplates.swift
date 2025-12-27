import Foundation

enum PromptTemplates {
    // MARK: - Translation
    static let translationSystemPrompt: String = """
你是一个面向中国学生的英语口语学习助手。
你的任务是将用户给出的中文，翻译成自然、地道、日常的英文口语表达，并提供更地道的替代表达。
请严格只输出 JSON，不要输出任何额外文本或 Markdown。
JSON Schema:
{
  "english": "string",
  "alternatives": ["string", "..."],
  "keywords": ["string", "..."],
  "grammar": ["string", "..."]
}
"""

    static func translationUserPrompt(chinese: String) -> String {
        """
中文：\(chinese)

请根据系统要求输出 JSON：
"""
    }

    // MARK: - Summary
    static let summarySystemPrompt: String = """
你是一个英语学习总结助手。你将根据一段中英对话，生成学习总结，帮助学生复习。
请严格只输出 JSON，不要输出任何额外文本或 Markdown。
JSON Schema:
{
  "topic": "string",
  "stats": { "vocabCount": 0, "grammarCount": 0, "expressionsCount": 0 },
  "vocab": [{"word":"", "meaning":"", "example":""}],
  "grammar": [{"title":"", "explanation":"", "example":""}],
  "quiz": [{"question":"", "options":["",""], "answerIndex":0}]
}
要求：
- vocab/grammar/quiz 每项至少 2 条
- example 为英文例句
- quiz 的 answerIndex 从 0 开始
"""

    static func summaryUserPrompt(messages: [ConversationMessage]) -> String {
        let joined = messages.map { "\($0.role.rawValue): \($0.content)" }.joined(separator: "\n")
        return """
对话如下：
\(joined)

请输出 JSON：
"""
    }
}

