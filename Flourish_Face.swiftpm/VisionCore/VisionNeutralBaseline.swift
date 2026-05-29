import Foundation

public struct VisionNeutralBaseline: Codable {
    
    public var browToEyeRatio: Double
    
    public var eyeAspectRatio: Double
    
    public var mouthCornerDisplacement: Double
    
    public var innerLipsOpenRatio: Double
    
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
