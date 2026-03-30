import SwiftUI

struct LogStatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            if icon.count <= 2 {
                Text(icon)
                    .font(.system(size: 22))
                    .accessibilityHidden(true)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryGreen)
                    .accessibilityHidden(true)
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}
