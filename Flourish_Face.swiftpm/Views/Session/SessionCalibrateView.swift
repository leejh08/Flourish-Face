import SwiftUI

struct SessionCalibrateView: View {
    let calibrationFailed: Bool
    let calibrationCapturing: Bool
    let calibrationProgress: Double
    let peakSmileValue: Float
    let onStartCapture: () -> Void
    let onSkip: () -> Void

    var body: some View {
        Group {
            if calibrationFailed {
                failedContent
                    .transition(.opacity)
            } else if !calibrationCapturing {
                readyContent
                    .transition(.opacity)
            } else {
                capturingContent
            }
        }
    }

    private var failedContent: some View {
        ZStack {
            VStack(spacing: 24) {
                Image(systemName: "face.dashed")
                    .font(.system(size: 70))
                    .foregroundStyle(Color.statusYellow)

                VStack(spacing: 8) {
                    Text("No Smile Detected")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("We couldn't capture your smile.\nTry again or skip to use default settings.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }

            VStack {
                Spacer()

                Button(action: onStartCapture) {
                    Text("Try Again")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.primaryGreen))
                }
                .padding(.horizontal, 24)

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .accessibilityLabel("Skip calibration, use default target")
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }

    private var readyContent: some View {
        ZStack {
            VStack(spacing: 24) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 70))
                    .foregroundStyle(Color.primaryGreen)

                VStack(spacing: 8) {
                    Text("Smile Calibration")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("When you press the button below,\nsmile as wide as you can for 5 seconds.\nWe'll use it to set your personal target.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }

            VStack {
                Spacer()

                Button(action: onStartCapture) {
                    Text("Ready to Smile")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.primaryGreen))
                }
                .accessibilityHint("Tap to begin 5-second smile capture")
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var capturingContent: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                if calibrationProgress == 0 {
                    Text("Get ready to smile!")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                } else {
                    Text("Smile as wide as you can!")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("No smile detected — try smiling wider!")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.statusYellow)
                        .opacity(peakSmileValue < 0.3 && calibrationProgress > 0.3 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: peakSmileValue < 0.3 && calibrationProgress > 0.3)
                }

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primaryGreen)
                        .frame(width: max(0, 200 * calibrationProgress), height: 8)
                        .animation(.linear(duration: 0.1), value: calibrationProgress)
                }
                .frame(width: 200)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
