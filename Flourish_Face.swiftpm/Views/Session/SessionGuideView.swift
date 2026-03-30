import SwiftUI

struct SessionGuideView: View {
    let exercise: FaceExercise
    let guideIconScale: CGFloat
    let guideTextOpacity: Double
    let pulseOpacity: Double

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: exercise.symbolName)
                .font(.system(size: 60))
                .foregroundStyle(.white)
                .scaleEffect(guideIconScale)

            VStack(spacing: 12) {
                Text(exercise.guide)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(exercise.tip)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(guideTextOpacity)

            Text("Starting soon...")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(pulseOpacity))
                .padding(.top, 20)
        }
        .padding(.horizontal, 32)
    }
}
