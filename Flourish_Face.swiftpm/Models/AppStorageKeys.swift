import Foundation

enum AppStorageKeys {
    static let todayCompletedExercisesData = "todayCompletedExercisesData"
    static let lastExerciseDate = "lastExerciseDate"
    static let totalGrowthPoints = "totalGrowthPoints"
    static let flowersEarned = "flowersEarned"
    static let pendingFlowerPick = "pendingFlowerPick"
    static let affectedSide = "affectedSide"
    static let selectedDifficulty = "selectedDifficulty"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasCompletedIntro = "hasCompletedIntro"

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func todayString() -> String {
        dateFormatter.string(from: Date())
    }

    static func parseCompletedExercises(_ data: String) -> Set<Int> {
        guard !data.isEmpty else { return [] }
        return Set(data.split(separator: ",").compactMap { Int($0) })
    }

    static func encodeCompletedExercises(_ exercises: Set<Int>) -> String {
        exercises.sorted().map { String($0) }.joined(separator: ",")
    }
}
