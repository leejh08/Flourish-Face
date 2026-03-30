import SwiftUI

struct SessionTrackingView: View {
    let manager: FaceTrackingManager
    let exercise: FaceExercise
    let showTrackingSkip: Bool
    let onSkipSet: () -> Void
    let onGoBack: () -> Void

    private var scoreColor: Color {
        switch manager.growthRate {
        case 0..<0.3: return Color.statusRed
        case 0.3..<0.5: return Color.statusYellow
        default: return Color.mintGreen
        }
    }

    private var scoreLabel: String {
        if manager.holdProgress > 0 {
            return "Hold it! \(String(format: "%.1f", manager.aboveThresholdDuration))s"
        }
        switch manager.growthRate {
        case 0..<0.3: return "Keep going..."
        case 0.3..<0.5: return "Almost there!"
        default: return "Hold that pose!"
        }
    }

    var body: some View {
        ZStack {
            if ARFaceView.isFaceTrackingSupported {
                trackingOverlay
            } else {
                unsupportedDeviceOverlay
            }
        }
    }

    private var trackingOverlay: some View {
        ZStack {
            SymmetryGuideOverlay(
                growthRate: manager.growthRate,
                holdProgress: manager.holdProgress
            )
            .ignoresSafeArea()

            VStack {
                HStack(spacing: 12) {
                    Button(action: onGoBack) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.8))
                            .shadow(radius: 4)
                    }
                    .accessibilityLabel("Close session")

                    HStack(spacing: 8) {
                        Image(systemName: exercise.symbolName)
                            .font(.system(size: 24))
                            .foregroundStyle(.white)

                        Text(exercise.guide)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("Set \(manager.currentSet)/\(manager.totalSets)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.mintGreen.opacity(0.3)))
                        .accessibilityLabel("Set \(manager.currentSet) of \(manager.totalSets)")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Text("\(Int(manager.growthRate * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.1), value: Int(manager.growthRate * 100))
                        .accessibilityLabel("Growth rate, \(Int(manager.growthRate * 100)) percent")

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.2))
                            .frame(width: 160, height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(scoreColor)
                            .frame(width: 160 * manager.holdProgress, height: 6)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Hold timer")
                    .accessibilityValue("\(String(format: "%.1f", manager.aboveThresholdDuration)) of \(Int(TrackingConfig.holdRequired)) seconds")

                    Text(scoreLabel)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .padding(.bottom, showTrackingSkip ? 16 : 40)

                if showTrackingSkip {
                    Button(action: onSkipSet) {
                        Text("Skip this set")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .accessibilityHint("Tap to skip the current set")
                    .padding(.bottom, 24)
                    .transition(.opacity)
                }
            }
        }
    }

    private var unsupportedDeviceOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "faceid")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.6))

                Text("Face Tracking Not Available")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("This device doesn't support Face Tracking.\nPlease use an iPad with TrueDepth camera.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onGoBack) {
                Text("Go Back")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.primaryGreen))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
