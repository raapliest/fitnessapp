import Foundation

@MainActor
final class CoachViewModel: ObservableObject {
    @Published private(set) var currentRecommendation: WorkoutRecommendation
    @Published private(set) var lastSavedMessage: String?
    @Published private(set) var isSendingCoachQuestion = false

    private let engine: RecommendationEngine
    private let historyStore: WorkoutHistoryStore
    private let chatService: CoachChatService

    init(
        engine: RecommendationEngine = RecommendationEngine(),
        historyStore: WorkoutHistoryStore,
        chatService: CoachChatService = CoachChatService()
    ) {
        self.engine = engine
        self.historyStore = historyStore
        self.chatService = chatService
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

    func askCoach(
        question: String,
        isBeginner: Bool,
        dailyWorkout: DailyWorkout,
        profile: UserProfile,
        chatStore: CoachChatStore
    ) async {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuestion.isEmpty, !isSendingCoachQuestion else { return }

        chatStore.append(CoachChatMessage(role: .user, text: trimmedQuestion))
        isSendingCoachQuestion = true
        defer { isSendingCoachQuestion = false }

        do {
            let reply = try await chatService.response(
                for: trimmedQuestion,
                recommendation: currentRecommendation,
                isBeginner: isBeginner,
                dailyWorkout: dailyWorkout,
                profile: profile,
                recentMessages: chatStore.messages
            )
            chatStore.append(CoachChatMessage(role: .assistant, text: reply))
        } catch {
            chatStore.append(CoachChatMessage(role: .assistant, text: error.localizedDescription))
        }
    }
}
