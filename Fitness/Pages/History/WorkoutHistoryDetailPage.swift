import SwiftUI

struct WorkoutHistoryDetailPage: View {
    let recommendation: WorkoutRecommendation

    var body: some View {
        List {
            Section("Summary") {
                WorkoutRecommendationRow(workout: recommendation)
                Label(
                    recommendation.generatedAt.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                Label(
                    "\(recommendation.activeEnergyAtGeneration) kcal active when generated",
                    systemImage: "flame"
                )
            }

            Section("Warm-up") {
                Text(recommendation.warmup)
            }

            Section("Main work") {
                ForEach(recommendation.mainWork) { block in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(block.name)
                            .font(.headline)
                        Text(block.detail)
                            .foregroundStyle(.secondary)
                        Text(blockMeta(block))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Cooldown") {
                Text(recommendation.cooldown)
            }

            Section("Safety") {
                ForEach(recommendation.safetyNotes, id: \.self) { note in
                    Label(note, systemImage: "checkmark.shield")
                }
            }
        }
        .navigationTitle("Workout Detail")
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
}

struct WorkoutHistoryDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutHistoryDetailPage(
                recommendation: RecommendationEngine().recommendation(
                    activeEnergy: 220,
                    calorieGoal: 550,
                    focus: .balanced,
                    availableMinutes: 30,
                    intensity: .medium,
                    isBeginner: true
                )
            )
        }
    }
}
