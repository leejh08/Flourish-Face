import SwiftUI

struct SideButton: View {
    let title: String
    var subtitle: String = ""
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 70, height: 70)

                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(title == "Left" && isSelected
                                  ? Color.accentPink
                                  : .white.opacity(0.3))
                            .frame(width: 14, height: 28)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(title == "Right" && isSelected
                                  ? Color.accentPink
                                  : .white.opacity(0.3))
                            .frame(width: 14, height: 28)
                    }

                    Circle()
                        .strokeBorder(Color.primaryGreen, lineWidth: 3)
                        .frame(width: 70, height: 70)
                        .scaleEffect(isSelected ? 1.0 : 0.8)
                        .opacity(isSelected ? 1 : 0)

                    if isSelected {
                        Circle()
                            .fill(Color.primaryGreen)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.black)
                            )
                            .offset(x: 26, y: -26)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(isSelected ? Color.primaryGreen : .white.opacity(0.7))

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.primaryGreen.opacity(0.15) : .white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected ? Color.primaryGreen.opacity(0.5) : .white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .accessibilityLabel(String(format: String(localized: "%@ side affected"), String(localized: String.LocalizationValue(title))))
        .accessibilityHint(String(format: String(localized: "Select if the %@ side of your face is affected"), String(localized: String.LocalizationValue(title.lowercased()))))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}
