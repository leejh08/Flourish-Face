import SwiftUI

struct SessionIntroView: View {
    let exercise: FaceExercise
    let totalSets: Int
    let introScale: CGFloat
    let introTextOpacity: Double
    let onStart: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Image(systemName: exercise.symbolName)
                    .font(.system(size: 70))
                    .foregroundStyle(Color.primaryGreen)
                    .scaleEffect(introScale)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("\(totalSets) Sets")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Hold each expression for 4 seconds")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .accessibilityElement(children: .combine)
                .opacity(introTextOpacity)
            }

            VStack {
                Spacer()

                Button(action: onStart) {
                    Text("Start")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.primaryGreen)
                        )
                }
                .opacity(introTextOpacity)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
