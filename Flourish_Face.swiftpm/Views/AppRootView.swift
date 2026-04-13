import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showFlowerPicker = false
    @State private var newlyAddedFlowerType: FlowerType? = nil
    @AppStorage(AppStorageKeys.todayCompletedExercisesData) private var todayCompletedExercisesData: String = ""
    @AppStorage(AppStorageKeys.lastExerciseDate) private var lastExerciseDate: String = ""
    @AppStorage(AppStorageKeys.flowersEarned) private var flowersEarned: Int = 0
    @AppStorage(AppStorageKeys.pendingFlowerPick) private var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedIntro) private var hasCompletedIntro: Bool = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                mainContent
            } else if !hasCompletedIntro {
                IntroView(hasCompletedIntro: $hasCompletedIntro)
                    .transition(.opacity)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedIntro)
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if completed {
                selectedTab = 0
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(showFlowerPicker: $showFlowerPicker)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                CollectionView(newlyAddedFlowerType: $newlyAddedFlowerType)
                    .tabItem {
                        Label("Collection", systemImage: "star.fill")
                    }
                    .tag(1)

                LogView()
                    .tabItem {
                        Label("Growth", systemImage: "chart.bar.fill")
                    }
                    .tag(2)
            }
            .tint(Color.primaryGreen)

            if showFlowerPicker {
                FlowerPickerView { selectedFlower in
                    let flower = Flower(type: selectedFlower)
                    modelContext.insert(flower)
                    var progressState = dailyProgressState
                    progressState.consumePendingFlowerReward()
                    storeDailyProgressState(progressState)
                    newlyAddedFlowerType = selectedFlower
                    showFlowerPicker = false
                    selectedTab = 1
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            if dailyProgressState.hasPendingFlowerReward {
                showFlowerPicker = true
            }
        }
    }

    private var dailyProgressState: DailyProgressState {
        DailyProgressState(
            completedExercisesData: todayCompletedExercisesData,
            lastExerciseDate: lastExerciseDate,
            flowersEarned: flowersEarned,
            pendingFlowerPick: pendingFlowerPick
        )
    }

    private func storeDailyProgressState(_ state: DailyProgressState) {
        todayCompletedExercisesData = state.completedExercisesData
        lastExerciseDate = state.lastExerciseDate
        flowersEarned = state.flowersEarned
        pendingFlowerPick = state.pendingFlowerPick
    }
}
