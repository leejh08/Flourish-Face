import Foundation
import ARKit

extension FaceTrackingManager {
    var isARFaceTrackingSupported: Bool {
        ARFaceTrackingConfiguration.isSupported
    }

    func startTracking(on sceneView: ARSCNView, chapter: Chapter, exercise: FaceExercise) {
        currentChapter = chapter
        currentExercise = exercise
        totalGrowthAccumulated = 0.0
        aboveThresholdDuration = 0.0
        sessionCompleted = false
        currentSet = 1
        setCompleted = false
        sessionStartTime = .now
        elapsedTime = 0
        self.sceneView = sceneView
        self.cachedScreenWidth = sceneView.bounds.width

        guard isARFaceTrackingSupported else { return }

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime = Date.now.timeIntervalSince(self.sessionStartTime ?? .now)
        }
    }

    func stopTracking() {
        sceneView?.session.pause()
        sceneView?.session.delegate = nil
        sceneView?.delegate = nil
        sceneView = nil
        isTracking = false
        timer?.invalidate()
        timer = nil
    }

    func resetForNextSet() {
        currentSet += 1
        setCompleted = false
        isProcessingEnabled = false
        aboveThresholdDuration = 0
        growthRate = 0
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        guard isARFaceTrackingSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking])
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard isARFaceTrackingSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking])
    }
}
