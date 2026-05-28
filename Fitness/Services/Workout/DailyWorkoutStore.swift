import Foundation

@MainActor
final class DailyWorkoutStore: ObservableObject {
    @Published private(set) var workout: DailyWorkout {
        didSet { save() }
    }

    private let storageKey = "dailyWorkout"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(DailyWorkout.self, from: data),
           Calendar.current.isDateInToday(decoded.date) {
            workout = decoded
        } else {
            workout = Self.defaultWorkout()
        }
    }

    func addExercise(_ exercise: WorkoutExercise) {
        workout.exercises.append(exercise)
    }

    func updateExercise(_ exercise: WorkoutExercise) {
        guard let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        workout.exercises[index] = exercise
    }

    func deleteExercise(at offsets: IndexSet) {
        workout.exercises.remove(atOffsets: offsets)
    }

    func toggleExercise(_ exercise: WorkoutExercise) {
        guard let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        workout.exercises[index].isCompleted.toggle()
    }

    func updateTitle(_ title: String) {
        workout.title = title
    }

    func updateNotes(_ notes: String) {
        workout.notes = notes
    }

    func resetToday() {
        workout = Self.defaultWorkout()
    }

    func applyRecommendation(_ recommendation: WorkoutRecommendation) {
        workout = DailyWorkout(
            title: recommendation.title,
            notes: recommendation.subtitle,
            exercises: recommendation.mainWork.map {
                WorkoutExercise(
                    name: $0.name,
                    detail: $0.detail,
                    sets: $0.sets ?? 1,
                    reps: $0.reps ?? "Timed",
                    minutes: $0.minutes
                )
            }
        )
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(workout) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func defaultWorkout() -> DailyWorkout {
        DailyWorkout(
            exercises: [
                WorkoutExercise(name: "Warm-up mobility", detail: "Easy full-body movement", sets: 1, reps: "5 min", minutes: 5),
                WorkoutExercise(name: "Bodyweight squats", detail: "Controlled tempo, full foot grounded", sets: 3, reps: "10-12", minutes: 8),
                WorkoutExercise(name: "Incline push-ups", detail: "Keep ribs down and elbows controlled", sets: 3, reps: "8-10", minutes: 7),
                WorkoutExercise(name: "Plank", detail: "Steady breathing, stop before form breaks", sets: 3, reps: "20-30 sec", minutes: 5)
            ]
        )
    }
}
