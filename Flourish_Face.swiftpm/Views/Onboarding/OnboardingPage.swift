import SwiftUI

struct OnboardingPage: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    @State private var appeared = false
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(iconColor)
                .scaleEffect(iconScale)
                .opacity(appeared ? 1 : 0)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Text(subtitle)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
            }
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
            iconScale = 0.5
        }
    }
}
