import Foundation

/// Calibrated neutral-face reference values.
/// All ratios are normalized by face bounding box dimensions.
public struct VisionNeutralBaseline: Codable {
    /// Eyebrow centroid Y − eye top Y, divided by faceHeight. (~0.10)
    public var browToEyeRatio: Double
    /// Open-eye height/width aspect ratio. (~0.28)
    public var eyeAspectRatio: Double
    /// Mouth corner distance from face horizontal center, divided by faceWidth. (~0.19)
    public var mouthCornerDisplacement: Double
    /// Inner-lips vertical gap divided by faceHeight at rest. (~0.02)
    public var innerLipsOpenRatio: Double
    /// Mouth-corner Y drop below lip midpoint divided by faceHeight at neutral. (~0.0)
    public var mouthCornerDropRatio: Double

    public init(
        browToEyeRatio: Double = 0.10,
        eyeAspectRatio: Double = 0.28,
        mouthCornerDisplacement: Double = 0.19,
        innerLipsOpenRatio: Double = 0.02,
        mouthCornerDropRatio: Double = 0.0
    ) {
        self.browToEyeRatio = browToEyeRatio
        self.eyeAspectRatio = eyeAspectRatio
        self.mouthCornerDisplacement = mouthCornerDisplacement
        self.innerLipsOpenRatio = innerLipsOpenRatio
        self.mouthCornerDropRatio = mouthCornerDropRatio
    }

    public static let `default` = VisionNeutralBaseline()
}
