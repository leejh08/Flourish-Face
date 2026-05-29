import Foundation
import VisionCore

extension FaceTrackingManager {
    func startVisionTracking(exercise: FaceExercise) {
        currentExercise = exercise
        totalGrowthAccumulated = 0.0
        aboveThresholdDuration = 0.0
        sessionCompleted = false
        currentSet = 1
        setCompleted = false
        sessionStartTime = .now
        elapsedTime = 0

        let baseline = VisionCalibrationStore().load()
        let tracker = VisionFaceTracker(baseline: baseline)

        tracker.onMeasurement = { [weak self] measurement, dt in
            guard let self,
                  self.isProcessingEnabled,
                  !self.sessionCompleted,
                  !self.setCompleted else { return }
            self.updateSignals(from: measurement)
            self.processFrame(deltaTime: dt)
        }

        visionTracker = tracker
        tracker.start()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedTime = Date.now.timeIntervalSince(self.sessionStartTime ?? .now)
        }
    }
}
