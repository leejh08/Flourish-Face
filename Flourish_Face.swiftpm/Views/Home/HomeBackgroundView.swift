import SwiftUI

struct HomeBackgroundView: View {
    let wavePhase: Double

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.bgDarkTeal,
                        Color.bgTeal,
                        Color.bgTealMedium
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ZStack {
                    Circle()
                        .fill(Color.accentGold.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -200)

                    Circle()
                        .fill(Color.primaryGreen.opacity(0.08))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: 150, y: 100)
                }

                WaveShape(phase: wavePhase)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.bgForest.opacity(0.4),
                                Color.bgDeepGreen.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 200)
                    .offset(y: geo.size.height - 100)
                    .blur(radius: 5)

                WaveShape(phase: wavePhase + 0.5)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.bgSageGreen.opacity(0.3),
                                Color.bgForest.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 180)
                    .offset(y: geo.size.height - 80)
                    .blur(radius: 3)
            }
        }
    }
}