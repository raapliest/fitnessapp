import SwiftUI

struct FormCoachPage: View {
    @StateObject private var camera = CameraViewModel()

    var body: some View {
        ZStack {
            // Full screen camera
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            // Skeleton overlay
            PoseSkeletonOverlay(skeleton: camera.skeleton)
                .ignoresSafeArea()

            // Top overlay: movement picker + camera button
            VStack {
                HStack {
                    Picker("Movement", selection: $camera.selectedMovement) {
                        ForEach(TrainerMovement.allCases) { movement in
                            Text(movement.title).tag(movement)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))

                    Button(action: camera.start) {
                        Image(systemName: "play.fill")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Bottom overlay: metrics panel
                CompactFeedbackOverlay(feedback: camera.feedback, cameraStatus: camera.cameraStatus)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .onDisappear(perform: camera.stop)
    }
}

private struct CompactFeedbackOverlay: View {
    let feedback: FormFeedback
    let cameraStatus: String

    var body: some View {
        VStack(spacing: 8) {
            // Headline + confidence
            HStack {
                Label(feedback.headline, systemImage: feedback.isReadyForModelUpgrade ? "checkmark.circle.fill" : "viewfinder")
                    .font(.subheadline.bold())
                    .foregroundStyle(feedback.isReadyForModelUpgrade ? .green : .orange)
                Spacer()
                Text(cameraStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: feedback.confidence)
                .tint(feedback.isReadyForModelUpgrade ? .green : .orange)

            // Metrics row
            HStack(spacing: 0) {
                metricItem("Reps", value: "\(feedback.trainerScore.repCount)")
                Divider().frame(height: 32)
                metricItem("Form", value: "\(Int(feedback.trainerScore.score * 100))%")
                Divider().frame(height: 32)
                metricItem("Stability", value: "\(Int(feedback.trainerScore.stabilityScore * 100))%")
                Divider().frame(height: 32)
                metricItem("Depth", value: "\(Int(feedback.trainerScore.depthScore * 100))%")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metricItem(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
