import UIKit
import AVFoundation

/// Camera preview layer for Vision-based face tracking on non-TrueDepth devices.
final class VisionPreviewView: UIView {
    var captureSession: AVCaptureSession? {
        didSet { rebuildPreviewLayer() }
    }

    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    private func rebuildPreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        guard let session = captureSession else { return }
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        previewLayer = layer
    }
}
