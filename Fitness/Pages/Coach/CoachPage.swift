import SwiftUI

struct CoachPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @StateObject private var viewModel: CoachViewModel

    init(historyStore: WorkoutHistoryStore? = nil) {
        _viewModel = StateObject(
            wrappedValue: CoachViewModel(
                historyStore: historyStore ?? WorkoutHistoryStore()
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Plan inputs") {
                    Picker("Time", selection: $settings.availableWorkoutMinutes) {
                        Text("15").tag(15)
                        Text("30").tag(30)
                        Text("60").tag(60)
                    }
                    .pickerStyle(.segmented)

                    Picker("Intensity", selection: $settings.preferredIntensity) {
                        ForEach(WorkoutIntensity.allCases) { intensity in
                            Text(intensity.title).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Training focus", selection: $settings.preferredFocus) {
                        ForEach(WorkoutFocus.allCases) { focus in
                            Text(focus.title).tag(focus)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Beginner safety mode", isOn: $settings.isBeginner)
                }

                Section("Recommended workout") {
                    WorkoutRecommendationRow(workout: viewModel.currentRecommendation)

                    recommendationDetail(viewModel.currentRecommendation)

                    Button {
                        saveRecommendation()
                    } label: {
                        Label("Quick Start Workout", systemImage: "play.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    if let message = viewModel.lastSavedMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Safety checks") {
                    ForEach(viewModel.currentRecommendation.safetyNotes, id: \.self) { note in
                        Label(note, systemImage: "checkmark.shield")
                    }
                }
            }
            .navigationTitle("Coach")
            .task {
                refreshRecommendation()
            }
            .onChange(of: healthKit.activeEnergy) { _ in refreshRecommendation() }
            .onChange(of: settings.dailyCalorieGoal) { _ in refreshRecommendation() }
            .onChange(of: settings.preferredFocus) { _ in refreshRecommendation() }
            .onChange(of: settings.availableWorkoutMinutes) { _ in refreshRecommendation() }
            .onChange(of: settings.preferredIntensity) { _ in refreshRecommendation() }
            .onChange(of: settings.isBeginner) { _ in refreshRecommendation() }
        }
    }

    private func recommendationDetail(_ recommendation: WorkoutRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Warm-up")
                .font(.headline)
            Text(recommendation.warmup)

            Text("Main work")
                .font(.headline)
            ForEach(recommendation.mainWork) { block in
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.name)
                        .font(.subheadline.bold())
                    Text(block.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(blockMeta(block))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Cooldown")
                .font(.headline)
            Text(recommendation.cooldown)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
    }

    private func blockMeta(_ block: WorkoutBlock) -> String {
        var parts = ["\(block.minutes) min"]

        if let sets = block.sets {
            parts.append("\(sets) sets")
        }

        if let reps = block.reps {
            parts.append(reps)
        }

        return parts.joined(separator: " • ")
    }

    private func refreshRecommendation() {
        viewModel.refresh(
            activeEnergy: healthKit.activeEnergy,
            calorieGoal: settings.dailyCalorieGoal,
            focus: settings.preferredFocus,
            availableMinutes: settings.availableWorkoutMinutes,
            intensity: settings.preferredIntensity,
            isBeginner: settings.isBeginner
        )
    }

    private func saveRecommendation() {
        historyStore.save(viewModel.currentRecommendation)
        Task {
            await healthKit.saveWorkout(viewModel.currentRecommendation)
        }
    }
}

struct CoachPage_Previews: PreviewProvider {
    static var previews: some View {
        CoachPage(historyStore: WorkoutHistoryStore())
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(WorkoutHistoryStore())
    }
}
