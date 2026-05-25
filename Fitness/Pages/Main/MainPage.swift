import SwiftUI

struct MainPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var historyStore: WorkoutHistoryStore

    private let engine = RecommendationEngine()

    private var recommendation: WorkoutRecommendation {
        engine.recommendation(
            activeEnergy: healthKit.activeEnergy,
            calorieGoal: settings.dailyCalorieGoal,
            focus: settings.preferredFocus,
            availableMinutes: settings.availableWorkoutMinutes,
            intensity: settings.preferredIntensity,
            isBeginner: settings.isBeginner
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ActiveEnergyCard(
                        activeEnergy: healthKit.activeEnergy,
                        calorieGoal: settings.dailyCalorieGoal,
                        statusMessage: healthKit.statusMessage,
                        refresh: refreshHealthData
                    )

                    stepsCard

                    CalorieGoalCard(goal: $settings.dailyCalorieGoal)

                    dashboardRecommendationCard

                    InsightCard(
                        title: "Today’s plan",
                        message: coachingMessage,
                        systemImage: "sparkles"
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Fitness Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshHealthData) {
                        Label("Refresh Health", systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await healthKit.refreshTodayMetrics()
            }
        }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Steps", systemImage: "shoeprints.fill")
                .font(.headline)
                .foregroundStyle(.blue)

            Text("\(Int(healthKit.stepCount))")
                .font(.title2.bold())

            Text("Supporting metric from Apple Health.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var dashboardRecommendationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recommended workout", systemImage: recommendation.systemImage)
                    .font(.headline)
                    .foregroundStyle(.green)

                Spacer()

                Text("\(recommendation.durationMinutes) min")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text(recommendation.title)
                .font(.title3.bold())

            Text(recommendation.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                quickStart()
            } label: {
                Label("Quick Start Workout", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var coachingMessage: String {
        let remaining = max(settings.dailyCalorieGoal - healthKit.activeEnergy, 0)

        if remaining == 0 {
            return "Goal complete. Today's recommendation stays light to avoid overtraining."
        }

        return "\(Int(remaining)) kcal left. The plan adapts to \(settings.availableWorkoutMinutes) minutes, \(settings.preferredIntensity.title.lowercased()) intensity, and \(settings.preferredFocus.title.lowercased()) focus."
    }

    private func refreshHealthData() {
        Task {
            await healthKit.refreshTodayMetrics()
        }
    }

    private func quickStart() {
        historyStore.save(recommendation)
        Task {
            await healthKit.saveWorkout(recommendation)
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(WorkoutHistoryStore())
    }
}
