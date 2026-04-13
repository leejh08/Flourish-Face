import Foundation
import ARKit
import SceneKit

extension FaceTrackingManager {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let sceneView = renderer as? ARSCNView else { return }

        let now = CACurrentMediaTime()
        guard now - lastRenderTime >= TrackingConfig.renderThrottleInterval else { return }
        lastRenderTime = now

        let blendShapes = faceAnchor.blendShapes

        let dateNow = Date.now
        let dt = lastUpdateTime.map { dateNow.timeIntervalSince($0) } ?? TrackingConfig.frameFallbackInterval
        lastUpdateTime = dateNow

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.cachedScreenWidth = sceneView.bounds.width

            guard self.isProcessingEnabled, !self.sessionCompleted, !self.setCompleted else { return }

            let measurement = FaceTrackingSignalMeasurement(
                browInnerUp: blendShapes[.browInnerUp]?.floatValue ?? 0,
                browOuterUpLeft: blendShapes[.browOuterUpLeft]?.floatValue ?? 0,
                browOuterUpRight: blendShapes[.browOuterUpRight]?.floatValue ?? 0,
                mouthSmileLeft: blendShapes[.mouthSmileLeft]?.floatValue ?? 0,
                mouthSmileRight: blendShapes[.mouthSmileRight]?.floatValue ?? 0,
                jawOpen: blendShapes[.jawOpen]?.floatValue ?? 0,
                eyeBlinkLeft: blendShapes[.eyeBlinkLeft]?.floatValue ?? 0,
                eyeBlinkRight: blendShapes[.eyeBlinkRight]?.floatValue ?? 0,
                mouthFrownLeft: blendShapes[.mouthFrownLeft]?.floatValue ?? 0,
                mouthFrownRight: blendShapes[.mouthFrownRight]?.floatValue ?? 0
            )

            self.updateSignals(from: measurement)

            self.processFrame(deltaTime: dt)
        }
    }
}
