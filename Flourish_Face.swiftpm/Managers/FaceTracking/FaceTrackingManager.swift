import Foundation
import ARKit
import Observation

@Observable
final class FaceTrackingManager: NSObject, ARSCNViewDelegate, ARSessionDelegate {
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

    var signals = FaceTrackingSignals()
    var lastUpdateTime: Date?
    weak var sceneView: ARSCNView?
    var timer: Timer?
    var cachedScreenWidth: CGFloat = 0
    var lastRenderTime: TimeInterval = 0

    var holdProgress: Double {
        min(1.0, aboveThresholdDuration / TrackingConfig.holdRequired)
    }
}
