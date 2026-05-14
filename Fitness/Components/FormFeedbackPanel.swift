import SwiftUI

struct FormFeedbackPanel: View {
    let feedback: FormFeedback
    let cameraStatus: String

    private let metricColumns = [
        GridItem(.flexible(minimum: 72), spacing: 10),
        GridItem(.flexible(minimum: 72), spacing: 10),
        GridItem(.flexible(minimum: 72), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(feedback.headline, systemImage: feedback.isReadyForModelUpgrade ? "checkmark.circle.fill" : "viewfinder")
                .font(.headline)
                .foregroundStyle(feedback.isReadyForModelUpgrade ? .green : .orange)

            Text(feedback.detail)
                .font(.body)
                .foregroundStyle(.secondary)

            ProgressView(value: feedback.confidence) {
                Text("Pose confidence")
            }
            .tint(feedback.isReadyForModelUpgrade ? .green : .orange)

            VStack(alignment: .leading, spacing: 10) {
                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 10) {
                    trainerMetric("Reps", value: "\(feedback.trainerScore.repCount)")
                    trainerMetric("Form", value: "\(Int(feedback.trainerScore.score * 100))")
                    trainerMetric("Stability", value: "\(Int(feedback.trainerScore.stabilityScore * 100))")
                }

                ProgressView(value: feedback.trainerScore.depthScore) {
                    Text("\(feedback.trainerScore.movement.title) depth")
                }
                .tint(.blue)
            }

            Text(cameraStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func trainerMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold())
        }
    }
}

struct FormFeedbackPanel_Previews: PreviewProvider {
    static var previews: some View {
        FormFeedbackPanel(
            feedback: .waiting,
            cameraStatus: "Camera is not running."
        )
    }
}
