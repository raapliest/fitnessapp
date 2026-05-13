import Foundation

enum WorkoutFocus: String, CaseIterable, Identifiable {
    case balanced
    case strength
    case cardio
    case mobility

    var id: String { rawValue }

    var title: String {
        switch self {
        case .balanced:
            return "Balanced"
        case .strength:
            return "Strength"
        case .cardio:
            return "Cardio"
        case .mobility:
            return "Mobility"
        }
    }
}
