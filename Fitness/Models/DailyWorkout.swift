import Foundation

struct DailyWorkout: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var title: String
    var notes: String
    var exercises: [WorkoutExercise]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String = "Today's Workout",
        notes: String = "",
        exercises: [WorkoutExercise] = []
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.notes = notes
        self.exercises = exercises
    }

    var completedCount: Int {
        exercises.filter(\.isCompleted).count
    }

    var totalMinutes: Int {
        exercises.reduce(0) { $0 + $1.minutes }
    }
}
