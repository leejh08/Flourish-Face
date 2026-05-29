import CoreGraphics

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

    
    
    

    private static func browToEyeRatio(brow: [CGPoint], eye: [CGPoint], faceHeight: Double) -> Double {
        guard !brow.isEmpty, !eye.isEmpty, faceHeight > 0 else { return 0 }
        let browCentroidY = brow.map { Double($0.y) }.reduce(0, +) / Double(brow.count)
        let eyeTopY = eye.map { Double($0.y) }.max() ?? 0
        return (browCentroidY - eyeTopY) / faceHeight
    }

    
    
    

    private static func eyeAspectRatio(points: [CGPoint]) -> Double {
        guard points.count >= 2 else { return 0 }
        let ys = points.map { Double($0.y) }
        let xs = points.map { Double($0.x) }
        let height = (ys.max() ?? 0) - (ys.min() ?? 0)
        let width  = (xs.max() ?? 0) - (xs.min() ?? 0)
        guard width > 0 else { return 0 }
        return height / width
    }

    
    
    
    

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

    
    

    private static func innerLipsOpenRatio(points: [CGPoint], faceHeight: Double) -> Double {
        guard !points.isEmpty, faceHeight > 0 else { return 0 }
        let ys = points.map { Double($0.y) }
        let gap = (ys.max() ?? 0) - (ys.min() ?? 0)
        return gap / faceHeight
    }

    
    
    

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
