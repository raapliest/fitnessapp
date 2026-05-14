import SwiftUI

struct MainPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @State private var a2aResponse: A2ACalorieResponse?
    @State private var a2aParseError: String?

    private var calorieData: A2ACalorieResponse.CalorieData? {
        a2aResponse?.calorieData
    }

    private var displayedActiveEnergy: Double {
        Double(calorieData?.activeCalories ?? Int(healthKit.activeEnergy))
    }

    private var displayedCalorieGoal: Double {
        Double(calorieData?.goalCalories ?? Int(settings.dailyCalorieGoal))
    }

    private var displayedStatusMessage: String {
        if let calorieData {
            return "Parsed from \(calorieData.source)."
        }

        if let a2aParseError {
            return a2aParseError
        }

        return healthKit.statusMessage
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ActiveEnergyCard(
                        activeEnergy: displayedActiveEnergy,
                        calorieGoal: displayedCalorieGoal,
                        statusMessage: displayedStatusMessage,
                        refresh: loadMockA2ACalorieResponse
                    )

                    CalorieGoalCard(goal: $settings.dailyCalorieGoal)

                    if let calorieData {
                        calorieBreakdown(for: calorieData)
                    }

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
                    Button(action: loadMockA2ACalorieResponse) {
                        Label("Load A2A mock", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .task {
                loadMockA2ACalorieResponse()
            }
        }
    }

    private var coachingMessage: String {
        if let insight = calorieData?.insight {
            return insight
        }

        let remaining = max(settings.dailyCalorieGoal - healthKit.activeEnergy, 0)

        if remaining == 0 {
            return "Goal complete. Keep the rest of the day light and focus on recovery."
        }

        return "\(Int(remaining)) kcal left. Pick a workout that fits your energy and available time."
    }

    private func calorieBreakdown(for calorieData: A2ACalorieResponse.CalorieData) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(a2aResponse?.result.persona.name ?? "FitnessApp Persona", systemImage: "person.crop.circle.badge.checkmark")
                .font(.headline)
                .foregroundStyle(.blue)

            HStack {
                calorieMetric("Consumed", value: calorieData.consumedCalories)
                Spacer()
                calorieMetric("Resting", value: calorieData.restingCalories)
                Spacer()
                calorieMetric("Remaining", value: calorieData.remainingCalories)
            }

            Divider()

            ForEach(calorieData.samples) { sample in
                HStack {
                    Text(sample.label)
                    Spacer()
                    Text("\(sample.calories) kcal")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func calorieMetric(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title3.bold())
                .contentTransition(.numericText())
        }
    }

    private func loadMockA2ACalorieResponse() {
        do {
            a2aResponse = try FitnessAppPersona.calorieResponse()
            a2aParseError = nil
        } catch {
            a2aResponse = nil
            a2aParseError = "Could not parse FitnessApp Persona A2A JSON."
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
