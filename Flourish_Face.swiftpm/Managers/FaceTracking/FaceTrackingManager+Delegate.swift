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

            let newBrowInnerUp = blendShapes[.browInnerUp]?.floatValue ?? 0
            let newBrowOuterUpLeft = blendShapes[.browOuterUpLeft]?.floatValue ?? 0
            let newBrowOuterUpRight = blendShapes[.browOuterUpRight]?.floatValue ?? 0
            let newMouthSmileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            let newMouthSmileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0
            let newJawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
            let newEyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let newEyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            let newMouthFrownLeft = blendShapes[.mouthFrownLeft]?.floatValue ?? 0
            let newMouthFrownRight = blendShapes[.mouthFrownRight]?.floatValue ?? 0

            if abs(self.browInnerUp - newBrowInnerUp) > TrackingConfig.blendShapeDelta { self.browInnerUp = newBrowInnerUp }
            if abs(self.browOuterUpLeft - newBrowOuterUpLeft) > TrackingConfig.blendShapeDelta { self.browOuterUpLeft = newBrowOuterUpLeft }
            if abs(self.browOuterUpRight - newBrowOuterUpRight) > TrackingConfig.blendShapeDelta { self.browOuterUpRight = newBrowOuterUpRight }
            if abs(self.mouthSmileLeft - newMouthSmileLeft) > TrackingConfig.blendShapeDelta { self.mouthSmileLeft = newMouthSmileLeft }
            if abs(self.mouthSmileRight - newMouthSmileRight) > TrackingConfig.blendShapeDelta { self.mouthSmileRight = newMouthSmileRight }
            if abs(self.jawOpen - newJawOpen) > TrackingConfig.blendShapeDelta { self.jawOpen = newJawOpen }
            if abs(self.eyeBlinkLeft - newEyeBlinkLeft) > TrackingConfig.blendShapeDelta { self.eyeBlinkLeft = newEyeBlinkLeft }
            if abs(self.eyeBlinkRight - newEyeBlinkRight) > TrackingConfig.blendShapeDelta { self.eyeBlinkRight = newEyeBlinkRight }
            if abs(self.mouthFrownLeft - newMouthFrownLeft) > TrackingConfig.blendShapeDelta { self.mouthFrownLeft = newMouthFrownLeft }
            if abs(self.mouthFrownRight - newMouthFrownRight) > TrackingConfig.blendShapeDelta { self.mouthFrownRight = newMouthFrownRight }

            self.processFrame(deltaTime: dt)
        }
    }
}
