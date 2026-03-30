import Foundation

extension FaceTrackingManager {
    func processFrame(deltaTime dt: TimeInterval) {
        growthRate = calculateRate(for: currentExercise)
        updateMirrorGuideValues()

        if growthRate >= TrackingConfig.threshold {
            aboveThresholdDuration += dt
            if aboveThresholdDuration >= TrackingConfig.holdRequired {
                totalGrowthAccumulated += TrackingConfig.growthPointsPerSet
                setCompleted = true
            }
        } else {
            aboveThresholdDuration = max(0, aboveThresholdDuration - dt * TrackingConfig.decayRate)
        }
    }

    func calculateRate(for exercise: FaceExercise) -> Double {
        switch exercise {
        case .browRaise:
            if affectedSide == .left {
                return min(1.0, Double(browOuterUpLeft) * TrackingConfig.browSensitivity)
            } else if affectedSide == .right {
                return min(1.0, Double(browOuterUpRight) * TrackingConfig.browSensitivity)
            } else if affectedSide == .central {
                return min(1.0, min(Double(browOuterUpLeft), Double(browOuterUpRight)) * TrackingConfig.browSensitivity)
            } else {
                let avg = (Double(browInnerUp) + Double(browOuterUpLeft) + Double(browOuterUpRight)) / 3.0
                return min(1.0, avg * TrackingConfig.browSensitivity)
            }

        case .smile:
            if affectedSide == .left {
                return min(1.0, Double(mouthSmileLeft) * TrackingConfig.smileSensitivity)
            } else if affectedSide == .right {
                return min(1.0, Double(mouthSmileRight) * TrackingConfig.smileSensitivity)
            } else if affectedSide == .central {
                return min(1.0, min(Double(mouthSmileLeft), Double(mouthSmileRight)) * TrackingConfig.smileSensitivity)
            } else {
                let avg = (Double(mouthSmileLeft) + Double(mouthSmileRight)) / 2.0
                return min(1.0, avg * TrackingConfig.smileSensitivity)
            }

        case .eyeClosure:
            if affectedSide == .left {
                return min(1.0, Double(eyeBlinkLeft) * TrackingConfig.eyeSensitivity)
            } else if affectedSide == .right {
                return min(1.0, Double(eyeBlinkRight) * TrackingConfig.eyeSensitivity)
            } else if affectedSide == .central {
                return min(1.0, min(Double(eyeBlinkLeft), Double(eyeBlinkRight)) * TrackingConfig.eyeSensitivity)
            } else {
                let avg = (Double(eyeBlinkLeft) + Double(eyeBlinkRight)) / 2.0
                return min(1.0, avg * TrackingConfig.eyeSensitivity)
            }

        case .jawOpen:
            return min(1.0, Double(jawOpen) * TrackingConfig.jawSensitivity)

        case .mouthFrown:
            if affectedSide == .left {
                return min(1.0, Double(mouthFrownLeft) * TrackingConfig.frownSensitivity)
            } else if affectedSide == .right {
                return min(1.0, Double(mouthFrownRight) * TrackingConfig.frownSensitivity)
            } else if affectedSide == .central {
                return min(1.0, min(Double(mouthFrownLeft), Double(mouthFrownRight)) * TrackingConfig.frownSensitivity)
            } else {
                let avg = (Double(mouthFrownLeft) + Double(mouthFrownRight)) / 2.0
                return min(1.0, avg * TrackingConfig.frownSensitivity)
            }
        }
    }

    func updateMirrorGuideValues() {
        guard affectedSide == .left || affectedSide == .right else {
            mirrorProgress = 1.0
            healthySideValue = 0.0
            affectedSideValue = 0.0
            return
        }

        switch currentExercise {
        case .browRaise:
            if affectedSide == .left {
                healthySideValue = Double(browOuterUpRight)
                affectedSideValue = Double(browOuterUpLeft)
            } else {
                healthySideValue = Double(browOuterUpLeft)
                affectedSideValue = Double(browOuterUpRight)
            }

        case .smile:
            if affectedSide == .left {
                healthySideValue = Double(mouthSmileRight)
                affectedSideValue = Double(mouthSmileLeft)
            } else {
                healthySideValue = Double(mouthSmileLeft)
                affectedSideValue = Double(mouthSmileRight)
            }

        case .eyeClosure:
            if affectedSide == .left {
                healthySideValue = Double(eyeBlinkRight)
                affectedSideValue = Double(eyeBlinkLeft)
            } else {
                healthySideValue = Double(eyeBlinkLeft)
                affectedSideValue = Double(eyeBlinkRight)
            }

        case .jawOpen:
            healthySideValue = Double(jawOpen)
            affectedSideValue = Double(jawOpen)

        case .mouthFrown:
            if affectedSide == .left {
                healthySideValue = Double(mouthFrownRight)
                affectedSideValue = Double(mouthFrownLeft)
            } else {
                healthySideValue = Double(mouthFrownLeft)
                affectedSideValue = Double(mouthFrownRight)
            }
        }

        if healthySideValue > TrackingConfig.mirrorMinThreshold {
            mirrorProgress = min(1.0, affectedSideValue / healthySideValue)
        } else {
            mirrorProgress = affectedSideValue > TrackingConfig.mirrorMinThreshold ? 1.0 : 0.0
        }
    }

    var isMirrorGuideEnabled: Bool {
        affectedSide == .left || affectedSide == .right
    }

    func setAffectedSide(_ side: AffectedSide) {
        self.affectedSide = side
    }
}
