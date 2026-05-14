import CoreGraphics
import CoreML
import Foundation
import Vision

protocol TrainerMovementScoring {
    func score(
        movement: TrainerMovement,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore
}

final class HeuristicTrainerMovementScorer: TrainerMovementScoring {
    func score(
        movement: TrainerMovement,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore {
        switch movement {
        case .squat:
            return squatScore(points: points, repCount: repCount)
        case .lunge:
            return lungeScore(points: points, repCount: repCount)
        case .plank:
            return plankScore(points: points, repCount: repCount)
        }
    }

    private func squatScore(
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore {
        let leftDepth = kneeDepth(hip: .leftHip, knee: .leftKnee, ankle: .leftAnkle, points: points)
        let rightDepth = kneeDepth(hip: .rightHip, knee: .rightKnee, ankle: .rightAnkle, points: points)
        let depth = average([leftDepth, rightDepth])
        let stability = horizontalBalance(.leftHip, .rightHip, points: points)
        let score = average([depth, stability])

        return TrainerMovementScore(
            movement: .squat,
            repCount: repCount,
            score: score,
            tempoScore: score,
            stabilityScore: stability,
            depthScore: depth,
            cue: depth > 0.65 ? "Good squat depth. Keep knees tracking over toes." : "Sit lower only if it feels controlled and pain-free."
        )
    }

    private func lungeScore(
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore {
        let frontDepth = max(
            kneeDepth(hip: .leftHip, knee: .leftKnee, ankle: .leftAnkle, points: points),
            kneeDepth(hip: .rightHip, knee: .rightKnee, ankle: .rightAnkle, points: points)
        )
        let stability = horizontalBalance(.leftShoulder, .rightShoulder, points: points)
        let score = average([frontDepth, stability])

        return TrainerMovementScore(
            movement: .lunge,
            repCount: repCount,
            score: score,
            tempoScore: score,
            stabilityScore: stability,
            depthScore: frontDepth,
            cue: stability > 0.6 ? "Torso looks steady. Keep the front foot planted." : "Slow down and keep your shoulders level."
        )
    }

    private func plankScore(
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore {
        let shoulderHipLine = horizontalBalance(.leftShoulder, .leftHip, points: points)
        let hipKneeLine = horizontalBalance(.leftHip, .leftKnee, points: points)
        let stability = average([shoulderHipLine, hipKneeLine])

        return TrainerMovementScore(
            movement: .plank,
            repCount: repCount,
            score: stability,
            tempoScore: stability,
            stabilityScore: stability,
            depthScore: stability,
            cue: stability > 0.65 ? "Strong plank line. Keep breathing steadily." : "Brace gently and bring shoulders, hips, and knees into one line."
        )
    }

    private func kneeDepth(
        hip: VNHumanBodyPoseObservation.JointName,
        knee: VNHumanBodyPoseObservation.JointName,
        ankle: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Double {
        guard
            let hipPoint = confidentPoint(hip, points: points),
            let kneePoint = confidentPoint(knee, points: points),
            let anklePoint = confidentPoint(ankle, points: points)
        else {
            return 0
        }

        let upperLeg = distance(hipPoint, kneePoint)
        let lowerLeg = distance(kneePoint, anklePoint)
        guard lowerLeg > 0 else {
            return 0
        }

        return min(max(upperLeg / lowerLeg, 0), 1)
    }

    private func horizontalBalance(
        _ first: VNHumanBodyPoseObservation.JointName,
        _ second: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Double {
        guard
            let firstPoint = confidentPoint(first, points: points),
            let secondPoint = confidentPoint(second, points: points)
        else {
            return 0
        }

        let difference = abs(firstPoint.y - secondPoint.y)
        return min(max(1 - (difference * 4), 0), 1)
    }

    private func confidentPoint(
        _ name: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CGPoint? {
        guard let point = points[name], point.confidence > 0.35 else {
            return nil
        }

        return point.location
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> Double {
        let x = Double(first.x - second.x)
        let y = Double(first.y - second.y)
        return sqrt((x * x) + (y * y))
    }

    private func average(_ values: [Double]) -> Double {
        let validValues = values.filter { $0 > 0 }
        guard !validValues.isEmpty else {
            return 0
        }

        return validValues.reduce(0, +) / Double(validValues.count)
    }
}

final class CoreMLTrainerMovementScorer: TrainerMovementScoring {
    private let model: MLModel

    init(model: MLModel) {
        self.model = model
    }

    func score(
        movement: TrainerMovement,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        repCount: Int
    ) -> TrainerMovementScore {
        _ = model
        _ = points

        return TrainerMovementScore(
            movement: movement,
            repCount: repCount,
            score: 0,
            tempoScore: 0,
            stabilityScore: 0,
            depthScore: 0,
            cue: "Core ML trainer model is connected. Map model outputs into movement scores here."
        )
    }
}
