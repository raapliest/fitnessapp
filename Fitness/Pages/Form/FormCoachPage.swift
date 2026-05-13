import SwiftUI

struct FormCoachPage: View {
    @StateObject private var camera = CameraViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CameraPreview(session: camera.session)
                    .frame(maxWidth: .infinity)
                    .frame(height: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()

                FormFeedbackPanel(feedback: camera.feedback, cameraStatus: camera.cameraStatus)

                Spacer(minLength: 0)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Form Feedback")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: camera.start) {
                        Label("Start Camera", systemImage: "play.fill")
                    }
                }
            }
            .onDisappear(perform: camera.stop)
        }
    }
}

struct FormCoachPage_Previews: PreviewProvider {
    static var previews: some View {
        FormCoachPage()
    }
}
