import SwiftUI

struct AffectedSideSelectionPage: View {
    @Binding var selectedSide: AffectedSide
    let onComplete: () -> Void

    @State private var appeared = false

    private var hasSelection: Bool {
        selectedSide != .none
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(Color.accentAmber)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.5)

                VStack(spacing: 8) {
                    Text("Which side is affected?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("We'll mirror your healthy side\nas a guide during exercises.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        SideButton(
                            title: "Left",
                            subtitle: "Full face",
                            isSelected: selectedSide == .left
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                selectedSide = selectedSide == .left ? .none : .left
                            }
                        }

                        SideButton(
                            title: "Right",
                            subtitle: "Full face",
                            isSelected: selectedSide == .right
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                selectedSide = selectedSide == .right ? .none : .right
                            }
                        }
                    }

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedSide = selectedSide == .central ? .none : .central
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if selectedSide == .central {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.primaryGreen)
                            }

                            Text("Lower face only")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(selectedSide == .central ? Color.primaryGreen : .white.opacity(0.5))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedSide == .central ? Color.primaryGreen.opacity(0.15) : .clear)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            selectedSide == .central ? Color.primaryGreen.opacity(0.5) : .white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .accessibilityLabel("Lower face only")
                    .accessibilityHint("Select if only your lower face is affected")
                    .accessibilityAddTraits(selectedSide == .central ? .isSelected : [])
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
            }

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("Get Started")
                    .font(.system(hasSelection ? .title2 : .title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(hasSelection ? .black : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, hasSelection ? 22 : 18)
                    .background(
                        RoundedRectangle(cornerRadius: hasSelection ? 20 : 16)
                            .fill(hasSelection ? Color.primaryGreen : .white.opacity(0.1))
                    )
            }
            .disabled(!hasSelection)
            .accessibilityHint(hasSelection ? "" : "Select an affected side first")
            .scaleEffect(hasSelection ? 1.0 : 0.95)
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: hasSelection)
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
