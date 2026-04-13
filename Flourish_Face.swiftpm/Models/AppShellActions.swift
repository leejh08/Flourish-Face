import Foundation
import SwiftData

enum AppRootRoute {
    case mainContent
    case intro
    case onboarding

    init(hasCompletedIntro: Bool, hasCompletedOnboarding: Bool) {
        if hasCompletedOnboarding {
            self = .mainContent
        } else if !hasCompletedIntro {
            self = .intro
        } else {
            self = .onboarding
        }
    }
}

struct AppRootShellState {
    var selectedTab = 0
    var showFlowerPicker = false
    var newlyAddedFlowerType: FlowerType?

    mutating func handleOnboardingCompletion() {
        selectedTab = 0
    }

    mutating func syncPendingFlowerReward(_ isPending: Bool) {
        showFlowerPicker = isPending
    }

    mutating func claimFlowerReward(
        _ selectedFlower: FlowerType,
        pendingFlowerPick: inout Bool,
        modelContext: ModelContext
    ) {
        modelContext.insert(Flower(type: selectedFlower))
        pendingFlowerPick = false
        newlyAddedFlowerType = selectedFlower
        showFlowerPicker = false
        selectedTab = 1
    }
}

enum AppResetAction {
    static func perform(
        modelContext: ModelContext,
        userDefaults: UserDefaults = .standard
    ) {
        NotificationManager.shared.cancelAll()

        userDefaults.set("", forKey: AppStorageKeys.todayCompletedExercisesData)
        userDefaults.set("", forKey: AppStorageKeys.lastExerciseDate)
        userDefaults.set(0.0, forKey: AppStorageKeys.totalGrowthPoints)
        userDefaults.set(0, forKey: AppStorageKeys.flowersEarned)
        userDefaults.set(false, forKey: AppStorageKeys.pendingFlowerPick)
        userDefaults.set(AffectedSide.none.rawValue, forKey: AppStorageKeys.affectedSide)
        userDefaults.set(Difficulty.basic.rawValue, forKey: AppStorageKeys.selectedDifficulty)
        userDefaults.set(false, forKey: AppStorageKeys.hasCompletedOnboarding)
        userDefaults.set(false, forKey: AppStorageKeys.hasCompletedIntro)

        try? modelContext.delete(model: Flower.self)

        do {
            try modelContext.delete(model: GrowthSession.self)
        } catch { }
    }
}
