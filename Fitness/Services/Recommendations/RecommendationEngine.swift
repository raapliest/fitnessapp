import Foundation

struct RecommendationEngine {
    func recommendations(
        activeEnergy: Double,
        calorieGoal: Double,
        focus: WorkoutFocus
    ) -> [WorkoutRecommendation] {
        let remaining = max(calorieGoal - activeEnergy, 0)

        if remaining < 80 {
            return [
                WorkoutRecommendation(
                    title: "Recovery mobility",
                    subtitle: "You are close to your target. Keep joints loose and breathing easy.",
                    durationMinutes: 12,
                    estimatedCalories: 45,
                    systemImage: "figure.cooldown"
                ),
                WorkoutRecommendation(
                    title: "Walk and stretch",
                    subtitle: "A gentle finish that supports consistency without overreaching.",
                    durationMinutes: 20,
                    estimatedCalories: 70,
                    systemImage: "figure.walk"
                )
            ]
        }

        switch focus {
        case .balanced:
            return balancedPlan(remaining: remaining)
        case .strength:
            return strengthPlan(remaining: remaining)
        case .cardio:
            return cardioPlan(remaining: remaining)
        case .mobility:
            return mobilityPlan(remaining: remaining)
        }
    }

    private func balancedPlan(remaining: Double) -> [WorkoutRecommendation] {
        [
            WorkoutRecommendation(
                title: "Full-body circuit",
                subtitle: "Squats, push-ups, rows, and planks with short rests.",
                durationMinutes: remaining > 250 ? 35 : 24,
                estimatedCalories: remaining > 250 ? 300 : 190,
                systemImage: "figure.highintensity.intervaltraining"
            ),
            WorkoutRecommendation(
                title: "Incline walk",
                subtitle: "Steady Zone 2 effort to build your base.",
                durationMinutes: 30,
                estimatedCalories: 210,
                systemImage: "figure.walk.motion"
            )
        ]
    }

    private func strengthPlan(remaining: Double) -> [WorkoutRecommendation] {
        [
            WorkoutRecommendation(
                title: "Lower-body strength",
                subtitle: "Goblet squats, hinges, split squats, and carries.",
                durationMinutes: 40,
                estimatedCalories: 260,
                systemImage: "figure.strengthtraining.traditional"
            ),
            WorkoutRecommendation(
                title: "Core finisher",
                subtitle: "Dead bugs, side planks, and slow mountain climbers.",
                durationMinutes: 14,
                estimatedCalories: Int(min(max(remaining, 90), 150)),
                systemImage: "figure.core.training"
            )
        ]
    }

    private func cardioPlan(remaining: Double) -> [WorkoutRecommendation] {
        [
            WorkoutRecommendation(
                title: "Intervals",
                subtitle: "Eight rounds of 45 seconds hard, 75 seconds easy.",
                durationMinutes: 24,
                estimatedCalories: 280,
                systemImage: "timer"
            ),
            WorkoutRecommendation(
                title: "Easy run",
                subtitle: "Conversational pace with a five-minute cool down.",
                durationMinutes: 35,
                estimatedCalories: 320,
                systemImage: "figure.run"
            )
        ]
    }

    private func mobilityPlan(remaining: Double) -> [WorkoutRecommendation] {
        [
            WorkoutRecommendation(
                title: "Desk reset",
                subtitle: "Hips, thoracic rotation, calves, and hamstrings.",
                durationMinutes: 18,
                estimatedCalories: 75,
                systemImage: "figure.flexibility"
            ),
            WorkoutRecommendation(
                title: "Long walk",
                subtitle: "Low-impact energy with posture checkpoints.",
                durationMinutes: remaining > 200 ? 45 : 25,
                estimatedCalories: remaining > 200 ? 240 : 130,
                systemImage: "figure.walk"
            )
        ]
    }
}
