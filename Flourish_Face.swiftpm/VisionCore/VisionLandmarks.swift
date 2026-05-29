import CoreGraphics

public struct VisionLandmarks {
    
    public let leftEye: [CGPoint]
    
    public let rightEye: [CGPoint]
    
    public let leftEyebrow: [CGPoint]
    
    public let rightEyebrow: [CGPoint]
    
    public let outerLips: [CGPoint]
    
    public let innerLips: [CGPoint]
    
    public let faceContour: [CGPoint]
    
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
