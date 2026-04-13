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
    @State var orchestrator = SessionOrchestrator()

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

    @State var introScale: CGFloat = 0
    @State var introTextOpacity: Double = 0

    @State var guideIconScale: CGFloat = 0.5
    @State var guideTextOpacity: Double = 0
    @State var pulseOpacity: Double = 0.4

    var body: some View {
        ZStack {
            phaseBackground

            if orchestrator.phase == .guide || orchestrator.phase == .ready || orchestrator.phase == .tracking || orchestrator.phase == .setRest {
                ARFaceView(
                    manager: manager,
                    chapter: chapter,
                    exercise: exercise,
                    autoStart: orchestrator.cameraWarmed
                )
                .ignoresSafeArea()

                if orchestrator.phase == .guide || orchestrator.phase == .ready || orchestrator.phase == .setRest {
                    Color.black
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }

            switch orchestrator.phase {
            case .intro:
                SessionIntroView(
                    exercise: exercise,
                    totalSets: totalSets,
                    introScale: introScale,
                    introTextOpacity: introTextOpacity,
                    onStart: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            orchestrator.enterGuidePhase(manager: manager, exerciseGuide: exercise.guide)
                        }
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
                    showTrackingSkip: orchestrator.showTrackingSkip,
                    onSkipSet: { manager.setCompleted = true },
                    onGoBack: dismissSession
                )
                .transition(.opacity)
            case .setRest:
                SessionSetRestView(
                    currentSet: manager.currentSet,
                    totalSets: manager.totalSets
                )
                .transition(.opacity)
            }

            if orchestrator.phase != .tracking {
                VStack {
                    HStack {
                        Button(action: dismissSession) {
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

            if orchestrator.isDismissing {
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
            orchestrator.prepareForSession(manager: manager)
            startIntroPhase()
        }
        .onChange(of: orchestrator.phase) { _, newPhase in
            switch newPhase {
            case .guide:
                startGuidePhase()
            default:
                break
            }
        }
        .onChange(of: manager.setCompleted) { _, completed in
            if completed {
                orchestrator.handleSetCompletion(
                    manager: manager,
                    requiredExerciseCount: requiredExerciseCount,
                    exerciseGuide: exercise.guide,
                    saveSession: saveSession,
                    loadCompletedExerciseCount: {
                        getCompletedExercisesFromAppStorage().count
                    }
                )
            }
        }
        .onDisappear {
            orchestrator.stop(manager: manager)
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { orchestrator.showResult },
                set: { orchestrator.showResult = $0 }
            )
        ) {
            RestView(
                chapter: chapter,
                exercise: exercise,
                growthPoints: orchestrator.finalGrowthPoints,
                duration: orchestrator.finalDuration,
                completedExerciseCount: orchestrator.completedExerciseCount,
                totalExercises: requiredExerciseCount,
                isDayComplete: orchestrator.isDayComplete,
                isBonus: isBonus,
                onDismiss: dismissResult
            )
        }
    }
}
