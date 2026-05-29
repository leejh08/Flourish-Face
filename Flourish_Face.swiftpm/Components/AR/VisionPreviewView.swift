import UIKit
import AVFoundation

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
