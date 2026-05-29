import Foundation

/// Pre-computed geometric measurements extracted from raw Vision landmarks.
/// All values are normalized by face bounding box dimensions.
///
/// Coordinate convention (Vision normalized image space):
///   - Origin: bottom-left of image
///   - Y increases upward  (top of face = higher Y)
///   - X increases rightward
///   - Front camera (raw, non-mirrored): person's anatomical LEFT side → higher X
public struct VisionGeometry {
    /// Eyebrow centroid Y − eye top Y, divided by faceHeight.
    /// Higher = eyebrow further above eye = more raised.
    public let leftBrowToEyeRatio: Double
    public let rightBrowToEyeRatio: Double

    /// Eye height / eye width (aspect ratio). ~0.28 open, ~0.0 closed.
    public let leftEyeAspectRatio: Double
    public let rightEyeAspectRatio: Double

    /// Distance from face horizontal center to mouth corner, divided by faceWidth.
    /// Person's anatomical left corner is at higher X (larger displacement).
    public let leftMouthCornerDisplacement: Double
    public let rightMouthCornerDisplacement: Double

    /// Inner-lips vertical gap (top Y − bottom Y) divided by faceHeight.
    public let innerLipsOpenRatio: Double

    /// (lip midpoint Y − corner Y) / faceHeight. Positive = corner is below midpoint (frowning).
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
    /// Returns a neutral geometry using population-average values.
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
