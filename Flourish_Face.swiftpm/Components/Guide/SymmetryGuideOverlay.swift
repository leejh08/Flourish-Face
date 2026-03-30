import SwiftUI

struct SymmetryGuideOverlay: View {
    var growthRate: Double
    var holdProgress: Double

    private var lineColor: Color {
        switch growthRate {
        case 0..<0.5:
            return Color.statusRed
        case 0.5..<0.8:
            return Color.statusYellow
        default:
            return Color.mintGreen
        }
    }

    private var lineWidth: CGFloat {
        switch growthRate {
        case 0..<0.5: return 3.0
        case 0.5..<0.8: return 2.5
        default: return 2.0
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .fill(lineColor.opacity(0.7))
                    .frame(width: lineWidth, height: geo.size.height * 0.5)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .shadow(color: lineColor.opacity(0.5), radius: growthRate >= 0.8 ? 8 : 0)

                let centerX = geo.size.width / 2
                let eyeY = geo.size.height * 0.38
                let mouthY = geo.size.height * 0.52

                HStack(spacing: geo.size.width * 0.25) {
                    MarkerDash(color: lineColor)
                    MarkerDash(color: lineColor)
                }
                .position(x: centerX, y: eyeY)

                HStack(spacing: geo.size.width * 0.18) {
                    MarkerDash(color: lineColor)
                    MarkerDash(color: lineColor)
                }
                .position(x: centerX, y: mouthY)

                if holdProgress > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 70, height: 70)

                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 5)
                            .frame(width: 60, height: 60)

                        Circle()
                            .trim(from: 0, to: holdProgress)
                            .stroke(Color.mintGreen, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: Color.mintGreen.opacity(0.6), radius: 8)

                        Text("\(Int(holdProgress * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .position(x: geo.size.width - 55, y: geo.size.height * 0.25)
                    .animation(.linear(duration: 0.1), value: holdProgress)
                }
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.3), value: growthRate)
    }
}
