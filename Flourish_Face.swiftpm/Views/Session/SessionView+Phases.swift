import SwiftUI

extension SessionView {
    var phaseBackground: some View {
        Group {
            switch phase {
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
        Text("\(countdownValue)")
            .font(.system(size: 140, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .scaleEffect(countdownScale)
            .opacity(countdownOpacity)
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
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            guideIconScale = 1.0
        }
        withAnimation(.easeIn.delay(0.2)) {
            guideTextOpacity = 1.0
        }
        pulseOpacity = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.cameraWarmUp) {
            cameraWarmed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.guideAutoAdvance) {
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .ready
            }
        }
    }

    func startCountdown() {
        countdownValue = TrackingConfig.countdownStart
        countdownScale = 0.6
        countdownOpacity = 1.0

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            countdownScale = 1.0
        }
        UIAccessibility.post(notification: .announcement, argument: "\(TrackingConfig.countdownStart)")

        var remainingCount = TrackingConfig.countdownStart - 1

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
            if remainingCount > 0 {
                countdownValue = remainingCount
                countdownScale = 0.6
                countdownOpacity = 1.0

                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    countdownScale = 1.0
                }
                UIAccessibility.post(notification: .announcement, argument: "\(remainingCount)")

                remainingCount -= 1
            } else {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = .tracking
                }
            }
        }
    }

    func startSetRest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.setRestDuration) {
            manager.resetForNextSet()
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .ready
            }
        }
    }
}
