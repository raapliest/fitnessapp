import Foundation

enum TrainerMovement: String, CaseIterable, Identifiable {
    case squat
    case lunge
    case plank

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .squat:
            return "Squat"
        case .lunge:
            return "Lunge"
        case .plank:
            return "Plank"
        }
    }
}
