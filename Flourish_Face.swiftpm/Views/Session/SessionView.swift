import SwiftUI
import SwiftData

struct SessionView: View {
    let chapter: Chapter
    let exercise: FaceExercise
    var isBonus: Bool = false
    var totalSets: Int = 3
    @Binding var navigationPath: NavigationPath

    @Environment(\.modelContext) var modelContext
    @State var manager = FaceTrackingManager()
    @State var showResult = false

    @AppStorage(AppStorageKeys.todayCompletedExercisesData) var todayCompletedExercisesData: String = ""
    @AppStorage(AppStorageKeys.lastExerciseDate) var lastExerciseDate: String = ""
    @AppStorage(AppStorageKeys.totalGrowthPoints) var totalGrowthPoints: Double = 0
    @AppStorage(AppStorageKeys.flowersEarned) var appFlowersEarned: Int = 0
    @AppStorage(AppStorageKeys.pendingFlowerPick) var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.affectedSide) var affectedSide: AffectedSide = .none
    @AppStorage(AppStorageKeys.selectedDifficulty) var selectedDifficulty: String = Difficulty.basic.rawValue

    var currentDifficulty: Difficulty {
        Difficulty(rawValue: selectedDifficulty) ?? .basic
    }

    var requiredExerciseCount: Int {
        FaceExercise.exercises(for: currentDifficulty).count
    }

    @State var phase: SessionPhase = .intro

    @State var introScale: CGFloat = 0
    @State var introTextOpacity: Double = 0

    @State var guideIconScale: CGFloat = 0.5
    @State var guideTextOpacity: Double = 0
    @State var pulseOpacity: Double = 0.4

    @State var countdownValue: Int = TrackingConfig.countdownStart
    @State var countdownScale: CGFloat = 1.0
    @State var countdownOpacity: Double = 1.0

    @State var finalGrowthPoints: Double = 0
    @State var finalDuration: TimeInterval = 0
    @State var completedExerciseCount: Int = 0
    @State var isDayComplete: Bool = false
    @State var isDismissing: Bool = false
    @State var cameraWarmed: Bool = false
    @State var showTrackingSkip: Bool = false
    @State var countdownTimer: Timer?

    var body: some View {
        ZStack {
            phaseBackground

            if phase == .guide || phase == .ready || phase == .tracking || phase == .setRest {
                ARFaceView(
                    manager: manager,
                    chapter: chapter,
                    exercise: exercise,
                    autoStart: cameraWarmed
                )
                .ignoresSafeArea()

                if phase == .guide || phase == .ready || phase == .setRest {
                    Color.black
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }

            switch phase {
            case .intro:
                SessionIntroView(
                    exercise: exercise,
                    totalSets: totalSets,
                    introScale: introScale,
                    introTextOpacity: introTextOpacity,
                    onStart: {
                        withAnimation(.easeInOut(duration: 0.4)) { phase = .guide }
                    }
                )
                .transition(.opacity)
            case .guide:
                SessionGuideView(
                    exercise: exercise,
                    guideIconScale: guideIconScale,
                    guideTextOpacity: guideTextOpacity,
                    pulseOpacity: pulseOpacity
                )
                .transition(.opacity)
            case .ready:
                countdownContent
                    .transition(.opacity)
            case .tracking:
                SessionTrackingView(
                    manager: manager,
                    exercise: exercise,
                    showTrackingSkip: showTrackingSkip,
                    onSkipSet: { manager.setCompleted = true },
                    onGoBack: {
                        countdownTimer?.invalidate()
                        countdownTimer = nil
                        manager.stopTracking()
                        navigationPath = NavigationPath()
                    }
                )
                .transition(.opacity)
            case .setRest:
                SessionSetRestView(
                    currentSet: manager.currentSet,
                    totalSets: manager.totalSets
                )
                .transition(.opacity)
            }

            if phase != .tracking {
                VStack {
                    HStack {
                        Button {
                            countdownTimer?.invalidate()
                            countdownTimer = nil
                            manager.stopTracking()
                            navigationPath = NavigationPath()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.8))
                                .shadow(radius: 4)
                        }
                        .accessibilityLabel("Close session")
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 8)
                    Spacer()
                }
            }

            if isDismissing {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            manager.setAffectedSide(affectedSide)
            manager.totalSets = totalSets
            startIntroPhase()
        }
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .guide:
                startGuidePhase()
            case .ready:
                startCountdown()
            case .tracking:
                manager.isProcessingEnabled = true
                showTrackingSkip = false
                DispatchQueue.main.asyncAfter(deadline: .now() + Delay.flowerPicker) {
                    UIAccessibility.post(notification: .announcement, argument: exercise.guide)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Delay.skipButtonReveal) {
                    if phase == .tracking && !manager.setCompleted {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showTrackingSkip = true
                        }
                    }
                }
            case .intro:
                break
            case .setRest:
                manager.isProcessingEnabled = false
                startSetRest()
            }
        }
        .onChange(of: manager.setCompleted) { _, completed in
            if completed {
                if manager.currentSet >= manager.totalSets {
                    finalGrowthPoints = manager.totalGrowthAccumulated
                    finalDuration = manager.elapsedTime

                    saveSession()

                    let completedSet = getCompletedExercisesFromAppStorage()
                    completedExerciseCount = completedSet.count
                    isDayComplete = completedExerciseCount >= requiredExerciseCount

                    showResult = true
                } else {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        phase = .setRest
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            RestView(
                chapter: chapter,
                exercise: exercise,
                growthPoints: finalGrowthPoints,
                duration: finalDuration,
                completedExerciseCount: completedExerciseCount,
                totalExercises: requiredExerciseCount,
                isDayComplete: isDayComplete,
                isBonus: isBonus,
                onDismiss: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isDismissing = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Delay.uiTransition) {
                        showResult = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.navigationDismiss) {
                            navigationPath = NavigationPath()
                        }
                    }
                }
            )
        }
    }
}
