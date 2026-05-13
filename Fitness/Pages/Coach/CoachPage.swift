import SwiftUI

struct CoachPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager

    private let engine = RecommendationEngine()

    private var recommendations: [WorkoutRecommendation] {
        engine.recommendations(
            activeEnergy: healthKit.activeEnergy,
            calorieGoal: settings.dailyCalorieGoal,
            focus: settings.preferredFocus
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Training focus") {
                    Picker("Training focus", selection: $settings.preferredFocus) {
                        ForEach(WorkoutFocus.allCases) { focus in
                            Text(focus.title).tag(focus)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Recommended workouts") {
                    ForEach(recommendations) { workout in
                        WorkoutRecommendationRow(workout: workout)
                    }
                }

                Section("More features included") {
                    Label("Goal-aware recommendations", systemImage: "target")
                    Label("Recovery suggestions when the goal is nearly complete", systemImage: "heart")
                    Label("Readable estimates for time and calories", systemImage: "clock")
                }
            }
            .navigationTitle("Coach")
        }
    }
}

struct CoachPage_Previews: PreviewProvider {
    static var previews: some View {
        CoachPage()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
    }
}
