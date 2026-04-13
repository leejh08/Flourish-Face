import SwiftUI
import SwiftData
import AVFoundation

struct HomeView: View {
    @Binding var showFlowerPicker: Bool
    @State private var launchFlow = HomeLaunchFlow()

    @State private var wavePhase: Double = 0

    @State private var dailyQuote: String = ""
    @State private var completionQuote: String = ""

    private func getQuotesForToday() -> (motivational: String, completion: String) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())

        switch weekday {
        case 2:
            return (String(localized: "Every smile starts with hope."), String(localized: "Consistency is the key.\nYou're doing amazing!"))
        case 3:
            return (String(localized: "Healing is a journey, not a race."), String(localized: "One step closer to your goals.\nTime to rest now."))
        case 4:
            return (String(localized: "Your strength shines through."), String(localized: "Every effort builds your bloom.\nGreat job today!"))
        case 5:
            return (String(localized: "Little by little, you bloom."), String(localized: "You've nurtured your growth.\nEnjoy your rest."))
        case 6:
            return (String(localized: "Your progress is beautiful."), String(localized: "Your future smile is thanking you.\nSee you tomorrow!"))
        case 7:
            return (String(localized: "Embrace your own pace."), String(localized: "Every effort builds your bloom."))
        case 1:
            return (String(localized: "A warmer smile awaits."), String(localized: "Take it slow.\nYou've earned your rest."))
        default:
            return (String(localized: "Believe in your bloom."), String(localized: "You did it!\nSee you tomorrow."))
        }
    }

    @AppStorage(AppStorageKeys.todayCompletedExercisesData) private var todayCompletedExercisesData: String = ""
    @AppStorage(AppStorageKeys.lastExerciseDate) private var lastExerciseDate: String = ""
    @AppStorage(AppStorageKeys.totalGrowthPoints) private var totalGrowthPoints: Double = 0
    @AppStorage(AppStorageKeys.flowersEarned) private var flowersEarned: Int = 0
    @AppStorage(AppStorageKeys.pendingFlowerPick) private var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.affectedSide) private var affectedSide: AffectedSide = .none
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue

    var body: some View {
        NavigationStack(path: $launchFlow.navigationPath) {
            ZStack {
                HomeBackgroundView(wavePhase: wavePhase)

                ParticleEffectView()

                VStack(spacing: 0) {
                    HomeTopBar(flowersEarned: flowersEarned)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)

                    Spacer(minLength: 24)

                    Text(derivedState.displayMessage)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    HomeProgressRing(
                        todayCompletedExercisesCount: derivedState.completedExercisesCount,
                        totalExercises: derivedState.currentExercises.count,
                        currentChapter: derivedState.currentChapter
                    )

                    Spacer()

                    HomeStepIndicator(
                        exercises: derivedState.currentExercises,
                        todayCompletedExercises: derivedState.todayCompletedExercises,
                        nextExercise: derivedState.nextExercise,
                        isTodayComplete: derivedState.isTodayComplete
                    )
                    .padding(.horizontal, 32)

                    startButton
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: SessionConfig.self) { config in
                SessionView(
                    chapter: config.chapter,
                    exercise: config.exercise,
                    isBonus: config.isBonus,
                    totalSets: config.totalSets,
                    navigationPath: $launchFlow.navigationPath
                )
            }
            .onAppear {
                checkAndResetForNewDay()
                startBackgroundAnimations()

                let quotes = getQuotesForToday()
                dailyQuote = quotes.motivational
                completionQuote = quotes.completion

                if derivedState.isTodayComplete {
                    NotificationManager.shared.cancelStreakReminder()
                } else {
                    NotificationManager.shared.scheduleStreakReminder()
                }

                if pendingFlowerPick {
                    showFlowerPicker = true
                }
            }
            .onChange(of: launchFlow.navigationPath) { _, newPath in
                if newPath.isEmpty {
                    checkAndResetForNewDay()
                    if pendingFlowerPick {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.flowerPicker) {
                            showFlowerPicker = true
                        }
                    }
                }
            }
            .sheet(item: $launchFlow.activeSheet) { sheet in
                switch sheet {
                case .exercisePicker:
                    ExercisePickerSheet(
                        exercises: derivedState.currentExercises,
                        onSelect: { exercise in
                            launchFlow.selectBonusExercise(exercise)
                            DispatchQueue.main.asyncAfter(deadline: .now() + Delay.sheetTransition) {
                                launchFlow.presentSetPicker()
                            }
                        }
                    )
                    .presentationDetents([.height(derivedState.currentExercises.count > 3 ? 480 : 360)])
                    .presentationDragIndicator(.visible)

                case .setPicker:
                    SetPickerSheet(selectedSets: $launchFlow.selectedSets) {
                        startPendingSession()
                    }
                    .presentationDetents([.height(340)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThinMaterial)
                }
            }
            .alert("Camera Access Required", isPresented: $launchFlow.showCameraPermissionAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Flourish needs camera access to track your facial movements. Please enable it in Settings.")
            }
        }
    }

    private var startButton: some View {
        Group {
            if pendingFlowerPick {
                Button {
                    showFlowerPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Text("🌸")
                        Text("Pick Your Flower")
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [Color.accentPink, Color.accentPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                }
                .accessibilityLabel("Pick your flower reward")
            } else if derivedState.isTodayComplete {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.primaryGreen)
                        Text("All Done Today")
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))

                    Button {
                        launchFlow.startBonusPractice()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                            Text("Practice More")
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Practice more exercises")
                }
            } else if case let .startNextExercise(exercise, buttonText) = derivedState.primaryAction {
                Button {
                    launchFlow.startDailySession(for: exercise)
                } label: {
                    HStack(spacing: 10) {
                        Text(buttonText)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryGreen)
                    )
                }
                .accessibilityLabel(buttonText)
                .accessibilityHint(String(format: String(localized: "Start %@ exercise"), exercise.guide))
            }
        }
    }

    private func startBackgroundAnimations() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                wavePhase = 1.0
            }
        }
    }

    private func startPendingSession() {
        guard let action = launchFlow.prepareLaunch(
            chapter: derivedState.currentChapter,
            cameraStatus: AVCaptureDevice.authorizationStatus(for: .video)
        ) else {
            return
        }

        handleLaunchAction(action)
    }

    private func handleLaunchAction(_ action: HomeLaunchFlow.LaunchAction) {
        switch action {
        case .navigate(let config):
            launchFlow.startSession(config)

        case .requestCameraAccess(let config):
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    let nextAction = launchFlow.resolveCameraAccess(granted: granted, config: config)
                    handleLaunchAction(nextAction)
                }
            }

        case .showPermissionAlert:
            break
        }
    }

    private func checkAndResetForNewDay() {
        let todayString = AppStorageKeys.todayString()
        if lastExerciseDate != todayString {
            todayCompletedExercisesData = ""
            lastExerciseDate = todayString
        }
    }

}
