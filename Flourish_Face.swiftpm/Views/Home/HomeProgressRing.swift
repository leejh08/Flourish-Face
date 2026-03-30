import SwiftUI

struct HomeProgressRing: View {
    let todayCompletedExercisesCount: Int
    let totalExercises: Int
    let currentChapter: Chapter

    private var progress: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(todayCompletedExercisesCount) / Double(totalExercises)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.greenDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: todayCompletedExercisesCount)

            VStack(spacing: 4) {
                Image(systemName: currentChapter.symbolName)
                    .font(.system(size: 48))
                    .foregroundStyle(Color.primaryGreen)
                    .padding(.bottom, 4)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(todayCompletedExercisesCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/ \(totalExercises)")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's progress, \(todayCompletedExercisesCount) of \(totalExercises) exercises complete")
    }
}
