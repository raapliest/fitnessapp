import SwiftUI

struct WorkoutRecommendationRow: View {
    let workout: WorkoutRecommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: workout.systemImage)
                .font(.title2)
                .frame(width: 32)
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(workout.title)
                    .font(.headline)

                Text(workout.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(workout.durationMinutes) min • ~\(workout.estimatedCalories) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct WorkoutRecommendationRow_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecommendationRow(
            workout: WorkoutRecommendation(
                title: "Full-body circuit",
                subtitle: "Squats, push-ups, rows, and planks.",
                durationMinutes: 24,
                estimatedCalories: 190,
                systemImage: "figure.highintensity.intervaltraining"
            )
        )
    }
}
