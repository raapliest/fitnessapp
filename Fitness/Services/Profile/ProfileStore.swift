import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { persist() }
    }

    private var userID: String = "guest"
    private let firestore = FirestoreService.shared

    init() {
        profile = .empty
        loadLocal()
    }

    func setUserID(_ userID: String) {
        self.userID = userID.isEmpty ? "guest" : userID
        loadLocal()
        Task { await fetchFromFirestore() }
    }

    func populateIfEmpty(from session: AuthSession) {
        guard !session.userID.isEmpty else { return }
        if profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profile.displayName = session.displayName.isEmpty ? session.email : session.displayName
        }
    }

    func resetProfile() {
        profile = .empty
    }

    // MARK: - Private

    private func persist() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: localKey)
        firestore.save(profile, userID: userID, store: "profile")
    }

    private func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: localKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = .empty
        }
    }

    private func fetchFromFirestore() async {
        guard let remote = await firestore.load(UserProfile.self, userID: userID, store: "profile") else { return }
        profile = remote
        if let data = try? JSONEncoder().encode(remote) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
    }

    private var localKey: String { "userProfile.\(userID)" }
}
