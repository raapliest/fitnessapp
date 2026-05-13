import Foundation

struct ReadinessItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let isComplete: Bool
}
