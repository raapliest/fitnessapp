import Foundation

struct FormFeedback {
    let headline: String
    let detail: String
    let confidence: Double
    let isReadyForModelUpgrade: Bool

    static let waiting = FormFeedback(
        headline: "Frame your full body",
        detail: "Place your phone where your shoulders, hips, knees, and ankles are visible.",
        confidence: 0,
        isReadyForModelUpgrade: false
    )
}
