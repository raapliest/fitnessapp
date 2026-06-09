import Foundation

struct CoachChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user
        case assistant
    }

    var id: UUID
    var role: Role
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), role: Role, text: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

struct ChatSession: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var messages: [CoachChatMessage]
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String = "New Chat", messages: [CoachChatMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func makeNew() -> ChatSession {
        let greeting = CoachChatMessage(
            role: .assistant,
            text: "Halo! Tanya aku soal workout hari ini, swap latihan, pemulihan, atau cara gerakan yang lebih aman."
        )
        return ChatSession(messages: [greeting])
    }
}
