import SwiftUI

struct GardenView: View {
    var growthRate: Double
    var sessionCount: Int

    @State private var phase: Double = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let groundY = h * 0.75

            ZStack {
                skyBackground(width: w, height: h)

                if growthRate >= 0.2 {
                    cloudGroup(width: w, groundY: groundY)
                }

                if growthRate >= 0.5 {
                    sunView
                        .position(x: w * 0.82, y: h * 0.18)
                        .opacity(min(1.0, (growthRate - 0.5) * 4))
                }

                groundLayer(width: w, height: h, groundY: groundY)

                grassPatches(width: w, groundY: groundY)

                sessionFlowers(width: w, groundY: groundY)

                mainPlant(width: w, groundY: groundY)

                if growthRate >= 1.0 {
                    butterflyGroup(width: w, groundY: groundY)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }

    private func skyBackground(width: CGFloat, height: CGFloat) -> some View {
        let topColor: Color = growthRate < 0.5
            ? Color.plantGreenMist
            : Color.skyBlue
        let bottomColor: Color = growthRate < 0.5
            ? Color.plantGreenFog
            : Color.skyBlueLight

        return LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .top,
            endPoint: .center
        )
        .frame(width: max(0, width), height: max(0, height))
    }

    private func cloudGroup(width: CGFloat, groundY: CGFloat) -> some View {
        let opacity = min(0.8, (growthRate - 0.2) * 2)
        return Group {
            CloudShape()
                .fill(.white.opacity(opacity))
                .frame(width: 60, height: 25)
                .offset(x: -width * 0.25 + phase * 8, y: -groundY * 0.5)

            CloudShape()
                .fill(.white.opacity(opacity * 0.7))
                .frame(width: 45, height: 20)
                .offset(x: width * 0.2 - phase * 5, y: -groundY * 0.6)
        }
    }

    private var sunView: some View {
        ZStack {
            Circle()
                .fill(Color.plantYellowLight.opacity(0.4))
                .frame(width: 50, height: 50)
                .scaleEffect(1.0 + phase * 0.1)
            Circle()
                .fill(Color.statusYellow)
                .frame(width: 30, height: 30)
        }
    }

    private func groundLayer(width: CGFloat, height: CGFloat, groundY: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: max(0, groundY - 8))

