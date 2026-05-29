import Foundation

public struct VisionMeasurement {
    public let browInnerUp: Float
    public let browOuterUpLeft: Float
    public let browOuterUpRight: Float
    public let mouthSmileLeft: Float
    public let mouthSmileRight: Float
    public let jawOpen: Float
    public let eyeBlinkLeft: Float
    public let eyeBlinkRight: Float
    public let mouthFrownLeft: Float
    public let mouthFrownRight: Float

    public init(
        browInnerUp: Float, browOuterUpLeft: Float, browOuterUpRight: Float,
        mouthSmileLeft: Float, mouthSmileRight: Float,
        jawOpen: Float,
        eyeBlinkLeft: Float, eyeBlinkRight: Float,
        mouthFrownLeft: Float, mouthFrownRight: Float
    ) {
        self.browInnerUp = browInnerUp
        self.browOuterUpLeft = browOuterUpLeft
        self.browOuterUpRight = browOuterUpRight
        self.mouthSmileLeft = mouthSmileLeft
        self.mouthSmileRight = mouthSmileRight
        self.jawOpen = jawOpen
        self.eyeBlinkLeft = eyeBlinkLeft
        self.eyeBlinkRight = eyeBlinkRight
        self.mouthFrownLeft = mouthFrownLeft
        self.mouthFrownRight = mouthFrownRight
    }

    public static let zero = VisionMeasurement(
        browInnerUp: 0, browOuterUpLeft: 0, browOuterUpRight: 0,
        mouthSmileLeft: 0, mouthSmileRight: 0, jawOpen: 0,
        eyeBlinkLeft: 0, eyeBlinkRight: 0, mouthFrownLeft: 0, mouthFrownRight: 0
    )
}
