import SwiftUI

struct MedicalDisclaimerView: View {
    let accept: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Label("Before You Start", systemImage: "cross.case.fill")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.red)

                Text("Fitness Coach provides general wellness and exercise guidance. It is not medical advice, diagnosis, treatment, or a replacement for a qualified clinician.")
                    .font(.body)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Stop if you feel pain, dizziness, chest pressure, or unusual shortness of breath.", systemImage: "exclamationmark.triangle")
                    Label("Ask a medical professional before changing exercise habits if you have an injury, condition, or health concern.", systemImage: "stethoscope")
                    Label("HealthKit, camera, and coaching data can be incomplete or inaccurate.", systemImage: "waveform.path.ecg")
                }
                .font(.callout)
                .foregroundStyle(.secondary)

                Spacer()

                Button(action: accept) {
                    Label("I Understand", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Disclaimer")
        }
    }
}

struct MedicalDisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalDisclaimerView(accept: {})
    }
}
