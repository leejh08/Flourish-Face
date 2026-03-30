import SwiftUI

struct FlowerOptionCard: View {
    let flower: FlowerType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(flower.emoji)
                .font(.system(size: 44))
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .accessibilityHidden(true)

            Text(flower.name)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected
                    ? flower.color.opacity(0.3)
                    : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(isSelected
                            ? flower.color
                            : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
