import SwiftUI

struct DifficultySelectionPage: View {
    @Binding var selectedDifficulty: String
    var onNext: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(Color.accentBlue)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.5)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Choose your level")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("You can change this later\nin the settings.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .accessibilityElement(children: .combine)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                HStack(spacing: 16) {
                    DifficultyButton(
                        difficulty: .basic,
                        isSelected: selectedDifficulty == Difficulty.basic.rawValue
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            selectedDifficulty = Difficulty.basic.rawValue
                        }
                    }

                    DifficultyButton(
                        difficulty: .advanced,
                        isSelected: selectedDifficulty == Difficulty.advanced.rawValue
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            selectedDifficulty = Difficulty.advanced.rawValue
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
            }

            Spacer()
        }
        .accessibilityAction(named: Text("Next")) {
            onNext?()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? difficulty.iconColor.opacity(0.2)
                            : Color.white.opacity(0.05)
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: difficulty.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(
                            isSelected
                            ? difficulty.iconColor
                            : .white.opacity(0.5)
                        )
                }

                VStack(spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))

                    Text(difficulty.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? difficulty.iconColor.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected ? difficulty.iconColor : .white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .accessibilityLabel("\(difficulty.displayName), \(difficulty.description)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

#Preview {
    DifficultySelectionPage(selectedDifficulty: .constant(Difficulty.basic.rawValue))
        .background(Color.bgPrimary)
}
