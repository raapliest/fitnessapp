import AVFoundation
import CoreGraphics
import CoreML
import Foundation
import Vision

final class FormFeedbackAnalyzer {
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    private let trainerScorer: TrainerMovementScoring
    private var selectedMovement: TrainerMovement = .squat
    private var repCount = 0
    private var wasInRepBottom = false

    init(trainerScorer: TrainerMovementScoring = HeuristicTrainerMovementScorer()) {
        self.trainerScorer = trainerScorer
    }

    func setMovement(_ movement: TrainerMovement) {
        guard selectedMovement != movement else {
            return
        }

        selectedMovement = movement
        repCount = 0
        wasInRepBottom = false
    }

    func analyze(sampleBuffer: CMSampleBuffer) -> FormFeedback {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return .waiting
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)

        do {
            try handler.perform([bodyPoseRequest])
            guard let observation = bodyPoseRequest.results?.first else {
                return .waiting
            }

            let points = try observation.recognizedPoints(.all)
            return feedback(from: points)
        } catch {
            return FormFeedback(
                headline: "Pose unavailable",
                detail: "Vision could not read this frame. Improve lighting and keep moving slowly.",
                confidence: 0,
                isReadyForModelUpgrade: false,
                trainerScore: .waiting
            )
        }
    }

    private func feedback(from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> FormFeedback {
        let visiblePoints = points.values.filter { $0.confidence > 0.35 }
        let confidence = visiblePoints.map(\.confidence).average
        let hasLowerBody = hasVisiblePoint(.leftKnee, in: points)
            && hasVisiblePoint(.rightKnee, in: points)
            && hasVisiblePoint(.leftAnkle, in: points)
            && hasVisiblePoint(.rightAnkle, in: points)

        if !hasLowerBody {
            return FormFeedback(
                headline: "Step back a little",
                detail: "Your lower body is partly out of frame. Full-body visibility improves squat and lunge feedback.",
                confidence: confidence,
                isReadyForModelUpgrade: false,
                trainerScore: .waiting
            )
        }

        updateRepCount(with: points)
        let trainerScore = trainerScorer.score(
            movement: selectedMovement,
            points: points,
            repCount: repCount
        )

        return FormFeedback(
            headline: "\(selectedMovement.title) score \(Int(trainerScore.score * 100))",
            detail: trainerScore.cue,
            confidence: confidence,
            isReadyForModelUpgrade: true,
            trainerScore: trainerScore
        )
    }

    private func updateRepCount(with points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard selectedMovement != .plank else {
            return
        }

        let kneeDepth = average([
            normalizedLegDepth(hip: .leftHip, knee: .leftKnee, ankle: .leftAnkle, points: points),
            normalizedLegDepth(hip: .rightHip, knee: .rightKnee, ankle: .rightAnkle, points: points)
        ])

        if kneeDepth > 0.72 {
            wasInRepBottom = true
        } else if kneeDepth < 0.55 && wasInRepBottom {
            repCount += 1
            wasInRepBottom = false
        }
    }

    private func normalizedLegDepth(
        hip: VNHumanBodyPoseObservation.JointName,
        knee: VNHumanBodyPoseObservation.JointName,
        ankle: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Double {
        guard
            let hipPoint = point(hip, in: points),
            let kneePoint = point(knee, in: points),
            let anklePoint = point(ankle, in: points)
        else {
            return 0
        }

        let upperLeg = distance(hipPoint.location, kneePoint.location)
        let lowerLeg = distance(kneePoint.location, anklePoint.location)
        guard lowerLeg > 0 else {
            return 0
        }

        return min(max(upperLeg / lowerLeg, 0), 1)
    }

    private func average(_ values: [Double]) -> Double {
        let validValues = values.filter { $0 > 0 }
        guard !validValues.isEmpty else {
            return 0
        }

        return validValues.reduce(0, +) / Double(validValues.count)
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> Double {
        let x = Double(first.x - second.x)
        let y = Double(first.y - second.y)
        return sqrt((x * x) + (y * y))
    }

    private func hasVisiblePoint(
        _ name: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Bool {
        point(name, in: points) != nil
    }

    private func point(
        _ name: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> VNRecognizedPoint? {
        guard let point = points[name], point.confidence > 0.35 else {
            return nil
        }

        return point
    }
}

private extension Array where Element == VNConfidence {
    var average: Double {
        guard !isEmpty else {
            return 0
        }

        let total = reduce(0) { $0 + Double($1) }
        return total / Double(count)
    }
}
