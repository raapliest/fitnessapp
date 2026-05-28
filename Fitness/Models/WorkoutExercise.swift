import Foundation

struct WorkoutExercise: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var detail: String
    var sets: Int
    var reps: String
    var minutes: Int
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        name: String,
        detail: String,
        sets: Int,
        reps: String,
        minutes: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.sets = sets
        self.reps = reps
        self.minutes = minutes
        self.isCompleted = isCompleted
    }
}
