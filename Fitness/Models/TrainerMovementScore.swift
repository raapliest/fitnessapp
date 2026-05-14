import Foundation

struct TrainerMovementScore {
    let movement: TrainerMovement
    let repCount: Int
    let score: Double
    let tempoScore: Double
    let stabilityScore: Double
    let depthScore: Double
    let cue: String

    static let waiting = TrainerMovementScore(
        movement: .squat,
        repCount: 0,
        score: 0,
        tempoScore: 0,
        stabilityScore: 0,
        depthScore: 0,
        cue: "Start camera tracking to score movement quality."
    )
}
