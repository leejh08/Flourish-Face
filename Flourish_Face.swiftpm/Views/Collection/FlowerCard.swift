import SwiftUI

struct FlowerCard: View {
    let flower: Flower
    var count: Int = 1
    var isNew: Bool = false

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowing: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Text(flower.type.emoji)
                    .font(.system(size: 38))

                if count > 1 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(Circle().fill(flower.type.color))
                        .offset(x: 10, y: -10)
                }
            }

            Text(flower.type.name)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(flower.type.color.opacity(glowing ? 0.3 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(flower.type.color.opacity(glowing ? 0.8 : 0.3), lineWidth: glowing ? 2 : 1)
                )
        )
        .scaleEffect(pulseScale)
        .shadow(color: glowing ? flower.type.color.opacity(0.5) : .clear, radius: 12)
        .onAppear {
            guard isNew else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45).repeatCount(3, autoreverses: true)) {
                pulseScale = 1.1
            }
            withAnimation(.easeInOut(duration: 0.4).repeatCount(4, autoreverses: true)) {
                glowing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Delay.flowerCardAnimation) {
                withAnimation(.easeOut(duration: 0.3)) {
                    pulseScale = 1.0
                    glowing = false
                }
            }
        }
    }
}
