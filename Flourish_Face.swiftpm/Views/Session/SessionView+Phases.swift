import SwiftUI

extension SessionView {
    var phaseBackground: some View {
        Group {
            switch orchestrator.phase {
            case .intro:
                LinearGradient(
                    colors: [Color.bgDarkGreen, Color.bgDeepGreen],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            case .guide:
                LinearGradient(
                    colors: [Color.bgSageGreen, Color.bgDarkGreen],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            case .ready, .tracking:
                Color.black.ignoresSafeArea()
            case .setRest:
                LinearGradient(
                    colors: [Color.bgDarkGreen, Color.bgDeepGreen],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }

    var countdownContent: some View {
        Text("\(orchestrator.countdownValue)")
            .font(.system(size: 140, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .scaleEffect(orchestrator.countdownScale)
            .opacity(orchestrator.countdownOpacity)
    }

    func startIntroPhase() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            introScale = 1.0
        }
        withAnimation(.easeIn.delay(0.3)) {
            introTextOpacity = 1.0
        }
    }

    func startGuidePhase() {
        guideIconScale = 0.5
        guideTextOpacity = 0
        pulseOpacity = 0.4

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            guideIconScale = 1.0
        }
        withAnimation(.easeIn.delay(0.2)) {
            guideTextOpacity = 1.0
        }
        pulseOpacity = 0.5
    }

    func dismissSession() {
        orchestrator.dismissSession(manager: manager) {
            navigationPath = NavigationPath()
        }
    }

    func dismissResult() {
        orchestrator.dismissResult {
            navigationPath = NavigationPath()
        }
    }
}
