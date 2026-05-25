import Foundation

struct WorkoutRecommendation: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let durationMinutes: Int
    let estimatedCalories: Int
    let systemImage: String
    let intensity: WorkoutIntensity
    let targetCalories: Int
    let activeEnergyAtGeneration: Int
    let generatedAt: Date
    let warmup: String
    let mainWork: [WorkoutBlock]
    let cooldown: String
    let safetyNotes: [String]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        durationMinutes: Int,
        estimatedCalories: Int,
        systemImage: String,
        intensity: WorkoutIntensity,
        targetCalories: Int,
        activeEnergyAtGeneration: Int,
        generatedAt: Date = Date(),
        warmup: String,
        mainWork: [WorkoutBlock],
        cooldown: String,
        safetyNotes: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.durationMinutes = durationMinutes
        self.estimatedCalories = estimatedCalories
        self.systemImage = systemImage
        self.intensity = intensity
        self.targetCalories = targetCalories
        self.activeEnergyAtGeneration = activeEnergyAtGeneration
        self.generatedAt = generatedAt
        self.warmup = warmup
        self.mainWork = mainWork
        self.cooldown = cooldown
        self.safetyNotes = safetyNotes
    }
}

struct WorkoutBlock: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let detail: String
    let minutes: Int
    let sets: Int?
    let reps: String?

    init(
        id: UUID = UUID(),
        name: String,
        detail: String,
        minutes: Int,
        sets: Int? = nil,
        reps: String? = nil
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.minutes = minutes
        self.sets = sets
        self.reps = reps
    }
}

enum WorkoutIntensity: String, CaseIterable, Codable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
