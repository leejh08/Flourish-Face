import SwiftUI
import SwiftData
import AVFoundation

struct HomeView: View {
    @Binding var showFlowerPicker: Bool
    @State private var navigationPath = NavigationPath()

    @State private var showCameraPermissionAlert = false
    @State private var pendingSessionConfig: SessionConfig?

    @State private var showExercisePicker = false
    @State private var isBonusPractice = false
    @State private var showSetPicker = false
    @State private var selectedSets: Int = 3
    @State private var pendingExercise: FaceExercise?

    @State private var wavePhase: Double = 0

    @State private var dailyQuote: String = ""
    @State private var completionQuote: String = ""

    private func getQuotesForToday() -> (motivational: String, completion: String) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())

        switch weekday {
        case 2:
            return ("Every smile starts with hope.", "Consistency is the key.\nYou're doing amazing!")
        case 3:
            return ("Healing is a journey, not a race.", "One step closer to your goals.\nTime to rest now.")
        case 4:
            return ("Your strength shines through.", "Every effort builds your bloom.\nGreat job today!")
        case 5:
            return ("Little by little, you bloom.", "You've nurtured your growth.\nEnjoy your rest.")
        case 6:
            return ("Your progress is beautiful.", "Your future smile is thanking you.\nSee you tomorrow!")
        case 7:
            return ("Embrace your own pace.", "Every effort builds your bloom.")
        case 1:
            return ("A warmer smile awaits.", "Take it slow.\nYou've earned your rest.")
        default:
            return ("Believe in your bloom.", "You did it!\nSee you tomorrow.")
        }
    }

    @AppStorage(AppStorageKeys.todayCompletedExercisesData) private var todayCompletedExercisesData: String = ""
    @AppStorage(AppStorageKeys.lastExerciseDate) private var lastExerciseDate: String = ""
    @AppStorage(AppStorageKeys.totalGrowthPoints) private var totalGrowthPoints: Double = 0
    @AppStorage(AppStorageKeys.flowersEarned) private var flowersEarned: Int = 0
    @AppStorage(AppStorageKeys.pendingFlowerPick) private var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.affectedSide) private var affectedSide: AffectedSide = .none
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue

    private var currentDifficulty: Difficulty {
        Difficulty(rawValue: selectedDifficulty) ?? .basic
    }

    private var currentExercises: [FaceExercise] {
        FaceExercise.exercises(for: currentDifficulty)
    }

    private var todayCompletedExercises: Set<Int> {
        guard lastExerciseDate == AppStorageKeys.todayString() else { return [] }
        return AppStorageKeys.parseCompletedExercises(todayCompletedExercisesData)
    }

    private var isTodayComplete: Bool {
        todayCompletedExercises.count >= currentExercises.count
    }

    private var nextExercise: FaceExercise? {
        for exercise in currentExercises {
            if !todayCompletedExercises.contains(exercise.rawValue) {
                return exercise
            }
        }
        return nil
    }

    private var currentChapter: Chapter {
        switch totalGrowthPoints {
        case 0..<20: return .seed
        case 20..<50: return .sprout
        case 50..<100: return .bloom
        default: return .breeze
        }
    }

    private var displayMessage: String {
        if isTodayComplete {
            return completionQuote.isEmpty ? "You did it!\nSee you tomorrow." : completionQuote
        } else {
            return dailyQuote
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                HomeBackgroundView(wavePhase: wavePhase)

                ParticleEffectView()

                VStack(spacing: 0) {
                    HomeTopBar(flowersEarned: flowersEarned)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)

                    Spacer(minLength: 24)

                    Text(displayMessage)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    HomeProgressRing(
                        todayCompletedExercisesCount: todayCompletedExercises.count,
                        totalExercises: currentExercises.count,
                        currentChapter: currentChapter
                    )

                    Spacer()

                    HomeStepIndicator(
                        exercises: currentExercises,
                        todayCompletedExercises: todayCompletedExercises,
                        nextExercise: nextExercise,
                        isTodayComplete: isTodayComplete
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
                SessionView(chapter: config.chapter, exercise: config.exercise, isBonus: config.isBonus, totalSets: config.totalSets, navigationPath: $navigationPath)
            }
            .onAppear {
                checkAndResetForNewDay()
                startBackgroundAnimations()

                let quotes = getQuotesForToday()
                dailyQuote = quotes.motivational
                completionQuote = quotes.completion

                if pendingFlowerPick {
                    showFlowerPicker = true
                }
            }
            .onChange(of: navigationPath) { _, newPath in
                if newPath.isEmpty {
                    checkAndResetForNewDay()
                    if pendingFlowerPick {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.flowerPicker) {
                            showFlowerPicker = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showSetPicker) {
                SetPickerSheet(selectedSets: $selectedSets) {
                    showSetPicker = false
                    if let exercise = pendingExercise {
                        let config = SessionConfig(
                            chapter: currentChapter,
                            exercise: exercise,
                            isBonus: isBonusPractice,
                            totalSets: selectedSets
                        )
                        requestCameraPermissionAndStart(config: config)
                    }
                }
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet(
                    exercises: currentExercises,
                    onSelect: { exercise in
                        showExercisePicker = false
                        pendingExercise = exercise
                        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.sheetTransition) {
                            showSetPicker = true
                        }
                    }
                )
                .presentationDetents([.height(currentExercises.count > 3 ? 480 : 360)])
                .presentationDragIndicator(.visible)
            }
            .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
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
            } else if isTodayComplete {
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
                        isBonusPractice = true
                        showExercisePicker = true
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
            } else if let exercise = nextExercise {
                let buttonText: String = {
                    let completedCount = todayCompletedExercises.count

                    if currentDifficulty == .basic {
                        switch completedCount {
                        case 0: return "Wake Up Your Smile"
                        case 1: return "Keep the Flow"
                        default: return "Complete Your Day"
                        }
                    } else {
                        switch completedCount {
                        case 0: return "Start Your Training"
                        case 1: return "Build the Momentum"
                        case 2: return "You're Warming Up"
                        case 3: return "Almost There"
                        default: return "One More to Go!"
                        }
                    }
                }()

                Button {
                    isBonusPractice = false
                    pendingExercise = exercise
                    showSetPicker = true
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
                .accessibilityHint("Start \(exercise.guide) exercise")
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

    private func requestCameraPermissionAndStart(config: SessionConfig) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            navigationPath.append(config)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        navigationPath.append(config)
                    } else {
                        showCameraPermissionAlert = true
                    }
                }
            }

        case .denied, .restricted:
            showCameraPermissionAlert = true

        @unknown default:
            showCameraPermissionAlert = true
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
