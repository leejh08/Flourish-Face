import Foundation
import ARKit
import Observation

@Observable
final class FaceTrackingManager: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    var browInnerUp: Float = 0
    var browOuterUpLeft: Float = 0
    var browOuterUpRight: Float = 0
    var mouthSmileLeft: Float = 0
    var mouthSmileRight: Float = 0
    var jawOpen: Float = 0
    var eyeBlinkLeft: Float = 0
    var eyeBlinkRight: Float = 0
    var mouthFrownLeft: Float = 0
    var mouthFrownRight: Float = 0

    var growthRate: Double = 0.0
    var isTracking: Bool = false

    var affectedSide: AffectedSide = .none
    var healthySideValue: Double = 0.0
    var affectedSideValue: Double = 0.0
    var mirrorProgress: Double = 0.0

    var isFaceCentered: Bool = true

    var currentChapter: Chapter = .seed
    var currentExercise: FaceExercise = .smile
    var sessionCompleted: Bool = false

    var currentSet: Int = 1
    var totalSets: Int = 3
    var setCompleted: Bool = false
    var isProcessingEnabled: Bool = false

    var totalGrowthAccumulated: Double = 0.0
    var aboveThresholdDuration: TimeInterval = 0.0
    var elapsedTime: TimeInterval = 0
    var sessionStartTime: Date?

    var lastUpdateTime: Date?
    weak var sceneView: ARSCNView?
    var timer: Timer?
    var cachedScreenWidth: CGFloat = 0
    var lastRenderTime: TimeInterval = 0

    var holdProgress: Double {
        min(1.0, aboveThresholdDuration / TrackingConfig.holdRequired)
    }
}
