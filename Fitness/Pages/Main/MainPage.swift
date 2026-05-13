import SwiftUI

struct MainPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ActiveEnergyCard(
                        activeEnergy: healthKit.activeEnergy,
                        calorieGoal: settings.dailyCalorieGoal,
                        statusMessage: healthKit.statusMessage,
                        refresh: refreshHealth
                    )

                    CalorieGoalCard(goal: $settings.dailyCalorieGoal)

                    InsightCard(
                        title: "Today’s coaching note",
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
                    Button(action: refreshHealth) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private var coachingMessage: String {
        let remaining = max(settings.dailyCalorieGoal - healthKit.activeEnergy, 0)

        if remaining == 0 {
            return "Goal complete. Keep the rest of the day light and focus on recovery."
        }

        return "\(Int(remaining)) kcal left. Pick a workout that fits your energy and available time."
    }

    private func refreshHealth() {
        Task {
            await healthKit.refreshActiveEnergy()
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
    }
}
