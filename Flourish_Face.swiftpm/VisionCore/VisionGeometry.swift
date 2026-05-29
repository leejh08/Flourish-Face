import Foundation

public struct VisionGeometry {
    
    
    public let leftBrowToEyeRatio: Double
    public let rightBrowToEyeRatio: Double

    
    public let leftEyeAspectRatio: Double
    public let rightEyeAspectRatio: Double

    
    
    public let leftMouthCornerDisplacement: Double
    public let rightMouthCornerDisplacement: Double

    
    public let innerLipsOpenRatio: Double

    
    public let leftMouthCornerDrop: Double
    public let rightMouthCornerDrop: Double

    public let faceHeight: Double
    public let faceWidth: Double

    public init(
        leftBrowToEyeRatio: Double, rightBrowToEyeRatio: Double,
        leftEyeAspectRatio: Double, rightEyeAspectRatio: Double,
        leftMouthCornerDisplacement: Double, rightMouthCornerDisplacement: Double,
        innerLipsOpenRatio: Double,
        leftMouthCornerDrop: Double, rightMouthCornerDrop: Double,
        faceHeight: Double, faceWidth: Double
    ) {
        self.leftBrowToEyeRatio = leftBrowToEyeRatio
        self.rightBrowToEyeRatio = rightBrowToEyeRatio
        self.leftEyeAspectRatio = leftEyeAspectRatio
        self.rightEyeAspectRatio = rightEyeAspectRatio
        self.leftMouthCornerDisplacement = leftMouthCornerDisplacement
        self.rightMouthCornerDisplacement = rightMouthCornerDisplacement
        self.innerLipsOpenRatio = innerLipsOpenRatio
        self.leftMouthCornerDrop = leftMouthCornerDrop
        self.rightMouthCornerDrop = rightMouthCornerDrop
        self.faceHeight = faceHeight
        self.faceWidth = faceWidth
    }
}

extension VisionGeometry {
    
    public static func neutral(baseline: VisionNeutralBaseline = .default) -> VisionGeometry {
        VisionGeometry(
            leftBrowToEyeRatio: baseline.browToEyeRatio,
            rightBrowToEyeRatio: baseline.browToEyeRatio,
            leftEyeAspectRatio: baseline.eyeAspectRatio,
            rightEyeAspectRatio: baseline.eyeAspectRatio,
            leftMouthCornerDisplacement: baseline.mouthCornerDisplacement,
            rightMouthCornerDisplacement: baseline.mouthCornerDisplacement,
            innerLipsOpenRatio: baseline.innerLipsOpenRatio,
            leftMouthCornerDrop: baseline.mouthCornerDropRatio,
            rightMouthCornerDrop: baseline.mouthCornerDropRatio,
            faceHeight: 0.8,
            faceWidth: 0.6
        )
    }
}