            GrassEdgeShape()
                .fill(Color.plantGreen)
                .frame(width: max(0, width), height: 16)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.plantGreen, Color.plantGreenMid, Color.plantGreenDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: max(0, width), height: max(0, height - groundY + 8))
        }
        .frame(width: max(0, width), height: max(0, height), alignment: .top)
    }

    private func grassPatches(width: CGFloat, groundY: CGFloat) -> some View {
        let blades: [(x: CGFloat, yOff: CGFloat, h: CGFloat)] = [
            (0.10, 0, 10), (0.25, -2, 12), (0.40, 1, 9), (0.60, -1, 11),
            (0.75, 2, 13), (0.88, -1, 10), (0.15, 1, 8), (0.55, 0, 12),
            (0.35, -2, 11), (0.80, 1, 9), (0.92, 0, 10), (0.05, -1, 11)
        ]

        return ForEach(Array(blades.enumerated()), id: \.offset) { _, blade in
            GrassBlade(height: blade.h)
                .stroke(Color.plantGreenAccent, lineWidth: 1.5)
                .frame(width: 6, height: 14)
                .position(x: width * blade.x, y: groundY + blade.yOff - 4)
        }
    }

    private func sessionFlowers(width: CGFloat, groundY: CGFloat) -> some View {
        let maxFlowers = min(sessionCount, 12)
        let flowerPositions: [(x: CGFloat, yOff: CGFloat, size: CGFloat, hue: Color)] = [
            (0.12, -8, 12, .gardenRed),
            (0.88, -6, 10, .statusYellow),
            (0.22, -10, 11, .gardenPurple),
            (0.78, -9, 13, .gardenOrange),
            (0.08, -7, 9, .gardenCyan),
            (0.92, -8, 11, .plantPink),
            (0.32, -6, 10, .plantGreenPale),
            (0.68, -10, 12, .gardenBlue),
            (0.18, -9, 10, .gardenPeach),
            (0.82, -7, 11, .gardenLilac),
            (0.42, -8, 9, .gardenCoral),
            (0.58, -6, 10, .gardenTeal),
        ]

        return ForEach(0..<maxFlowers, id: \.self) { i in
            let pos = flowerPositions[i]
            SmallFlower(size: pos.size, color: pos.hue, phase: phase)
                .position(x: width * pos.x, y: groundY + pos.yOff)
        }
    }

    private func mainPlant(width: CGFloat, groundY: CGFloat) -> some View {
        let centerX = width * 0.5

        return ZStack {
            if growthRate < 0.2 {
                seedStage(phase: phase)
                    .position(x: centerX, y: groundY - 15)
            } else if growthRate < 0.5 {
                sproutStage(progress: (growthRate - 0.2) / 0.3)
                    .position(x: centerX, y: groundY - 60)
            } else if growthRate < 1.0 {
                bloomStage(progress: (growthRate - 0.5) / 0.5, phase: phase)
                    .position(x: centerX, y: groundY - 100)
            } else {
                treeStage(phase: phase)
                    .position(x: centerX, y: groundY - 140)
            }
        }
    }

    private func butterflyGroup(width: CGFloat, groundY: CGFloat) -> some View {
        Group {
            ButterflyView(color: Color.statusYellow)
                .offset(
                    x: width * 0.3 + sin(phase * .pi) * 20,
                    y: groundY - 100 + cos(phase * .pi * 1.5) * 15
                )
            ButterflyView(color: Color.plantPink)
                .offset(
                    x: width * 0.65 + cos(phase * .pi) * 15,
                    y: groundY - 80 + sin(phase * .pi * 1.2) * 20
                )
        }
    }

    private func seedStage(phase: Double) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.plantBrown, Color.plantBrownDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 24)

            Circle()
                .stroke(Color.plantGreenPale.opacity(0.5), lineWidth: 3)
                .frame(width: 56, height: 56)
                .scaleEffect(1.0 + phase * 0.2)
                .opacity(1.0 - phase * 0.5)
        }
    }

    private func sproutStage(progress: Double) -> some View {
        let stemHeight: CGFloat = 40 + 80 * progress

        return ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.plantGreen)
                .frame(width: 8, height: stemHeight)
                .offset(y: stemHeight / 2 - 10)

            if progress > 0.3 {
                LeafShape()
                    .fill(Color.plantGreenLight)
                    .frame(width: 36 * progress, height: 20 * progress)
                    .rotationEffect(.degrees(-35))
                    .offset(x: -20, y: 20)

                LeafShape()
                    .fill(Color.plantGreen)
                    .frame(width: 32 * progress, height: 18 * progress)
                    .rotationEffect(.degrees(30))
                    .offset(x: 18, y: 40)
            }

            Circle()
                .fill(Color.plantLime)
                .frame(width: 16 + 8 * progress, height: 16 + 8 * progress)
                .offset(y: -stemHeight + 20)
        }
    }

    private func bloomStage(progress: Double, phase: Double) -> some View {
        let trunkHeight: CGFloat = 100 + 60 * progress

        return ZStack {
            TrunkShape(height: trunkHeight)
                .fill(
                    LinearGradient(
                        colors: [Color.plantBrown, Color.plantBrownMid],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: trunkHeight)
                .offset(y: trunkHeight * 0.3)

            ForEach(0..<3, id: \.self) { i in
                let angle: Double = [-25, 20, -15][i]
                let length: CGFloat = [50, 42, 35][i] * progress
                let yOff: CGFloat = [-20, 10, -45][i]

                BranchView(length: length, angle: angle, leafCount: 2 + i, progress: progress)
                    .offset(y: yOff)
            }

            if progress > 0.4 {
                let flowerProgress = (progress - 0.4) / 0.6
                ForEach(0..<6, id: \.self) { i in
                    let offsets: [(CGFloat, CGFloat)] = [(-35, -50), (38, -35), (-25, -85), (30, -75), (-45, -25), (48, -55)]
                    let pos = offsets[i]
                    TreeFlower(progress: flowerProgress, phase: phase)
                        .scaleEffect(1.5)
                        .offset(x: pos.0, y: pos.1)
                }
            }
        }
    }

    private func treeStage(phase: Double) -> some View {
        ZStack {
            TrunkShape(height: 160)
                .fill(
                    LinearGradient(
                        colors: [Color.plantBrownWood, Color.plantBrownDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 28, height: 160)
                .offset(y: 50)

            ForEach(0..<3, id: \.self) { i in
                let sizes: [CGFloat] = [120, 95, 85]
                let offsets: [(CGFloat, CGFloat)] = [(0, -70), (-35, -45), (38, -35)]
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.plantGreen, Color.plantGreenAccent],
                            center: .center,
                            startRadius: 0,
                            endRadius: sizes[i] / 2
                        )
                    )
                    .frame(width: sizes[i], height: sizes[i] * 0.8)
                    .offset(x: offsets[i].0, y: offsets[i].1)
            }

            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * 45
                let radius: CGFloat = 40
                let x = cos(angle * .pi / 180) * radius
                let y = sin(angle * .pi / 180) * radius - 60
                TreeFlower(progress: 1.0, phase: phase)
                    .offset(x: x, y: y)
                    .scaleEffect(1.3)
            }
        }
    }
}
