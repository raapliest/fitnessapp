import Foundation

@MainActor
final class CoachViewModel: ObservableObject {
    @Published private(set) var currentRecommendation: WorkoutRecommendation
    @Published private(set) var lastSavedMessage: String?

    private let engine: RecommendationEngine
    private let historyStore: WorkoutHistoryStore

    init(
        engine: RecommendationEngine = RecommendationEngine(),
        historyStore: WorkoutHistoryStore
    ) {
        self.engine = engine
        self.historyStore = historyStore
        currentRecommendation = engine.recommendation(
            activeEnergy: 0,
            calorieGoal: 550,
            focus: .balanced,
            availableMinutes: 30,
            intensity: .medium,
            isBeginner: true
        )
    }

    func refresh(
        activeEnergy: Double,
        calorieGoal: Double,
        focus: WorkoutFocus,
        availableMinutes: Int,
        intensity: WorkoutIntensity,
        isBeginner: Bool
    ) {
        currentRecommendation = engine.recommendation(
            activeEnergy: activeEnergy,
            calorieGoal: calorieGoal,
            focus: focus,
            availableMinutes: availableMinutes,
            intensity: intensity,
            isBeginner: isBeginner
        )
    }

    func saveCurrentRecommendation() {
        historyStore.save(currentRecommendation)
        lastSavedMessage = "Workout saved to history."
    }
}
