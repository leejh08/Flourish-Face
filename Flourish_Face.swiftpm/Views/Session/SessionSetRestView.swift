import SwiftUI

struct SessionSetRestView: View {
    let currentSet: Int
    let totalSets: Int

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.mintGreen)

            Text("Set \(currentSet) Complete!")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                ForEach(1...totalSets, id: \.self) { set in
                    Circle()
                        .fill(set <= currentSet ? Color.mintGreen : .white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }

            Text("Take a short break...")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
