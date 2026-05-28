import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { save() }
    }

    private let storageKey = "userProfile"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = .empty
        }
    }

    var isLoggedIn: Bool {
        !profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func signOut() {
        profile = .empty
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
