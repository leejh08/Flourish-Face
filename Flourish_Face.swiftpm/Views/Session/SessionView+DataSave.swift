import SwiftUI
import SwiftData

extension SessionView {
    func saveSession() {
        manager.stopTracking()

        if isBonus {
            let session = GrowthSession(date: Date(), exerciseRaw: exercise.rawValue)
            modelContext.insert(session)
            return
        }

        saveExerciseToAppStorage()
        totalGrowthPoints += manager.totalGrowthAccumulated

        let session = GrowthSession(date: Date(), exerciseRaw: exercise.rawValue)
        modelContext.insert(session)

        let completedSet = getCompletedExercisesFromAppStorage()
        if completedSet.count >= requiredExerciseCount {
            var previousSet = completedSet
            previousSet.remove(exercise.rawValue)
            if previousSet.count < requiredExerciseCount {
                appFlowersEarned += 1
                pendingFlowerPick = true
            }
        }
    }

    func saveExerciseToAppStorage() {
        let todayString = AppStorageKeys.todayString()

        if lastExerciseDate != todayString {
            todayCompletedExercisesData = ""
            lastExerciseDate = todayString
        }

        var exercises = AppStorageKeys.parseCompletedExercises(todayCompletedExercisesData)
        exercises.insert(exercise.rawValue)
        todayCompletedExercisesData = AppStorageKeys.encodeCompletedExercises(exercises)
    }

    func getCompletedExercisesFromAppStorage() -> Set<Int> {
        guard lastExerciseDate == AppStorageKeys.todayString() else { return [] }
        return AppStorageKeys.parseCompletedExercises(todayCompletedExercisesData)
    }
}
