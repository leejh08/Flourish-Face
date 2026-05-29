import CoreGraphics

/// Extracts VisionGeometry from raw Vision landmark points.
/// All outputs are normalized by face bounding box dimensions.
public enum VisionGeometryExtractor {

    public static func extract(from landmarks: VisionLandmarks) -> VisionGeometry {
        let box = landmarks.boundingBox
        let faceHeight = Double(box.height)
        let faceWidth  = Double(box.width)
        let faceCenterX = Double(box.midX)

        return VisionGeometry(
            leftBrowToEyeRatio:  browToEyeRatio(brow: landmarks.leftEyebrow,  eye: landmarks.leftEye,  faceHeight: faceHeight),
            rightBrowToEyeRatio: browToEyeRatio(brow: landmarks.rightEyebrow, eye: landmarks.rightEye, faceHeight: faceHeight),
            leftEyeAspectRatio:  eyeAspectRatio(points: landmarks.leftEye),
            rightEyeAspectRatio: eyeAspectRatio(points: landmarks.rightEye),
            leftMouthCornerDisplacement:  cornerDisplacement(lips: landmarks.outerLips, side: .left,  centerX: faceCenterX, faceWidth: faceWidth),
            rightMouthCornerDisplacement: cornerDisplacement(lips: landmarks.outerLips, side: .right, centerX: faceCenterX, faceWidth: faceWidth),
            innerLipsOpenRatio:  innerLipsOpenRatio(points: landmarks.innerLips, faceHeight: faceHeight),
            leftMouthCornerDrop:  cornerDrop(lips: landmarks.outerLips, side: .left,  faceHeight: faceHeight),
            rightMouthCornerDrop: cornerDrop(lips: landmarks.outerLips, side: .right, faceHeight: faceHeight),
            faceHeight: faceHeight,
            faceWidth:  faceWidth
        )
    }

    // MARK: - Brow raise
    // (eyebrow centroid Y − eye top Y) / faceHeight
    // Vision Y-up: eyebrow has higher Y than eye top → positive value.

    private static func browToEyeRatio(brow: [CGPoint], eye: [CGPoint], faceHeight: Double) -> Double {
        guard !brow.isEmpty, !eye.isEmpty, faceHeight > 0 else { return 0 }
        let browCentroidY = brow.map { Double($0.y) }.reduce(0, +) / Double(brow.count)
        let eyeTopY = eye.map { Double($0.y) }.max() ?? 0
        return (browCentroidY - eyeTopY) / faceHeight
    }

    // MARK: - Eye aspect ratio
    // EAR = eye height / eye width using bounding extremes.
    // Simplified from full 6-point Soukupová formula; sufficient for blink detection.

    private static func eyeAspectRatio(points: [CGPoint]) -> Double {
        guard points.count >= 2 else { return 0 }
        let ys = points.map { Double($0.y) }
        let xs = points.map { Double($0.x) }
        let height = (ys.max() ?? 0) - (ys.min() ?? 0)
        let width  = (xs.max() ?? 0) - (xs.min() ?? 0)
        guard width > 0 else { return 0 }
        return height / width
    }

    // MARK: - Smile (corner displacement from face center)
    // Person's anatomical LEFT → higher X in front camera raw image.
    // .left  → point with max X (person's left corner)
    // .right → point with min X (person's right corner)

    private enum Side { case left, right }

    private static func cornerDisplacement(lips: [CGPoint], side: Side, centerX: Double, faceWidth: Double) -> Double {
        guard !lips.isEmpty, faceWidth > 0 else { return 0 }
        let cornerX: Double
        switch side {
        case .left:  cornerX = Double(lips.map { $0.x }.max() ?? 0)
        case .right: cornerX = Double(lips.map { $0.x }.min() ?? 0)
        }
        return abs(cornerX - centerX) / faceWidth
    }

    // MARK: - Inner lips open ratio
    // (top Y − bottom Y) / faceHeight. Y-up: top lip has higher Y.

    private static func innerLipsOpenRatio(points: [CGPoint], faceHeight: Double) -> Double {
        guard !points.isEmpty, faceHeight > 0 else { return 0 }
        let ys = points.map { Double($0.y) }
        let gap = (ys.max() ?? 0) - (ys.min() ?? 0)
        return gap / faceHeight
    }

    // MARK: - Mouth corner drop
    // Positive when corner Y is below lip midpoint Y (frowning).
    // Y-up: lower Y = further down → (midpoint Y − corner Y) > 0 when frowning.

    private static func cornerDrop(lips: [CGPoint], side: Side, faceHeight: Double) -> Double {
        guard !lips.isEmpty, faceHeight > 0 else { return 0 }
        let ys = lips.map { Double($0.y) }
        let lipMidpointY = ((ys.max() ?? 0) + (ys.min() ?? 0)) / 2

        let cornerX: Double
        switch side {
        case .left:  cornerX = Double(lips.map { $0.x }.max() ?? 0)
        case .right: cornerX = Double(lips.map { $0.x }.min() ?? 0)
        }
        let cornerPoint = lips.min(by: { abs(Double($0.x) - cornerX) < abs(Double($1.x) - cornerX) })
        let cornerY = Double(cornerPoint?.y ?? 0)
        return (lipMidpointY - cornerY) / faceHeight
    }
}
