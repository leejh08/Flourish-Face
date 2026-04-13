import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var shellState = AppRootShellState()
    @AppStorage(AppStorageKeys.pendingFlowerPick) private var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedIntro) private var hasCompletedIntro: Bool = false

    var body: some View {
        ZStack {
            switch AppRootRoute(
                hasCompletedIntro: hasCompletedIntro,
                hasCompletedOnboarding: hasCompletedOnboarding
            ) {
            case .mainContent:
                mainContent
            case .intro:
                IntroView(hasCompletedIntro: $hasCompletedIntro)
                    .transition(.opacity)
            case .onboarding:
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedIntro)
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if completed {
                shellState.handleOnboardingCompletion()
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            TabView(selection: $shellState.selectedTab) {
                HomeView(showFlowerPicker: $shellState.showFlowerPicker)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                CollectionView(newlyAddedFlowerType: $shellState.newlyAddedFlowerType)
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

            if shellState.showFlowerPicker {
                FlowerPickerView { selectedFlower in
                    shellState.claimFlowerReward(
                        selectedFlower,
                        pendingFlowerPick: &pendingFlowerPick,
                        modelContext: modelContext
                    )
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            shellState.syncPendingFlowerReward(pendingFlowerPick)
        }
    }
}
