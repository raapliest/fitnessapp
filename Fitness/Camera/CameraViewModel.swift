import AVFoundation
import Combine
import Foundation

final class CameraViewModel: NSObject, ObservableObject {
    @Published private(set) var feedback = FormFeedback.waiting
    @Published private(set) var cameraStatus = "Camera is not running."

    let session = AVCaptureSession()

    private let analyzer = FormFeedbackAnalyzer()
    private let outputQueue = DispatchQueue(label: "fitness.camera.frames")
    private var isConfigured = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStart()
                    } else {
                        self?.cameraStatus = "Camera access is needed for form feedback."
                    }
                }
            }
        case .denied, .restricted:
            cameraStatus = "Camera access is needed for form feedback."
        @unknown default:
            cameraStatus = "Camera status is unknown."
        }
    }

    func stop() {
        guard session.isRunning else {
            return
        }

        outputQueue.async { [session] in
            session.stopRunning()
        }
    }

    private func configureAndStart() {
        if !isConfigured {
            configureSession()
        }

        guard !session.isRunning else {
            return
        }

        cameraStatus = "Analyzing form with Vision."
        outputQueue.async { [session] in
            session.startRunning()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        defer {
            session.commitConfiguration()
        }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            cameraStatus = "Front camera is unavailable."
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }

            isConfigured = true
        } catch {
            cameraStatus = "Camera setup failed."
        }
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let result = analyzer.analyze(sampleBuffer: sampleBuffer)

        DispatchQueue.main.async {
            self.feedback = result
        }
    }
}
