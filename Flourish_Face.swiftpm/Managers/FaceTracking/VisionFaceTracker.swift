import AVFoundation
import Vision
import CoreGraphics
import VisionCore

final class VisionFaceTracker: NSObject {
    
    var onMeasurement: ((FaceTrackingSignalMeasurement, TimeInterval) -> Void)?

    private(set) var captureSession = AVCaptureSession()
    private let outputQueue = DispatchQueue(label: "com.flourish.vision.output", qos: .userInteractive)
    private let calculator: VisionBlendShapeCalculator
    private var lastFrameTime: Date?

    init(baseline: VisionNeutralBaseline = .default) {
        self.calculator = VisionBlendShapeCalculator(baseline: baseline)
        super.init()
        setupCaptureSession()
    }

    func start() {
        guard !captureSession.isRunning else { return }
        outputQueue.async { [weak self] in self?.captureSession.startRunning() }
    }

    func stop() {
        captureSession.stopRunning()
        lastFrameTime = nil
    }

    

    private func setupCaptureSession() {
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
        if captureSession.canAddInput(input) { captureSession.addInput(input) }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: outputQueue)
        output.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(output) { captureSession.addOutput(output) }
        captureSession.commitConfiguration()
    }
}

extension VisionFaceTracker: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let now = Date()
        let dt = lastFrameTime.map { now.timeIntervalSince($0) } ?? TrackingConfig.frameFallbackInterval
        lastFrameTime = now

        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        let request = VNDetectFaceLandmarksRequest { [weak self] req, _ in
            self?.handleLandmarkResult(req, deltaTime: dt)
        }

        try? handler.perform([request])
    }

    private func handleLandmarkResult(_ request: VNRequest, deltaTime: TimeInterval) {
        guard
            let results = request.results as? [VNFaceObservation],
            let face = results.first,
            let landmarks = face.landmarks,
            let vl = VisionLandmarks(from: landmarks, boundingBox: face.boundingBox)
        else { return }

        let geometry = VisionGeometryExtractor.extract(from: vl)
        let vm = calculator.measurement(from: geometry)
        let measurement = FaceTrackingSignalMeasurement(from: vm)

        DispatchQueue.main.async { [weak self] in
            self?.onMeasurement?(measurement, deltaTime)
        }
    }
}

extension VisionLandmarks {
    init?(from landmarks: VNFaceLandmarks2D, boundingBox: CGRect) {
        guard
            let leftEye      = landmarks.leftEye,
            let rightEye     = landmarks.rightEye,
            let leftEyebrow  = landmarks.leftEyebrow,
            let rightEyebrow = landmarks.rightEyebrow,
            let outerLips    = landmarks.outerLips,
            let innerLips    = landmarks.innerLips,
            let faceContour  = landmarks.faceContour
        else { return nil }

        func points(_ region: VNFaceLandmarkRegion2D) -> [CGPoint] {
            UnsafeBufferPointer(start: region.normalizedPoints, count: region.pointCount)
                .map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        }

        self.init(
            leftEye:      points(leftEye),
            rightEye:     points(rightEye),
            leftEyebrow:  points(leftEyebrow),
            rightEyebrow: points(rightEyebrow),
            outerLips:    points(outerLips),
            innerLips:    points(innerLips),
            faceContour:  points(faceContour),
            boundingBox:  boundingBox
        )
    }
}

extension FaceTrackingSignalMeasurement {
    init(from v: VisionMeasurement) {
        self.init(
            browInnerUp:      v.browInnerUp,
            browOuterUpLeft:  v.browOuterUpLeft,
            browOuterUpRight: v.browOuterUpRight,
            mouthSmileLeft:   v.mouthSmileLeft,
            mouthSmileRight:  v.mouthSmileRight,
            jawOpen:          v.jawOpen,
            eyeBlinkLeft:     v.eyeBlinkLeft,
            eyeBlinkRight:    v.eyeBlinkRight,
            mouthFrownLeft:   v.mouthFrownLeft,
            mouthFrownRight:  v.mouthFrownRight
        )
    }
}
