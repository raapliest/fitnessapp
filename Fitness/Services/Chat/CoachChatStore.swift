import Foundation

@MainActor
final class CoachChatStore: ObservableObject {
    @Published private(set) var sessions: [ChatSession] = []
    @Published private(set) var activeSessionID: UUID?

    private var userID: String = "guest"
    private let firestore = FirestoreService.shared

    init() {
        loadLocal()
    }

    var activeSession: ChatSession? {
        guard let id = activeSessionID else { return nil }
        return sessions.first { $0.id == id }
    }

    var messages: [CoachChatMessage] {
        activeSession?.messages ?? []
    }

    func newSession() {
        let session = ChatSession.makeNew()
        sessions.insert(session, at: 0)
        activeSessionID = session.id
        persist()
    }

    func switchTo(_ sessionID: UUID) {
        guard sessions.contains(where: { $0.id == sessionID }) else { return }
        activeSessionID = sessionID
    }

    func deleteSession(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        if activeSessionID == id {
            activeSessionID = sessions.first?.id
        }
        if sessions.isEmpty { newSession() }
        persist()
    }

    func append(_ message: CoachChatMessage) {
        guard let id = activeSessionID,
              let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].messages.append(message)
        if message.role == .user && sessions[index].title == "New Chat" {
            let words = message.text.split(separator: " ").prefix(5).joined(separator: " ")
            sessions[index].title = words.isEmpty ? "Chat" : words
        }
        sessions[index].updatedAt = Date()
        persist()
    }

    func setUserID(_ userID: String) {
        self.userID = userID.isEmpty ? "guest" : userID
        loadLocal()
        Task { await fetchFromFirestore() }
    }

    // MARK: - Private

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: localKey)
        firestore.save(sessions, userID: userID, store: "chatSessions")
    }

    private func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: localKey),
           let decoded = try? JSONDecoder().decode([ChatSession].self, from: data),
           !decoded.isEmpty {
            sessions = decoded.sorted { $0.updatedAt > $1.updatedAt }
            activeSessionID = sessions.first?.id
        } else {
            let session = ChatSession.makeNew()
            sessions = [session]
            activeSessionID = session.id
        }
    }

    private func fetchFromFirestore() async {
        guard let remote = await firestore.load([ChatSession].self, userID: userID, store: "chatSessions"),
              !remote.isEmpty else { return }
        sessions = remote.sorted { $0.updatedAt > $1.updatedAt }
        activeSessionID = sessions.first?.id
        if let data = try? JSONEncoder().encode(remote) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
    }

    private var localKey: String { "coachChatSessions.\(userID)" }
}
