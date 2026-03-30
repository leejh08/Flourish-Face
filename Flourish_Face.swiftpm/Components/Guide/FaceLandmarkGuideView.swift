import SwiftUI

struct FaceLandmarkGuideView: View {
    let affectedSide: AffectedSide
    let leftMouthCorner: CGPoint
    let rightMouthCorner: CGPoint
    let targetMouthCorner: CGPoint
    let progress: Double
    let screenCenterX: CGFloat

    private var targetColor: Color {
        if progress >= 0.8 {
            return Color.mintGreen
        } else if progress >= 0.5 {
            return Color.statusYellow
        } else {
            return Color.statusRedLight
        }
    }

    private var currentCorner: CGPoint {
        affectedSide == .left ? rightMouthCorner : leftMouthCorner
    }

    private var hasValidPositions: Bool {
        leftMouthCorner != .zero && rightMouthCorner != .zero && targetMouthCorner != .zero
    }

    var body: some View {
        ZStack {
            if hasValidPositions {
                let centerMouthPoint = CGPoint(
                    x: screenCenterX,
                    y: (leftMouthCorner.y + rightMouthCorner.y) / 2
                )

                Path { path in
                    path.move(to: centerMouthPoint)
                    path.addLine(to: targetMouthCorner)
                }
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .foregroundColor(targetColor.opacity(0.6))

                ZStack {
                    Circle()
                        .stroke(targetColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 32, height: 32)

                    Circle()
                        .stroke(targetColor, lineWidth: 2.5)
                        .frame(width: 24, height: 24)

                    if progress >= 0.7 {
                        Circle()
                            .fill(targetColor.opacity(0.4))
                            .frame(width: 16, height: 16)
                    }

                    Text("Reach here")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(targetColor)
                        .padding(4)
                        .background(Color.black.opacity(0.6).cornerRadius(4))
                        .offset(y: -24)
                }
                .shadow(color: targetColor.opacity(0.5), radius: 8)
                .position(targetMouthCorner)

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(targetColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                    .position(
                        x: targetMouthCorner.x,
                        y: targetMouthCorner.y + 24
                    )
            }
        }
        .animation(.easeOut(duration: 0.08), value: leftMouthCorner.x)
        .animation(.easeOut(duration: 0.08), value: rightMouthCorner.x)
        .animation(.easeOut(duration: 0.08), value: targetMouthCorner.x)
    }
}
