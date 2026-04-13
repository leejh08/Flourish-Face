import SwiftUI
import SwiftData

extension SessionView {
    func saveSession() {
        manager.stopTracking()

        let session = GrowthSession(date: Date(), exerciseRaw: exercise.rawValue)
        modelContext.insert(session)

        if isBonus {
            return
        }

        totalGrowthPoints += manager.totalGrowthAccumulated

        var progressState = dailyProgressState
        let reminderPolicy = progressState.recordCompletedExercise(
            exercise.rawValue,
            requiredExerciseCount: requiredExerciseCount
        )
        storeDailyProgressState(progressState)

        if let reminderPolicy {
            apply(reminderPolicy)
        }
    }

    private var dailyProgressState: DailyProgressState {
        DailyProgressState(
            completedExercisesData: todayCompletedExercisesData,
            lastExerciseDate: lastExerciseDate,
            flowersEarned: appFlowersEarned,
            pendingFlowerPick: pendingFlowerPick
        )
    }

    func getCompletedExercisesFromAppStorage() -> Set<Int> {
        dailyProgressState.normalizedForToday().completedExercises()
    }

    private func storeDailyProgressState(_ state: DailyProgressState) {
        todayCompletedExercisesData = state.completedExercisesData
        lastExerciseDate = state.lastExerciseDate
        appFlowersEarned = state.flowersEarned
        pendingFlowerPick = state.pendingFlowerPick
    }

    private func apply(_ reminderPolicy: DailyReminderPolicy) {
        switch reminderPolicy {
        case .schedule:
            NotificationManager.shared.scheduleStreakReminder()
        case .cancel:
            NotificationManager.shared.cancelStreakReminder()
        }
    }
}
