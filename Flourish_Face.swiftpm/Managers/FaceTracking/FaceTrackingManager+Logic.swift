import Foundation

extension FaceTrackingManager {
    func updateSignals(from measurement: FaceTrackingSignalMeasurement) {
        signals.update(from: measurement)
    }

    func processFrame(deltaTime dt: TimeInterval) {
        let evaluation = FaceTrackingScoring.evaluate(
            signals: signals,
            exercise: currentExercise,
            affectedSide: affectedSide
        )
        let progress = FaceTrackingProgressCalculator.advance(
            growthRate: evaluation.growthRate,
            aboveThresholdDuration: aboveThresholdDuration,
            totalGrowthAccumulated: totalGrowthAccumulated,
            isSetCompleted: setCompleted,
            deltaTime: dt
        )

        growthRate = evaluation.growthRate
        healthySideValue = evaluation.healthySideValue
        affectedSideValue = evaluation.affectedSideValue
        mirrorProgress = evaluation.mirrorProgress

        aboveThresholdDuration = progress.aboveThresholdDuration
        totalGrowthAccumulated = progress.totalGrowthAccumulated
        setCompleted = progress.setCompleted
    }

    var isMirrorGuideEnabled: Bool {
        affectedSide == .left || affectedSide == .right
    }

    func setAffectedSide(_ side: AffectedSide) {
        self.affectedSide = side
    }
}

struct FaceTrackingSignals {
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

    mutating func update(from measurement: FaceTrackingSignalMeasurement) {
        if abs(browInnerUp - measurement.browInnerUp) > TrackingConfig.blendShapeDelta { browInnerUp = measurement.browInnerUp }
        if abs(browOuterUpLeft - measurement.browOuterUpLeft) > TrackingConfig.blendShapeDelta { browOuterUpLeft = measurement.browOuterUpLeft }
        if abs(browOuterUpRight - measurement.browOuterUpRight) > TrackingConfig.blendShapeDelta { browOuterUpRight = measurement.browOuterUpRight }
        if abs(mouthSmileLeft - measurement.mouthSmileLeft) > TrackingConfig.blendShapeDelta { mouthSmileLeft = measurement.mouthSmileLeft }
        if abs(mouthSmileRight - measurement.mouthSmileRight) > TrackingConfig.blendShapeDelta { mouthSmileRight = measurement.mouthSmileRight }
        if abs(jawOpen - measurement.jawOpen) > TrackingConfig.blendShapeDelta { jawOpen = measurement.jawOpen }
        if abs(eyeBlinkLeft - measurement.eyeBlinkLeft) > TrackingConfig.blendShapeDelta { eyeBlinkLeft = measurement.eyeBlinkLeft }
        if abs(eyeBlinkRight - measurement.eyeBlinkRight) > TrackingConfig.blendShapeDelta { eyeBlinkRight = measurement.eyeBlinkRight }
        if abs(mouthFrownLeft - measurement.mouthFrownLeft) > TrackingConfig.blendShapeDelta { mouthFrownLeft = measurement.mouthFrownLeft }
        if abs(mouthFrownRight - measurement.mouthFrownRight) > TrackingConfig.blendShapeDelta { mouthFrownRight = measurement.mouthFrownRight }
    }
}

struct FaceTrackingSignalMeasurement {
    let browInnerUp: Float
    let browOuterUpLeft: Float
    let browOuterUpRight: Float
    let mouthSmileLeft: Float
    let mouthSmileRight: Float
    let jawOpen: Float
    let eyeBlinkLeft: Float
    let eyeBlinkRight: Float
    let mouthFrownLeft: Float
    let mouthFrownRight: Float
}

private struct FaceTrackingEvaluation {
    let growthRate: Double
    let healthySideValue: Double
    let affectedSideValue: Double
    let mirrorProgress: Double
}

private enum FaceTrackingScoring {
    static func evaluate(
        signals: FaceTrackingSignals,
        exercise: FaceExercise,
        affectedSide: AffectedSide
    ) -> FaceTrackingEvaluation {
        let growthRate = calculateRate(
            signals: signals,
            exercise: exercise,
            affectedSide: affectedSide
        )
        let mirrorGuide = mirrorGuideValues(
            signals: signals,
            exercise: exercise,
            affectedSide: affectedSide
        )

        return FaceTrackingEvaluation(
            growthRate: growthRate,
            healthySideValue: mirrorGuide.healthySideValue,
            affectedSideValue: mirrorGuide.affectedSideValue,
            mirrorProgress: mirrorGuide.mirrorProgress
        )
    }

