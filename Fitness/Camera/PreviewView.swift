import AVFoundation
import UIKit

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("PreviewView layer must be AVCaptureVideoPreviewLayer.")
        }

        return layer
    }
}
