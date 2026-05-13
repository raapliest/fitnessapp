import SwiftUI

struct FormFeedbackPanel: View {
    let feedback: FormFeedback
    let cameraStatus: String

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

            Text(cameraStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding([.horizontal, .bottom])
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
