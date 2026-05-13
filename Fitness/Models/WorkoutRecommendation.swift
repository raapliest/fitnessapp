import Foundation

struct WorkoutRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let durationMinutes: Int
    let estimatedCalories: Int
    let systemImage: String
}
