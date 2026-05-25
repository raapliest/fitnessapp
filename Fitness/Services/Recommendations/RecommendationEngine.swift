import Foundation

struct RecommendationEngine {
    func recommendation(
        activeEnergy: Double,
        calorieGoal: Double,
        focus: WorkoutFocus,
        availableMinutes: Int,
        intensity requestedIntensity: WorkoutIntensity,
        isBeginner: Bool
    ) -> WorkoutRecommendation {
        let normalizedGoal = min(max(Int(calorieGoal), 150), 900)
        let currentEnergy = max(Int(activeEnergy), 0)
        let remainingCalories = max(normalizedGoal - currentEnergy, 0)
        let duration = normalizedDuration(availableMinutes)
        let intensity = safeIntensity(requestedIntensity, isBeginner: isBeginner)
        let targetCalories = targetCalories(
            remainingCalories: remainingCalories,
            duration: duration,
            intensity: intensity
        )
        let structure = structure(
            focus: focus,
            duration: duration,
            intensity: intensity,
            targetCalories: targetCalories,
            remainingCalories: remainingCalories
        )

        return WorkoutRecommendation(
            title: structure.title,
            subtitle: structure.subtitle,
            durationMinutes: duration,
            estimatedCalories: targetCalories,
            systemImage: structure.systemImage,
            intensity: intensity,
            targetCalories: normalizedGoal,
            activeEnergyAtGeneration: currentEnergy,
            warmup: warmup(for: duration),
            mainWork: structure.blocks,
            cooldown: cooldown(for: duration),
            safetyNotes: safetyNotes(
                requestedIntensity: requestedIntensity,
                actualIntensity: intensity,
                remainingCalories: remainingCalories,
                targetCalories: targetCalories,
                isBeginner: isBeginner
            )
        )
    }

    func recommendations(
        activeEnergy: Double,
        calorieGoal: Double,
        focus: WorkoutFocus
    ) -> [WorkoutRecommendation] {
        [15, 30, 60].map { minutes in
            recommendation(
                activeEnergy: activeEnergy,
                calorieGoal: calorieGoal,
                focus: focus,
                availableMinutes: minutes,
                intensity: minutes == 60 ? .medium : .low,
                isBeginner: true
            )
        }
    }

    private func normalizedDuration(_ minutes: Int) -> Int {
        if minutes <= 15 {
            return 15
        }

        if minutes <= 30 {
            return 30
        }

        return 60
    }

    private func safeIntensity(
        _ requestedIntensity: WorkoutIntensity,
        isBeginner: Bool
    ) -> WorkoutIntensity {
        guard isBeginner, requestedIntensity == .high else {
            return requestedIntensity
        }

        return .medium
    }

    private func targetCalories(
        remainingCalories: Int,
        duration: Int,
        intensity: WorkoutIntensity
    ) -> Int {
        guard remainingCalories > 40 else {
            return min(60, max(35, remainingCalories))
        }

        let intensityCap: Int
        switch intensity {
        case .low:
            intensityCap = duration * 5
        case .medium:
            intensityCap = duration * 8
        case .high:
            intensityCap = duration * 11
        }

        let overtrainingCap = min(remainingCalories, 420)
        return max(60, min(intensityCap, overtrainingCap))
    }

    private func warmup(for duration: Int) -> String {
        duration == 15
            ? "3 min easy walk plus shoulder and hip circles."
            : "5 min easy cardio plus dynamic hips, ankles, and shoulders."
    }

    private func cooldown(for duration: Int) -> String {
        duration == 15
            ? "2 min slow breathing and light lower-body stretch."
            : "5 min easy walk, nasal breathing, calf, quad, and chest stretch."
    }

    private func safetyNotes(
        requestedIntensity: WorkoutIntensity,
        actualIntensity: WorkoutIntensity,
        remainingCalories: Int,
        targetCalories: Int,
        isBeginner: Bool
    ) -> [String] {
        var notes = [
            "Warm-up and cooldown are included.",
            "Stop if pain, dizziness, or unusual shortness of breath appears."
        ]

        if isBeginner && requestedIntensity != actualIntensity {
            notes.append("High intensity was capped to medium for beginner safety.")
        }

        if remainingCalories <= 40 {
            notes.append("You are near today's goal, so the plan stays recovery-focused.")
        }

        if targetCalories >= 420 {
            notes.append("Calorie target was capped to avoid overtraining.")
        }

        return notes
    }

