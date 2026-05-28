import Foundation

@MainActor
final class CoachChatStore: ObservableObject {
    @Published private(set) var messages: [CoachChatMessage] {
        didSet { save() }
    }

    private let storageKey = "coachChatMessages"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CoachChatMessage].self, from: data) {
            messages = decoded
        } else {
            messages = [
                CoachChatMessage(
                    role: .assistant,
                    text: "Ask me about today's workout, swaps, pacing, recovery, or how to make a movement safer."
                )
            ]
        }
    }

    func append(_ message: CoachChatMessage) {
        messages.append(message)
    }

    func clear() {
        messages = [
            CoachChatMessage(role: .assistant, text: "Fresh chat started. What do you want to train today?")
        ]
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
