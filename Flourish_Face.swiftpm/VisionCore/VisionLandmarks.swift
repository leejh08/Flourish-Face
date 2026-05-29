import CoreGraphics

/// Raw facial landmark points extracted from a VNFaceObservation.
/// All points are in Vision normalized image coordinates (origin: bottom-left, Y up).
public struct VisionLandmarks {
    /// 6 points forming the left eye contour (person's anatomical left = higher X in front camera).
    public let leftEye: [CGPoint]
    /// 6 points forming the right eye contour.
    public let rightEye: [CGPoint]
    /// 5 points along the left eyebrow.
    public let leftEyebrow: [CGPoint]
    /// 5 points along the right eyebrow.
    public let rightEyebrow: [CGPoint]
    /// 12 points forming the outer lip contour.
    public let outerLips: [CGPoint]
    /// 8 points forming the inner lip contour.
    public let innerLips: [CGPoint]
    /// 17 points along the face/jaw contour.
    public let faceContour: [CGPoint]
    /// Face bounding box in normalized image coordinates.
    public let boundingBox: CGRect

    public init(
        leftEye: [CGPoint], rightEye: [CGPoint],
        leftEyebrow: [CGPoint], rightEyebrow: [CGPoint],
        outerLips: [CGPoint], innerLips: [CGPoint],
        faceContour: [CGPoint],
        boundingBox: CGRect
    ) {
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.leftEyebrow = leftEyebrow
        self.rightEyebrow = rightEyebrow
        self.outerLips = outerLips
        self.innerLips = innerLips
        self.faceContour = faceContour
        self.boundingBox = boundingBox
    }
}