    private func structure(
        focus: WorkoutFocus,
        duration: Int,
        intensity: WorkoutIntensity,
        targetCalories: Int,
        remainingCalories: Int
    ) -> WorkoutStructure {
        if remainingCalories <= 40 {
            return recoveryStructure(duration: duration, targetCalories: targetCalories)
        }

        switch focus {
        case .balanced:
            return balancedStructure(duration: duration, intensity: intensity)
        case .strength:
            return strengthStructure(duration: duration, intensity: intensity)
        case .cardio:
            return cardioStructure(duration: duration, intensity: intensity)
        case .mobility:
            return mobilityStructure(duration: duration, intensity: intensity)
        }
    }

    private func balancedStructure(duration: Int, intensity: WorkoutIntensity) -> WorkoutStructure {
        WorkoutStructure(
            title: "Balanced calorie builder",
            subtitle: "\(duration) min mix of cardio and strength at \(intensity.title.lowercased()) intensity.",
            systemImage: "figure.mixed.cardio",
            blocks: [
                WorkoutBlock(name: "Cardio base", detail: "Incline walk, bike, or row at steady effort.", minutes: duration / 3),
                WorkoutBlock(name: "Strength circuit", detail: "Squat, push, row, hinge, and carry.", minutes: duration / 2, sets: intensity == .low ? 2 : 3, reps: "8-12 each"),
                WorkoutBlock(name: "Core finisher", detail: "Dead bug and side plank.", minutes: max(duration / 6, 3), sets: 2, reps: "30 sec")
            ]
        )
    }

    private func strengthStructure(duration: Int, intensity: WorkoutIntensity) -> WorkoutStructure {
        WorkoutStructure(
            title: "Strength-first session",
            subtitle: "Controlled full-body strength with a short cardio finish.",
            systemImage: "figure.strengthtraining.traditional",
            blocks: [
                WorkoutBlock(name: "Lower body", detail: "Goblet squat and Romanian deadlift.", minutes: duration / 3, sets: intensity == .low ? 2 : 3, reps: "8-10"),
                WorkoutBlock(name: "Upper body", detail: "Incline push-up and one-arm row.", minutes: duration / 3, sets: intensity == .high ? 4 : 3, reps: "8-12"),
                WorkoutBlock(name: "Cardio finish", detail: "Bike or treadmill at conversational pace.", minutes: duration / 4)
            ]
        )
    }

    private func cardioStructure(duration: Int, intensity: WorkoutIntensity) -> WorkoutStructure {
        let intervalDetail = intensity == .high
            ? "60 sec strong, 90 sec easy repeats."
            : "45 sec brisk, 90 sec easy repeats."

        return WorkoutStructure(
            title: "Cardio progress session",
            subtitle: "Cardio-led plan that scales with today's remaining calories.",
            systemImage: "figure.run",
            blocks: [
                WorkoutBlock(name: "Steady cardio", detail: "Walk, bike, elliptical, or row.", minutes: duration / 2),
                WorkoutBlock(name: "Intervals", detail: intervalDetail, minutes: duration / 3),
                WorkoutBlock(name: "Easy flush", detail: "Drop to low effort before cooldown.", minutes: max(duration / 6, 3))
            ]
        )
    }

    private func mobilityStructure(duration: Int, intensity: WorkoutIntensity) -> WorkoutStructure {
        WorkoutStructure(
            title: "Mobility and light burn",
            subtitle: "Low-impact movement for recovery, posture, and consistency.",
            systemImage: "figure.flexibility",
            blocks: [
                WorkoutBlock(name: "Easy cardio", detail: "Walk or bike at low effort.", minutes: duration / 3),
                WorkoutBlock(name: "Mobility flow", detail: "Hips, hamstrings, thoracic rotation, calves.", minutes: duration / 2),
                WorkoutBlock(name: "Core stability", detail: "Bird dog, dead bug, and plank variation.", minutes: max(duration / 6, 3), sets: intensity == .low ? 1 : 2, reps: "30 sec")
            ]
        )
    }

    private func recoveryStructure(duration: Int, targetCalories: Int) -> WorkoutStructure {
        WorkoutStructure(
            title: "Recovery finish",
            subtitle: "You are close to today's goal, so this keeps intensity low.",
            systemImage: "figure.cooldown",
            blocks: [
                WorkoutBlock(name: "Easy walk", detail: "Stay relaxed and conversational.", minutes: max(duration - 7, 8)),
                WorkoutBlock(name: "Mobility reset", detail: "Hips, calves, chest, and breathing.", minutes: min(7, duration / 2))
            ]
        )
    }
}

private struct WorkoutStructure {
    let title: String
    let subtitle: String
    let systemImage: String
    let blocks: [WorkoutBlock]
}
