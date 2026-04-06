import SwiftUI

struct RestView: View {
    let chapter: Chapter
    let exercise: FaceExercise
    let growthPoints: Double
    let duration: TimeInterval
    let completedExerciseCount: Int
    let totalExercises: Int
    let isDayComplete: Bool
    var isBonus: Bool = false
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var flowerBounce = false

    @State private var bonusSymbolName: String = "hand.raised.fill"
    @State private var bonusTitleValue: String = "Great Job!"
    @State private var bonusMessageValue: String = "Keep going!"

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    if isBonus {
                        bonusCompletionContent
                    } else if isDayComplete {
                        dayCompleteContent
                    } else {
                        normalCompletionContent
                    }
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 10) {
                        if isDayComplete && !isBonus {
                            Text("🌸")
                            Text("Pick Your Flower")
                        } else {
                            Text("Done")
                        }
                    }
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(isDayComplete && !isBonus ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(buttonGradient)
                    )
                }
                .accessibilityLabel(isDayComplete && !isBonus ? "Pick your flower reward" : "Done, return to home")
                .opacity(showContent ? 1 : 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if isBonus {
                setupBonusContent()
            }

            withAnimation(.spring(duration: 0.8, bounce: 0.4).delay(0.2)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                showContent = true
            }
            if isDayComplete && !isBonus {
                flowerBounce = true
            }
        }
    }

    private var bonusCompletionContent: some View {
        VStack(spacing: 24) {
            Image(systemName: bonusSymbolName)
                .font(.system(size: 60))
                .foregroundStyle(.white)
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

            VStack(spacing: 12) {
                Text(bonusTitleValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(bonusMessageValue)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(showContent ? 1 : 0)

            HStack(spacing: 12) {
                Image(systemName: exercise.symbolName)
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))

                Text(exercise.shortName)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.white.opacity(0.1))
            )
            .opacity(showContent ? 1 : 0)
        }
    }

    private func setupBonusContent() {
        let symbols = ["hand.raised.fill", "star.fill", "sparkles", "hands.clap.fill", "star.circle.fill", "rainbow"]
        let titles = [
            String(localized: "Amazing Effort!"),
            String(localized: "You're Dedicated!"),
            String(localized: "Keep It Up!"),
            String(localized: "Wonderful!"),
            String(localized: "So Proud of You!")
        ]
        let messages = [
            String(localized: "Extra practice shows real commitment.\nYour dedication will pay off."),
            String(localized: "Every extra effort counts.\nYou're doing great!"),
            String(localized: "Going the extra mile!\nYour muscles will thank you."),
            String(localized: "Practice makes progress.\nYou're on the right path."),
            String(localized: "Taking care of yourself is a gift.\nKeep believing in your journey.")
        ]

        bonusSymbolName = symbols.randomElement() ?? "hand.raised.fill"
        bonusTitleValue = titles.randomElement() ?? String(localized: "Great Job!")
        bonusMessageValue = messages.randomElement() ?? String(localized: "Keep going!")
    }

    private var dayCompleteContent: some View {
        VStack(spacing: 20) {
            Text("🌸")
                .font(.system(size: 70))
                .scaleEffect(flowerBounce ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: flowerBounce)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("You earned a flower!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Choose your flower\nwhen you return home")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
        }
        .scaleEffect(titleScale)
        .opacity(titleOpacity)
    }

    private var normalCompletionContent: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.primaryGreen.opacity(0.2))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.primaryGreen)
            }
            .scaleEffect(titleScale)
            .opacity(titleOpacity)
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Great Job!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(totalExercises - completedExerciseCount) more to earn a flower")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .accessibilityElement(children: .combine)
            .opacity(showContent ? 1 : 0)
        }
    }

    private var backgroundColors: [Color] {
        if isBonus {
            return [Color.bgNavy, Color.bgPrimary]
        } else if isDayComplete {
            return [Color.bgIndigo, Color.bgDarkBlue]
        } else {
            return [Color.bgPrimary, Color.bgSecondary]
        }
    }

    private var buttonGradient: LinearGradient {
        if isDayComplete && !isBonus {
            return LinearGradient(colors: [Color.accentPink, Color.accentPurple], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color.primaryGreen, Color.primaryGreen], startPoint: .leading, endPoint: .trailing)
        }
    }
}
