import SwiftUI
import Observation

@MainActor
@Observable
final class SessionOrchestrator {
    var phase: SessionPhase = .intro
    var showResult = false
    var countdownValue = TrackingConfig.countdownStart
    var countdownScale: CGFloat = 1.0
    var countdownOpacity: Double = 1.0
    var finalGrowthPoints: Double = 0
    var finalDuration: TimeInterval = 0
    var completedExerciseCount: Int = 0
    var isDayComplete = false
    var isDismissing = false
    var cameraWarmed = false
    var showTrackingSkip = false

    private weak var trackingManager: FaceTrackingManager?
    private var countdownTimer: Timer?
    private var scheduledWork: [ScheduledWork: DispatchWorkItem] = [:]

    func prepareForSession(manager: FaceTrackingManager) {
        cancelAllScheduledWork()
        invalidateCountdown()
        trackingManager = manager

        phase = .intro
        showResult = false
        countdownValue = TrackingConfig.countdownStart
        countdownScale = 1.0
        countdownOpacity = 1.0
        finalGrowthPoints = 0
        finalDuration = 0
        completedExerciseCount = 0
        isDayComplete = false
        isDismissing = false
        cameraWarmed = false
        showTrackingSkip = false
    }

    func enterGuidePhase(manager: FaceTrackingManager, exerciseGuide: String) {
        trackingManager = manager
        cancel(work: [.trackingAnnouncement, .skipReveal, .setRestAdvance, .resultDismiss, .navigationDismiss])
        invalidateCountdown()

        phase = .guide
        showTrackingSkip = false

        schedule(.cameraWarmUp, after: Delay.cameraWarmUp) { [weak self] in
            self?.cameraWarmed = true
        }

        schedule(.guideAdvance, after: Delay.guideAutoAdvance) { [weak self] in
            guard let self else { return }
            guard let manager = self.trackingManager else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                self.enterReadyPhase(manager: manager, exerciseGuide: exerciseGuide)
            }
        }
    }

    func enterReadyPhase(manager: FaceTrackingManager, exerciseGuide: String) {
        trackingManager = manager
        cancel(work: [.guideAdvance, .setRestAdvance, .trackingAnnouncement, .skipReveal])
        invalidateCountdown()

        phase = .ready
        countdownValue = TrackingConfig.countdownStart
        countdownScale = 0.6
        countdownOpacity = 1.0

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            countdownScale = 1.0
        }
        UIAccessibility.post(notification: .announcement, argument: "\(TrackingConfig.countdownStart)")

        var remainingCount = TrackingConfig.countdownStart - 1
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self else {
                    timer.invalidate()
                    return
                }

                guard let manager = self.trackingManager else {
                    self.invalidateCountdown()
                    return
                }

                if remainingCount > 0 {
                    self.countdownValue = remainingCount
                    self.countdownScale = 0.6
                    self.countdownOpacity = 1.0

                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        self.countdownScale = 1.0
                    }
                    UIAccessibility.post(notification: .announcement, argument: "\(remainingCount)")

                    remainingCount -= 1
                } else {
                    self.invalidateCountdown()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.enterTrackingPhase(manager: manager, exerciseGuide: exerciseGuide)
                    }
                }
            }
        }
    }

    func enterTrackingPhase(manager: FaceTrackingManager, exerciseGuide: String) {
        trackingManager = manager
        cancel(work: [.guideAdvance, .setRestAdvance])
        invalidateCountdown()

        phase = .tracking
        manager.isProcessingEnabled = true
        showTrackingSkip = false

        schedule(.trackingAnnouncement, after: Delay.flowerPicker) {
            UIAccessibility.post(notification: .announcement, argument: exerciseGuide)
        }

        schedule(.skipReveal, after: Delay.skipButtonReveal) { [weak self] in
            guard let self else { return }
            guard let manager = self.trackingManager else { return }
            guard self.phase == .tracking, !manager.setCompleted else { return }

            withAnimation(.easeInOut(duration: 0.3)) {
                self.showTrackingSkip = true
            }
        }
    }

    func handleSetCompletion(
        manager: FaceTrackingManager,
        requiredExerciseCount: Int,
        exerciseGuide: String,
        saveSession: () -> Void,
        loadCompletedExerciseCount: () -> Int
    ) {
        trackingManager = manager
        cancel(work: [.trackingAnnouncement, .skipReveal])

        if manager.currentSet >= manager.totalSets {
            finalGrowthPoints = manager.totalGrowthAccumulated
            finalDuration = manager.elapsedTime
            manager.isProcessingEnabled = false

            saveSession()

            let completedCount = loadCompletedExerciseCount()
            completedExerciseCount = completedCount
            isDayComplete = completedCount >= requiredExerciseCount
            showResult = true
            return
        }

        enterSetRestPhase(manager: manager, exerciseGuide: exerciseGuide)
    }

    func enterSetRestPhase(manager: FaceTrackingManager, exerciseGuide: String) {
        trackingManager = manager
        cancel(work: [.trackingAnnouncement, .skipReveal])
        invalidateCountdown()

        phase = .setRest
        manager.isProcessingEnabled = false

        schedule(.setRestAdvance, after: Delay.setRestDuration) { [weak self] in
            guard let self else { return }
            guard let manager = self.trackingManager else { return }
            manager.resetForNextSet()
            withAnimation(.easeInOut(duration: 0.4)) {
                self.enterReadyPhase(manager: manager, exerciseGuide: exerciseGuide)
            }
        }
    }

    func dismissSession(manager: FaceTrackingManager, onDismiss: () -> Void) {
        trackingManager = manager
        cancelAllScheduledWork()
        invalidateCountdown()
        manager.isProcessingEnabled = false
        manager.stopTracking()
        onDismiss()
    }

    func dismissResult(onNavigationDismiss: @escaping () -> Void) {
        cancel(work: [.resultDismiss, .navigationDismiss])

        withAnimation(.easeOut(duration: 0.2)) {
            isDismissing = true
        }

        schedule(.resultDismiss, after: Delay.uiTransition) { [weak self] in
            guard let self else { return }

            self.showResult = false
            self.schedule(.navigationDismiss, after: Delay.navigationDismiss) { [weak self] in
                guard let self else { return }
                self.isDismissing = false
                onNavigationDismiss()
            }
        }
    }

    func stop(manager: FaceTrackingManager) {
        trackingManager = manager
        cancelAllScheduledWork()
        invalidateCountdown()
        manager.isProcessingEnabled = false
        manager.stopTracking()
    }

    private func invalidateCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func schedule(_ work: ScheduledWork, after delay: TimeInterval, action: @escaping @MainActor () -> Void) {
        cancel(work: [work])

        let item = DispatchWorkItem { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                action()
                self.scheduledWork[work] = nil
            }
        }
        scheduledWork[work] = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    private func cancel(work items: [ScheduledWork]) {
        for item in items {
            scheduledWork[item]?.cancel()
            scheduledWork[item] = nil
        }
    }

    private func cancelAllScheduledWork() {
        cancel(work: Array(scheduledWork.keys))
    }
}

private extension SessionOrchestrator {
    enum ScheduledWork: Hashable {
        case cameraWarmUp
        case guideAdvance
        case trackingAnnouncement
        case skipReveal
        case setRestAdvance
        case resultDismiss
        case navigationDismiss
    }
}
