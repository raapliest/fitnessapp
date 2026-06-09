import Foundation

@MainActor
final class WorkoutHistoryStore: ObservableObject {
    @Published private(set) var recommendations: [WorkoutRecommendation] = []

    private var userID: String = "guest"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let firestore = FirestoreService.shared

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        loadLocal()
    }

    func save(_ recommendation: WorkoutRecommendation) {
        recommendations.removeAll { $0.id == recommendation.id }
        recommendations.insert(recommendation, at: 0)
        recommendations = Array(recommendations.prefix(20))
        persist()
    }

    func clear() {
        recommendations = []
        UserDefaults.standard.removeObject(forKey: localKey)
        firestore.save([WorkoutRecommendation](), userID: userID, store: "workoutHistory")
    }

    func setUserID(_ userID: String) {
        self.userID = userID.isEmpty ? "guest" : userID
        loadLocal()
        Task { await fetchFromFirestore() }
    }

    // MARK: - Private

    private func persist() {
        if let data = try? encoder.encode(recommendations) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
        firestore.save(recommendations, userID: userID, store: "workoutHistory")
    }

    private func loadLocal() {
        guard let data = UserDefaults.standard.data(forKey: localKey),
              let decoded = try? decoder.decode([WorkoutRecommendation].self, from: data) else {
            recommendations = []
            return
        }
        recommendations = decoded
    }

    private func fetchFromFirestore() async {
        guard let remote = await firestore.load([WorkoutRecommendation].self, userID: userID, store: "workoutHistory") else { return }
        recommendations = remote
        if let data = try? encoder.encode(remote) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
    }

    private var localKey: String { "workoutRecommendationHistory.\(userID)" }
}