    private static func calculateRate(
        signals: FaceTrackingSignals,
        exercise: FaceExercise,
        affectedSide: AffectedSide
    ) -> Double {
        switch exercise {
        case .browRaise:
            if affectedSide == .left {
                return scaled(signals.browOuterUpLeft, sensitivity: TrackingConfig.browSensitivity)
            } else if affectedSide == .right {
                return scaled(signals.browOuterUpRight, sensitivity: TrackingConfig.browSensitivity)
            } else if affectedSide == .central {
                return scaled(min(signals.browOuterUpLeft, signals.browOuterUpRight), sensitivity: TrackingConfig.browSensitivity)
            } else {
                return scaled(
                    average(signals.browInnerUp, signals.browOuterUpLeft, signals.browOuterUpRight),
                    sensitivity: TrackingConfig.browSensitivity
                )
            }

        case .smile:
            return sidedRate(
                left: signals.mouthSmileLeft,
                right: signals.mouthSmileRight,
                affectedSide: affectedSide,
                sensitivity: TrackingConfig.smileSensitivity
            )

        case .eyeClosure:
            return sidedRate(
                left: signals.eyeBlinkLeft,
                right: signals.eyeBlinkRight,
                affectedSide: affectedSide,
                sensitivity: TrackingConfig.eyeSensitivity
            )

        case .jawOpen:
            return scaled(signals.jawOpen, sensitivity: TrackingConfig.jawSensitivity)

        case .mouthFrown:
            return sidedRate(
                left: signals.mouthFrownLeft,
                right: signals.mouthFrownRight,
                affectedSide: affectedSide,
                sensitivity: TrackingConfig.frownSensitivity
            )
        }
    }

    private static func mirrorGuideValues(
        signals: FaceTrackingSignals,
        exercise: FaceExercise,
        affectedSide: AffectedSide
    ) -> (healthySideValue: Double, affectedSideValue: Double, mirrorProgress: Double) {
        guard affectedSide == .left || affectedSide == .right else {
            return (0.0, 0.0, 1.0)
        }

        let values: (healthy: Double, affected: Double)
        switch exercise {
        case .browRaise:
            values = mirroredPair(
                affectedSide: affectedSide,
                left: signals.browOuterUpLeft,
                right: signals.browOuterUpRight
            )

        case .smile:
            values = mirroredPair(
                affectedSide: affectedSide,
                left: signals.mouthSmileLeft,
                right: signals.mouthSmileRight
            )

        case .eyeClosure:
            values = mirroredPair(
                affectedSide: affectedSide,
                left: signals.eyeBlinkLeft,
                right: signals.eyeBlinkRight
            )

        case .jawOpen:
            values = (Double(signals.jawOpen), Double(signals.jawOpen))

        case .mouthFrown:
            values = mirroredPair(
                affectedSide: affectedSide,
                left: signals.mouthFrownLeft,
                right: signals.mouthFrownRight
            )
        }

        let mirrorProgress: Double
        if values.healthy > TrackingConfig.mirrorMinThreshold {
            mirrorProgress = min(1.0, values.affected / values.healthy)
        } else {
            mirrorProgress = values.affected > TrackingConfig.mirrorMinThreshold ? 1.0 : 0.0
        }

        return (values.healthy, values.affected, mirrorProgress)
    }

    private static func sidedRate(
        left: Float,
        right: Float,
        affectedSide: AffectedSide,
        sensitivity: Double
    ) -> Double {
        switch affectedSide {
        case .left:
            return scaled(left, sensitivity: sensitivity)
        case .right:
            return scaled(right, sensitivity: sensitivity)
        case .central:
            return scaled(min(left, right), sensitivity: sensitivity)
        case .none:
            return scaled(average(left, right), sensitivity: sensitivity)
        }
    }

    private static func mirroredPair(
        affectedSide: AffectedSide,
        left: Float,
        right: Float
    ) -> (healthy: Double, affected: Double) {
        affectedSide == .left
            ? (Double(right), Double(left))
            : (Double(left), Double(right))
    }

    private static func scaled(_ value: Float, sensitivity: Double) -> Double {
        min(1.0, Double(value) * sensitivity)
    }

    private static func average(_ values: Float...) -> Float {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Float(values.count)
    }
}

private struct FaceTrackingProgress {
    let aboveThresholdDuration: TimeInterval
    let totalGrowthAccumulated: Double
    let setCompleted: Bool
}

private enum FaceTrackingProgressCalculator {
    static func advance(
        growthRate: Double,
        aboveThresholdDuration: TimeInterval,
        totalGrowthAccumulated: Double,
        isSetCompleted: Bool,
        deltaTime dt: TimeInterval
    ) -> FaceTrackingProgress {
        guard !isSetCompleted else {
            return FaceTrackingProgress(
                aboveThresholdDuration: aboveThresholdDuration,
                totalGrowthAccumulated: totalGrowthAccumulated,
                setCompleted: true
            )
        }

        if growthRate >= TrackingConfig.threshold {
            let updatedDuration = aboveThresholdDuration + dt
            if updatedDuration >= TrackingConfig.holdRequired {
                return FaceTrackingProgress(
                    aboveThresholdDuration: updatedDuration,
                    totalGrowthAccumulated: totalGrowthAccumulated + TrackingConfig.growthPointsPerSet,
                    setCompleted: true
                )
            }

            return FaceTrackingProgress(
                aboveThresholdDuration: updatedDuration,
                totalGrowthAccumulated: totalGrowthAccumulated,
                setCompleted: false
            )
        }

        return FaceTrackingProgress(
            aboveThresholdDuration: max(0, aboveThresholdDuration - dt * TrackingConfig.decayRate),
            totalGrowthAccumulated: totalGrowthAccumulated,
            setCompleted: false
        )
    }
}
