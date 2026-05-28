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

                        ZStack {
                            CameraPreview(session: camera.session)
                            PoseSkeletonOverlay(skeleton: camera.skeleton)
                        }
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

private struct PoseSkeletonOverlay: View {
    let skeleton: PoseSkeleton

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                var linePath = Path()

                for segment in skeleton.segments {
                    linePath.move(to: scaled(segment.0, in: size))
                    linePath.addLine(to: scaled(segment.1, in: size))
                }

                context.stroke(
                    linePath,
                    with: .color(.green.opacity(0.9)),
                    style: StrokeStyle(lineWidth: max(size.width * 0.012, 4), lineCap: .round, lineJoin: .round)
                )

                for joint in skeleton.visibleJoints {
                    let center = scaled(joint, in: size)
                    let radius = max(size.width * 0.018, 6)
                    let rect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(.yellow))
                    context.stroke(Path(ellipseIn: rect), with: .color(.black.opacity(0.45)), lineWidth: 1)
                }

                if let head = skeleton.joints[.nose] {
                    let center = scaled(head, in: size)
                    let radius = max(size.width * 0.034, 12)
                    let rect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.stroke(Path(ellipseIn: rect), with: .color(.yellow), lineWidth: 3)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func scaled(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
}

struct FormCoachPage_Previews: PreviewProvider {
    static var previews: some View {
        FormCoachPage()
    }
}
