import Foundation

enum TrackingConfig {
    static let holdRequired: TimeInterval = 4.0
    static let threshold: Double = 0.5
    static let growthPointsPerSet: Double = 3.5
    static let renderThrottleInterval: TimeInterval = 0.033
    static let blendShapeDelta: Float = 0.01
    static let decayRate: Double = 0.5
    static let mirrorMinThreshold: Double = 0.05

    static let countdownStart: Int = 3
    static let frameFallbackInterval: TimeInterval = 0.016

    static let browSensitivity: Double = 3.0
    static let smileSensitivity: Double = 4.0
    static let eyeSensitivity: Double = 2.5
    static let jawSensitivity: Double = 3.0
    static let frownSensitivity: Double = 4.0
}
