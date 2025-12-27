import Foundation

enum Role: String, Codable {
    case user
    case assistant
}

struct ConversationMessage: Codable {
    var role: Role
    var content: String
}

