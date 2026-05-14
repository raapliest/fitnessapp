import SwiftUI

struct FormCoachPage: View {
    @StateObject private var camera = CameraViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        Picker("Movement", selection: $camera.selectedMovement) {
                            ForEach(TrainerMovement.allCases) { movement in
                                Text(movement.title).tag(movement)
                            }
                        }
                        .pickerStyle(.segmented)

                        CameraPreview(session: camera.session)
                            .frame(maxWidth: .infinity)
                            .frame(height: min(proxy.size.height * 0.48, 420))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        FormFeedbackPanel(feedback: camera.feedback, cameraStatus: camera.cameraStatus)
                    }
                    .padding()
                }
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
