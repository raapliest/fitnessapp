import AVFoundation
import CoreML
import Foundation
import Vision

final class FormFeedbackAnalyzer {
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()

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
                isReadyForModelUpgrade: false
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
                isReadyForModelUpgrade: false
            )
        }

        return FormFeedback(
            headline: "Good tracking",
            detail: "Vision is detecting your joints. Next path: route these pose vectors into a Core ML classifier for rep counting and form scoring.",
            confidence: confidence,
            isReadyForModelUpgrade: true
        )
    }

    private func hasVisiblePoint(
        _ name: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Bool {
        guard let point = points[name] else {
            return false
        }

        return point.confidence > 0.35
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
