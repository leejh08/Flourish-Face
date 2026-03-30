import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var appeared = false
    @AppStorage(AppStorageKeys.affectedSide) private var affectedSide: AffectedSide = .none
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue

    private let totalPages = 5

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "face.smiling.fill",
                        iconColor: Color.primaryGreen,
                        title: "Practice simple\nface exercises",
                        subtitle: "Daily exercises\nto support your recovery."
                    )
                    .tag(0)

                    OnboardingPage(
                        icon: "sparkle",
                        iconColor: Color.pinkLight,
                        title: "Earn flowers daily",
                        subtitle: "Complete all exercises\nto collect a flower."
                    )
                    .tag(1)

                    OnboardingPage(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: Color.accentBlue,
                        title: "Track your progress",
                        subtitle: "Watch your smile\ngrow stronger."
                    )
                    .tag(2)

                    DifficultySelectionPage(
                        selectedDifficulty: $selectedDifficulty,
                        onNext: {
                            withAnimation { currentPage = min(currentPage + 1, totalPages - 1) }
                        }
                    )
                    .tag(3)

                    AffectedSideSelectionPage(
                        selectedSide: $affectedSide,
                        onComplete: { completeOnboarding() }
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primaryGreen : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                Button {
                    withAnimation { currentPage = min(currentPage + 1, totalPages - 1) }
                } label: {
                    Text("Next")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .opacity(currentPage == totalPages - 1 ? 0 : 1)
                .animation(.easeOut(duration: 0.3), value: currentPage)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.bgPrimary, Color.bgSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryGreen.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -250)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.accentPink.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 120, y: 350)
        }
    }

    private func completeOnboarding() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
