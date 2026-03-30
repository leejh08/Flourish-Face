import SwiftUI

struct SmallFlower: View {
    let size: CGFloat
    let color: Color
    let phase: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.plantGreen)
                .frame(width: 2, height: size * 0.8)
                .offset(y: size * 0.4)

            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .fill(color)
                    .frame(width: size * 0.4, height: size * 0.6)
                    .offset(y: -size * 0.25)
                    .rotationEffect(.degrees(Double(i) * 72))
            }

            Circle()
                .fill(Color.plantYellowLight)
                .frame(width: size * 0.3, height: size * 0.3)
        }
        .scaleEffect(0.9 + phase * 0.05)
    }
}

struct TreeFlower: View {
    let progress: Double
    let phase: Double

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.plantPinkLight, Color.plantPink],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 10, height: 14)
                    .offset(y: -7)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Circle()
                .fill(Color.plantYellow)
                .frame(width: 7, height: 7)
        }
        .scaleEffect(progress * (0.9 + phase * 0.08))
        .opacity(progress)
    }
}

struct BranchView: View {
    let length: CGFloat
    let angle: Double
    let leafCount: Int
    let progress: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.plantBrown)
                .frame(width: length, height: 5)
                .rotationEffect(.degrees(angle))

            ForEach(0..<leafCount, id: \.self) { i in
                let t = CGFloat(i + 1) / CGFloat(leafCount + 1)
                LeafShape()
                    .fill(i % 2 == 0 ? Color.plantGreenLight : Color.plantGreen)
                    .frame(width: 24 * progress, height: 14 * progress)
                    .offset(
                        x: (t - 0.5) * length * cos(angle * .pi / 180),
                        y: (t - 0.5) * length * sin(angle * .pi / 180) - 14
                    )
            }
        }
    }
}

struct ButterflyView: View {
    let color: Color

    var body: some View {
        ZStack {
            Ellipse()
                .fill(color.opacity(0.8))
                .frame(width: 10, height: 7)
                .offset(x: -5)
            Ellipse()
                .fill(color.opacity(0.8))
                .frame(width: 10, height: 7)
                .offset(x: 5)
            Capsule()
                .fill(Color.plantBrownDark)
                .frame(width: 2, height: 8)
        }
        .scaleEffect(0.7)
    }
}
