import SwiftUI
import AVFoundation

struct HomeLaunchFlow {
    enum Sheet: String, Identifiable {
        case exercisePicker
        case setPicker

        var id: String { rawValue }
    }

    enum LaunchAction {
        case navigate(SessionConfig)
        case requestCameraAccess(SessionConfig)
        case showPermissionAlert
    }

    var navigationPath = NavigationPath()
    var activeSheet: Sheet?
    var showCameraPermissionAlert = false
    var selectedSets = 3

    private var pendingExercise: FaceExercise?
    private var isBonusPractice = false

    mutating func startBonusPractice() {
        isBonusPractice = true
        activeSheet = .exercisePicker
    }

    mutating func startDailySession(for exercise: FaceExercise) {
        isBonusPractice = false
        pendingExercise = exercise
        activeSheet = .setPicker
    }

    mutating func selectBonusExercise(_ exercise: FaceExercise) {
        pendingExercise = exercise
        activeSheet = nil
    }

    mutating func presentSetPicker() {
        activeSheet = .setPicker
    }

    mutating func prepareLaunch(chapter: Chapter, cameraStatus: AVAuthorizationStatus) -> LaunchAction? {
        activeSheet = nil

        guard let config = sessionConfig(chapter: chapter) else {
            return nil
        }

        switch cameraStatus {
        case .authorized:
            return .navigate(config)
        case .notDetermined:
            return .requestCameraAccess(config)
        case .denied, .restricted:
            showCameraPermissionAlert = true
            return .showPermissionAlert
        @unknown default:
            showCameraPermissionAlert = true
            return .showPermissionAlert
        }
    }

    mutating func resolveCameraAccess(granted: Bool, config: SessionConfig) -> LaunchAction {
        guard granted else {
            showCameraPermissionAlert = true
            return .showPermissionAlert
        }

        return .navigate(config)
    }

    mutating func startSession(_ config: SessionConfig) {
        pendingExercise = nil
        navigationPath.append(config)
    }

    private func sessionConfig(chapter: Chapter) -> SessionConfig? {
        guard let pendingExercise else {
            return nil
        }

        return SessionConfig(
            chapter: chapter,
            exercise: pendingExercise,
            isBonus: isBonusPractice,
            totalSets: selectedSets
        )
    }
}
