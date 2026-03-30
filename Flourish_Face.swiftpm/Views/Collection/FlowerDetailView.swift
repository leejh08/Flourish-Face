import SwiftUI

struct FlowerDetailView: View {
    let flower: Flower

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 24) {
                Text(flower.type.emoji)
                    .font(.system(size: 80))

                VStack(spacing: 8) {
                    Text(flower.type.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Earned on \(flower.earnedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}
