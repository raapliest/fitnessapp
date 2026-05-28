import Foundation

enum ExerciseTrackingType: String, CaseIterable, Codable, Identifiable {
    case reps
    case weightedBodyweight
    case duration
    case weightedDuration
    case distance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .reps:
            return "Weight + reps"
        case .weightedBodyweight:
            return "Bodyweight +kg + reps"
        case .duration:
            return "Duration"
        case .weightedDuration:
            return "Weight + duration"
        case .distance:
            return "Distance"
        }
    }

    var targetFieldLabel: String {
        switch self {
        case .reps:
            return "Target reps"
        case .weightedBodyweight:
            return "Target reps"
        case .duration:
            return "Target time"
        case .weightedDuration:
            return "Target time"
        case .distance:
            return "Target distance"
        }
    }

    var logFieldLabel: String {
        switch self {
        case .reps:
            return "reps"
        case .weightedBodyweight:
            return "reps"
        case .duration:
            return "time"
        case .weightedDuration:
            return "time"
        case .distance:
            return "distance"
        }
    }

    var defaultTarget: String {
        switch self {
        case .reps:
            return "8-12"
        case .weightedBodyweight:
            return "4-8"
        case .duration:
            return "30-60 sec"
        case .weightedDuration:
            return "30-60 sec"
        case .distance:
            return "1 km"
        }
    }

    var loadFieldLabel: String? {
        switch self {
        case .reps:
            return "kg"
        case .weightedBodyweight:
            return "+kg"
        case .weightedDuration:
            return "kg"
        case .duration, .distance:
            return nil
        }
    }

    var usesNumericValueKeyboard: Bool {
        switch self {
        case .reps, .weightedBodyweight:
            return true
        case .duration, .weightedDuration, .distance:
            return false
        }
    }
}

struct ExerciseLibraryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let category: String
    let primaryMuscle: String
    let trackingType: ExerciseTrackingType

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        primaryMuscle: String,
        trackingType: ExerciseTrackingType = .reps
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.primaryMuscle = primaryMuscle
        self.trackingType = trackingType
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case primaryMuscle
        case trackingType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        primaryMuscle = try container.decode(String.self, forKey: .primaryMuscle)
        trackingType = try container.decodeIfPresent(ExerciseTrackingType.self, forKey: .trackingType) ?? .reps
    }
}

struct WorkoutRoutineExercise: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: String
    var targetSets: Int
    var targetReps: String
    var trackingType: ExerciseTrackingType

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        targetSets: Int = 3,
        targetReps: String = "8-12",
        trackingType: ExerciseTrackingType = .reps
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.trackingType = trackingType
    }

    var targetSummary: String {
        "\(targetSets) sets • \(targetReps)"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case targetSets
        case targetReps
        case trackingType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        targetSets = try container.decode(Int.self, forKey: .targetSets)
        let storedTarget = try container.decode(String.self, forKey: .targetReps)
        targetReps = storedTarget
        let inferredType = Self.inferredTrackingType(name: name, category: category, target: storedTarget)
        trackingType = try container.decodeIfPresent(ExerciseTrackingType.self, forKey: .trackingType)
            ?? Self.inferredTrackingType(name: name, category: category, target: targetReps)
        if inferredType == .duration && storedTarget == ExerciseTrackingType.reps.defaultTarget {
            targetReps = category == "Cardio" ? "10-20 min" : ExerciseTrackingType.duration.defaultTarget
        }
    }

    private static func inferredTrackingType(name: String, category: String, target: String) -> ExerciseTrackingType {
        let text = "\(name) \(category) \(target)".lowercased()
        if text.contains("weighted") && text.contains("plank") {
            return .weightedDuration
        }
        if text.contains("weighted") && (text.contains("pull") || text.contains("dip")) {
            return .weightedBodyweight
        }
        if text.contains("km") || text.contains("mile") {
            return .distance
        }
        if text.contains("plank") ||
            text.contains("run") ||
            text.contains("bike") ||
            text.contains("cardio") ||
            text.contains("sec") ||
            text.contains("min") {
            return .duration
        }
        return .reps
    }
}

struct WorkoutRoutine: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var note: String
    var exercises: [WorkoutRoutineExercise]

    init(
        id: UUID = UUID(),
        name: String,
        note: String = "",
        exercises: [WorkoutRoutineExercise]
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.exercises = exercises
    }
}

struct RoutineSetLog: Identifiable, Codable, Equatable {
    var id: UUID
    var exerciseID: UUID
    var exerciseName: String
    var setNumber: Int
    var kilograms: String
    var reps: String
    var trackingType: ExerciseTrackingType

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        exerciseName: String,
        setNumber: Int,
        kilograms: String = "",
        reps: String = "",
        trackingType: ExerciseTrackingType = .reps
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.kilograms = kilograms
        self.reps = reps
        self.trackingType = trackingType
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case exerciseID
        case exerciseName
        case setNumber
        case kilograms
        case reps
        case trackingType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exerciseID = try container.decode(UUID.self, forKey: .exerciseID)
        exerciseName = try container.decode(String.self, forKey: .exerciseName)
        setNumber = try container.decode(Int.self, forKey: .setNumber)
        kilograms = try container.decode(String.self, forKey: .kilograms)
        reps = try container.decode(String.self, forKey: .reps)
        trackingType = try container.decodeIfPresent(ExerciseTrackingType.self, forKey: .trackingType) ?? .reps
    }
}

struct RoutineWorkoutSession: Identifiable, Codable, Equatable {
    var id: UUID
    var routineName: String
    var finishedAt: Date
    var logs: [RoutineSetLog]

    init(
        id: UUID = UUID(),
        routineName: String,
        finishedAt: Date = Date(),
        logs: [RoutineSetLog]
    ) {
        self.id = id
        self.routineName = routineName
        self.finishedAt = finishedAt
        self.logs = logs
    }
}
