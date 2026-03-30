import Foundation

struct SessionConfig: Hashable {
    let chapter: Chapter
    let exercise: FaceExercise
    var isBonus: Bool = false
    var totalSets: Int = 3
}
