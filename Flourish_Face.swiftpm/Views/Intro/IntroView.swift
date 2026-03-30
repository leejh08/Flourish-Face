import SwiftUI

struct IntroView: View {
    @Binding var hasCompletedIntro: Bool

    @State private var phase = 0
    @State private var textOpacity: Double = 0
    @State private var backgroundBrightness: Double = 0
    @State private var seedScale: CGFloat = 0
    @State private var logoOpacity: Double = 0
    @State private var waveOffset: CGFloat = 1.0
    @State private var wavePhase: Double = 0
    @State private var animationTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.bgBlack
                .overlay(
                    Color.bgDarkGreen.opacity(backgroundBrightness)
                )
                .ignoresSafeArea()

            GeometryReader { geo in
                WaveShape(phase: wavePhase)
                    .fill(Color.bgPrimary)
                    .frame(height: geo.size.height * 1.5)
                    .offset(y: geo.size.height * waveOffset)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.easeOut(duration: 0.5)) {
                            hasCompletedIntro = true
                        }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.white.opacity(0.1)))
                    .padding(.top, 16)
                    .padding(.trailing, 24)
                }

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        if phase == 0 {
                            Image(systemName: "person.fill.viewfinder")
                                .font(.system(size: 55))
                                .foregroundStyle(.white)
                                .opacity(textOpacity)
                        } else if phase == 1 {
                            Image(systemName: "face.smiling.inverse")
                                .font(.system(size: 55))
                                .foregroundStyle(.white.opacity(0.8))
                                .opacity(textOpacity)
                        } else if phase == 2 {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 65))
                                .foregroundStyle(Color.primaryGreen)
                                .scaleEffect(seedScale)
                                .opacity(textOpacity)
                        }
                    }
                    .id("icon-layer-\(phase)")
                    .frame(height: 80)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: phase)

                    Group {
                        if phase == 0 {
                            Text("Some days, it's hard\nto look in the mirror.")
                                .opacity(textOpacity)
                        } else if phase == 1 {
                            Text("When your own smile\nfeels out of reach.")
                                .opacity(textOpacity)
                        } else if phase == 2 {
                            Text("But healing begins\nwith one small movement.")
                                .opacity(textOpacity)
                        } else {
                            Text("Flourish")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .tracking(12)
                                .opacity(logoOpacity)
                        }
                    }
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 600)
                    .frame(height: 100, alignment: .center)
                    .animation(.easeInOut(duration: 0.5), value: phase)

                    Spacer()
                        .frame(height: 70)
                }

                Spacer()
            }
            .padding(.horizontal, 48)
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                wavePhase = 1.0
            }
            startAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + Delay.sheetTransition) {
                UIAccessibility.post(notification: .announcement, argument: "Some days, it's hard to look in the mirror.")
            }
        }
        .onChange(of: phase) { _, newPhase in
            let text: String
            let delay: Double
            switch newPhase {
            case 1: text = "When your own smile feels out of reach."; delay = 0.5
            case 2: text = "But healing begins with one small movement."; delay = 2.0
            case 3: text = "Flourish"; delay = 1.0
            default: return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIAccessibility.post(notification: .announcement, argument: text)
            }
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }

    private func startAnimation() {
        animationTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 1.2)) { textOpacity = 1 }

            try? await Task.sleep(for: .seconds(3.3))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { textOpacity = 0 }

            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }
            phase = 1
            withAnimation(.easeIn(duration: 0.8)) { textOpacity = 1 }

            try? await Task.sleep(for: .seconds(2.0))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { textOpacity = 0 }

            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }
            phase = 2
            withAnimation(.easeIn(duration: 0.8)) {
                textOpacity = 1
                backgroundBrightness = 0.3
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { seedScale = 1.0 }

            try? await Task.sleep(for: .seconds(5.0))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 0
                seedScale = 0.5
            }

            try? await Task.sleep(for: .seconds(0.3))
            guard !Task.isCancelled else { return }
            phase = 3
            withAnimation(.easeIn(duration: 1.0)) {
                logoOpacity = 1
                backgroundBrightness = 0.4
            }
            withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) { waveOffset = 0.8 }

            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 1.5)) {
                waveOffset = -0.5
                logoOpacity = 0
            }

            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { hasCompletedIntro = true }
        }
    }
}
