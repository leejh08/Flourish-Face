import Foundation

enum DailyReminderPolicy {
    case schedule
    case cancel
}

struct DailyProgressState {
    var completedExercisesData: String
    var lastExerciseDate: String
    var flowersEarned: Int
    var pendingFlowerPick: Bool

    var hasPendingFlowerReward: Bool {
        pendingFlowerPick
    }

    func normalizedForToday(todayString: String = AppStorageKeys.todayString()) -> DailyProgressState {
        guard lastExerciseDate != todayString else { return self }

        var copy = self
        copy.completedExercisesData = ""
        copy.lastExerciseDate = todayString
        return copy
    }

    func completedExercises(todayString: String = AppStorageKeys.todayString()) -> Set<Int> {
        guard lastExerciseDate == todayString else { return [] }
        return AppStorageKeys.parseCompletedExercises(completedExercisesData)
    }

    func isTodayComplete(requiredExerciseCount: Int, todayString: String = AppStorageKeys.todayString()) -> Bool {
        completedExercises(todayString: todayString).count >= requiredExerciseCount
    }

    func reminderPolicy(requiredExerciseCount: Int, todayString: String = AppStorageKeys.todayString()) -> DailyReminderPolicy {
        isTodayComplete(requiredExerciseCount: requiredExerciseCount, todayString: todayString) ? .cancel : .schedule
    }

    mutating func recordCompletedExercise(
        _ exerciseID: Int,
        requiredExerciseCount: Int,
        todayString: String = AppStorageKeys.todayString()
    ) -> DailyReminderPolicy? {
        self = normalizedForToday(todayString: todayString)

        let previousExercises = completedExercises(todayString: todayString)
        let wasDayComplete = previousExercises.count >= requiredExerciseCount

        var updatedExercises = previousExercises
        let inserted = updatedExercises.insert(exerciseID).inserted
        completedExercisesData = AppStorageKeys.encodeCompletedExercises(updatedExercises)

        let isDayComplete = updatedExercises.count >= requiredExerciseCount
        let didEarnFlowerReward = inserted && !wasDayComplete && isDayComplete

        if didEarnFlowerReward {
            flowersEarned += 1
            pendingFlowerPick = true
        }

        return isDayComplete ? .cancel : nil
    }

    mutating func consumePendingFlowerReward() {
        pendingFlowerPick = false
    }

    mutating func reset() {
        completedExercisesData = ""
        lastExerciseDate = ""
        flowersEarned = 0
        pendingFlowerPick = false
    }
}
