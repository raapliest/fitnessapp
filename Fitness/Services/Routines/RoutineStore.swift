import Foundation

@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [WorkoutRoutine] {
        didSet { persist() }
    }

    private let storageKey = "workoutRoutines"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([WorkoutRoutine].self, from: data) {
            routines = decoded
        } else {
            routines = Self.defaultRoutines()
        }
    }

    func addRoutine(_ routine: WorkoutRoutine) {
        routines.insert(routine, at: 0)
    }

    func updateRoutine(_ routine: WorkoutRoutine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index] = routine
    }

    func deleteRoutine(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
    }

    func saveFinishedSession(_ session: RoutineWorkoutSession, to historyStore: WorkoutHistoryStore) {
        let groupedLogs = Dictionary(grouping: session.logs) { $0.exerciseName }
        let blocks = groupedLogs.keys.sorted().map { name in
            let detail = (groupedLogs[name] ?? [])
                .sorted { $0.setNumber < $1.setNumber }
                .map { log in
                    Self.formattedLogDetail(log)
                }
                .joined(separator: ", ")

            return WorkoutBlock(name: name, detail: detail, minutes: 0)
        }

        historyStore.save(
            WorkoutRecommendation(
                title: session.routineName,
                subtitle: "Routine workout finished with \(session.logs.count) logged sets.",
                durationMinutes: 0,
                estimatedCalories: 0,
                systemImage: "dumbbell.fill",
                intensity: .medium,
                targetCalories: 0,
                activeEnergyAtGeneration: 0,
                generatedAt: session.finishedAt,
                warmup: "Routine session",
                mainWork: blocks,
                cooldown: "Finished workout",
                safetyNotes: ["Logged routine workout."]
            )
        )
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(routines) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func formattedLogDetail(_ log: RoutineSetLog) -> String {
        let value = log.reps.isEmpty ? "-" : log.reps
        let load = log.kilograms.isEmpty ? "" : "\(log.kilograms) kg, "

        switch log.trackingType {
        case .reps:
            return "Set \(log.setNumber): \(log.kilograms.isEmpty ? "-" : log.kilograms) kg x \(value)"
        case .weightedBodyweight:
            return "Set \(log.setNumber): +\(log.kilograms.isEmpty ? "-" : log.kilograms) kg x \(value)"
        case .duration:
            return "Set \(log.setNumber): \(value)"
        case .weightedDuration:
            return "Set \(log.setNumber): \(load)\(value)"
        case .distance:
            return "Set \(log.setNumber): \(value)"
        }
    }

    private static func defaultRoutines() -> [WorkoutRoutine] {
        [
            WorkoutRoutine(
                name: "Push Day",
                note: "Chest, shoulders, and triceps.",
                exercises: [
                    WorkoutRoutineExercise(name: "Bench Press", category: "Push", targetSets: 3, targetReps: "6-10"),
                    WorkoutRoutineExercise(name: "Shoulder Press", category: "Push", targetSets: 3, targetReps: "8-10"),
                    WorkoutRoutineExercise(name: "Lateral Raise", category: "Push", targetSets: 3, targetReps: "12-15"),
                    WorkoutRoutineExercise(name: "Triceps Pushdown", category: "Push", targetSets: 3, targetReps: "10-12")
                ]
            ),
            WorkoutRoutine(
                name: "Pull Day",
                note: "Back and biceps.",
                exercises: [
                    WorkoutRoutineExercise(name: "Pull-up", category: "Pull", targetSets: 3, targetReps: "AMRAP"),
                    WorkoutRoutineExercise(name: "Barbell Row", category: "Pull", targetSets: 3, targetReps: "8-10"),
                    WorkoutRoutineExercise(name: "Lat Pulldown", category: "Pull", targetSets: 3, targetReps: "10-12"),
                    WorkoutRoutineExercise(name: "Biceps Curl", category: "Pull", targetSets: 3, targetReps: "10-12")
                ]
            ),
            WorkoutRoutine(
                name: "Leg Day",
                note: "Quads, hamstrings, glutes, and calves.",
                exercises: [
                    WorkoutRoutineExercise(name: "Back Squat", category: "Legs", targetSets: 3, targetReps: "6-10"),
                    WorkoutRoutineExercise(name: "Romanian Deadlift", category: "Legs", targetSets: 3, targetReps: "8-10"),
                    WorkoutRoutineExercise(name: "Walking Lunge", category: "Legs", targetSets: 3, targetReps: "10 each"),
                    WorkoutRoutineExercise(name: "Calf Raise", category: "Legs", targetSets: 4, targetReps: "12-15")
                ]
            )
        ]
    }
}
