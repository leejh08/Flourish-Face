import Foundation

public struct VisionBlendShapeCalculator {
    public let baseline: VisionNeutralBaseline

    public init(baseline: VisionNeutralBaseline = .default) {
        self.baseline = baseline
    }

    public func measurement(from geometry: VisionGeometry) -> VisionMeasurement {
        VisionMeasurement(
            browInnerUp:      browInnerUp(geometry),
            browOuterUpLeft:  browOuterUpLeft(geometry),
            browOuterUpRight: browOuterUpRight(geometry),
            mouthSmileLeft:   smileLeft(geometry),
            mouthSmileRight:  smileRight(geometry),
            jawOpen:          jawOpen(geometry),
            eyeBlinkLeft:     eyeBlinkLeft(geometry),
            eyeBlinkRight:    eyeBlinkRight(geometry),
            mouthFrownLeft:   mouthFrownLeft(geometry),
            mouthFrownRight:  mouthFrownRight(geometry)
        )
    }

    
    
    

    func browInnerUp(_ g: VisionGeometry) -> Float {
        let avg = (g.leftBrowToEyeRatio + g.rightBrowToEyeRatio) / 2
        return browRaise(ratio: avg)
    }

    func browOuterUpLeft(_ g: VisionGeometry) -> Float {
        browRaise(ratio: g.leftBrowToEyeRatio)
    }

    func browOuterUpRight(_ g: VisionGeometry) -> Float {
        browRaise(ratio: g.rightBrowToEyeRatio)
    }

    private func browRaise(ratio: Double) -> Float {
        let base = baseline.browToEyeRatio
        guard base > 0 else { return 0 }
        return clamp((ratio - base) / (base * 0.8))
    }

    
    

    func eyeBlinkLeft(_ g: VisionGeometry) -> Float {
        eyeBlink(ear: g.leftEyeAspectRatio)
    }

    func eyeBlinkRight(_ g: VisionGeometry) -> Float {
        eyeBlink(ear: g.rightEyeAspectRatio)
    }

    private func eyeBlink(ear: Double) -> Float {
        let base = baseline.eyeAspectRatio
        guard base > 0 else { return 0 }
        return clamp(1.0 - ear / base)
    }

    
    

    func jawOpen(_ g: VisionGeometry) -> Float {
        clamp((g.innerLipsOpenRatio - baseline.innerLipsOpenRatio) / 0.15)
    }

    
    

    func smileLeft(_ g: VisionGeometry) -> Float {
        clamp((g.leftMouthCornerDisplacement - baseline.mouthCornerDisplacement) / 0.08)
    }

    func smileRight(_ g: VisionGeometry) -> Float {
        clamp((g.rightMouthCornerDisplacement - baseline.mouthCornerDisplacement) / 0.08)
    }

    
    

    func mouthFrownLeft(_ g: VisionGeometry) -> Float {
        clamp((g.leftMouthCornerDrop - baseline.mouthCornerDropRatio) / 0.06)
    }

    func mouthFrownRight(_ g: VisionGeometry) -> Float {
        clamp((g.rightMouthCornerDrop - baseline.mouthCornerDropRatio) / 0.06)
    }

    

    private func clamp(_ value: Double) -> Float {
        Float(max(0.0, min(1.0, value)))
    }
}
