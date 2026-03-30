import SwiftUI

struct ExercisePickerSheet: View {
    let exercises: [FaceExercise]
    let onSelect: (FaceExercise) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Extra Practice")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Which exercise would you like to practice?")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(exercises, id: \.rawValue) { exercise in
                    Button {
                        onSelect(exercise)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: exercise.symbolName)
                                .font(.system(size: 28))
                                .foregroundStyle(.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.shortName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text(exercise.guide)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .padding(.top, 16)
    }
}
