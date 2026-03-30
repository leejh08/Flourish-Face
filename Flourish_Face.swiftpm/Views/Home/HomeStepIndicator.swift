import SwiftUI

struct HomeStepIndicator: View {
    let exercises: [FaceExercise]
    let todayCompletedExercises: Set<Int>
    let nextExercise: FaceExercise?
    let isTodayComplete: Bool

    @State private var glowOpacity: Double = 0.5
    @State private var floatOffset: CGFloat = 0.0

    var body: some View {
        HStack(spacing: exercises.count > 3 ? 16 : 24) {
            ForEach(Array(exercises.enumerated()), id: \.element.rawValue) { index, exercise in
                let isCompleted = todayCompletedExercises.contains(exercise.rawValue)
                let isCurrent = (nextExercise == exercise) && !isTodayComplete

                let scale: CGFloat = isCurrent ? 1.2 : 0.85
                let circleSize: CGFloat = exercises.count > 3 ? 70 : 90
                let iconSize: CGFloat = exercises.count > 3 ? (isCurrent ? 28 : 22) : (isCurrent ? 38 : 30)

                VStack(spacing: exercises.count > 3 ? 10 : 14) {
                    ZStack {
                        if isCurrent {
                            Circle()
                                .fill(Color.primaryGreen)
                                .frame(width: circleSize + 20, height: circleSize + 20)
                                .blur(radius: 25)
                                .opacity(glowOpacity)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                        glowOpacity = 0.8
                                    }
                                }
                        }

                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: circleSize, height: circleSize)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: fillColors(isCompleted: isCompleted, isCurrent: isCurrent),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .opacity(isCompleted ? 0.8 : (isCurrent ? 0.3 : 0.1))
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.8), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: isCurrent ? 3 : 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: isCurrent ? 12 : 6, x: 0, y: isCurrent ? 10 : 5)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: exercises.count > 3 ? 24 : 32, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                        } else {
                            Image(systemName: exercise.symbolName)
                                .font(.system(size: iconSize))
                                .foregroundStyle(.white)
                                .opacity(isCurrent ? 1.0 : 0.6)
                                .shadow(radius: isCurrent ? 6 : 0)
                        }
                    }
                    .scaleEffect(scale)
                    .offset(y: isCurrent ? floatOffset : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isCurrent)
                    .onAppear {
                        if isCurrent {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                floatOffset = -6
                            }
                        }
                    }

                    Text(exercise.shortName)
                        .font(.system(size: isCurrent ? (exercises.count > 3 ? 14 : 18) : (exercises.count > 3 ? 11 : 14), weight: isCurrent ? .bold : .medium, design: .rounded))
                        .foregroundStyle(isCurrent ? .white : .white.opacity(0.5))
                        .shadow(color: isCurrent ? Color.primaryGreen.opacity(0.5) : .clear, radius: 4)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel({
                    if isCompleted { return "\(exercise.shortName), completed" }
                    if isCurrent { return "\(exercise.shortName), up next" }
                    return "\(exercise.shortName), not yet done"
                }())
            }
        }
        .padding(.vertical, 24)
    }

    private func fillColors(isCompleted: Bool, isCurrent: Bool) -> [Color] {
        if isCompleted {
            return [Color.primaryGreen, Color.greenDeep]
        } else if isCurrent {
            return [Color.primaryGreen.opacity(0.6), Color.primaryGreen.opacity(0.1)]
        } else {
            return [Color.white.opacity(0.1), Color.white.opacity(0.0)]
        }
    }
}
