import Foundation
import SwiftData

@Model
final class GrowthSession {
    var date: Date
    var exerciseRaw: Int

    init(
        date: Date = .now,
        exerciseRaw: Int = 0
    ) {
        self.date = date
        self.exerciseRaw = exerciseRaw
    }

    var exercise: FaceExercise? {
        FaceExercise(rawValue: exerciseRaw)
    }
}
