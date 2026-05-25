import Foundation

@MainActor
final class WorkoutHistoryStore: ObservableObject {
    @Published private(set) var recommendations: [WorkoutRecommendation] = []

    private let storageKey = "workoutRecommendationHistory"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func save(_ recommendation: WorkoutRecommendation) {
        recommendations.removeAll { $0.id == recommendation.id }
        recommendations.insert(recommendation, at: 0)
        recommendations = Array(recommendations.prefix(20))
        persist()
    }

    func clear() {
        recommendations = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            recommendations = []
            return
        }

        do {
            recommendations = try decoder.decode([WorkoutRecommendation].self, from: data)
        } catch {
            recommendations = []
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(recommendations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
}
