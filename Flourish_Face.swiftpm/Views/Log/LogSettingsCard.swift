import SwiftUI

struct LogSettingsCard: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue
    @AppStorage(AppStorageKeys.affectedSide) private var affectedSide: AffectedSide = .none
    @AppStorage(AppStorageKeys.todayCompletedExercisesData) private var todayCompletedExercisesData: String = ""
    @AppStorage(AppStorageKeys.lastExerciseDate) private var lastExerciseDate: String = ""
    @AppStorage(AppStorageKeys.totalGrowthPoints) private var totalGrowthPoints: Double = 0
    @AppStorage(AppStorageKeys.flowersEarned) private var flowersEarned: Int = 0
    @AppStorage(AppStorageKeys.pendingFlowerPick) private var pendingFlowerPick: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedIntro) private var hasCompletedIntro: Bool = false

    @State private var showResetAlert = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.accentBlue)

                Text("Preferences")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()
            }

            VStack(spacing: 0) {
                settingRow(
                    title: "Difficulty",
                    subtitle: "Daily workout intensity",
                    icon: "gauge.with.needle",
                    iconColor: .primaryGreen,
                    content: AnyView(
                        Menu {
                            ForEach(Difficulty.allCases, id: \.self) { diff in
                                Button {
                                    selectedDifficulty = diff.rawValue
                                } label: {
                                    HStack {
                                        Text(diff.displayName)
                                        if selectedDifficulty == diff.rawValue {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(Difficulty(rawValue: selectedDifficulty)?.displayName ?? "Basic")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(Color.primaryGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.primaryGreen.opacity(0.15)))
                        }
                    )
                )

                Divider().background(.white.opacity(0.1)).padding(.vertical, 10)

                settingRow(
                    title: "Affected Side",
                    subtitle: "Facial guide setting",
                    icon: "face.dashed",
                    iconColor: .accentAmber,
                    content: AnyView(
                        Menu {
                            Button { affectedSide = .left } label: {
                                HStack {
                                    Text("Left Side")
                                    if affectedSide == .left { Image(systemName: "checkmark") }
                                }
                            }
                            Button { affectedSide = .right } label: {
                                HStack {
                                    Text("Right Side")
                                    if affectedSide == .right { Image(systemName: "checkmark") }
                                }
                            }
                            Button { affectedSide = .central } label: {
                                HStack {
                                    Text("Lower Face")
                                    if affectedSide == .central { Image(systemName: "checkmark") }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(sideDisplayName(affectedSide))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(Color.accentAmber)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.accentAmber.opacity(0.15)))
                        }
                    )
                )

                Divider().background(.white.opacity(0.1)).padding(.vertical, 10)

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Danger Zone")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.red.opacity(0.9))

                        Text("Reset everything")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()

                    Button {
                        showResetAlert = true
                    } label: {
                        Text("Reset")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Capsule().stroke(.red.opacity(0.4), lineWidth: 1.5))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Reset all data")
                .accessibilityHint("Permanently deletes all sessions, flowers, and settings")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.04))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset Everything", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your sessions, flowers, and settings will be permanently deleted. This cannot be undone.")
        }
    }

    private func settingRow(title: String, subtitle: String, icon: String, iconColor: Color, content: AnyView) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            content
        }
        .accessibilityElement(children: .combine)
    }

    private func sideDisplayName(_ side: AffectedSide) -> String {
        switch side {
        case .left: return String(localized: "Left")
        case .right: return String(localized: "Right")
        case .central: return String(localized: "Lower")
        case .none: return String(localized: "None")
        }
    }

    private func resetAllData() {
        todayCompletedExercisesData = ""
        lastExerciseDate = ""
        totalGrowthPoints = 0
        flowersEarned = 0
        pendingFlowerPick = false
        hasCompletedOnboarding = false
        hasCompletedIntro = false
        affectedSide = .none
        selectedDifficulty = Difficulty.basic.rawValue
        try? modelContext.delete(model: Flower.self)

        do {
            try modelContext.delete(model: GrowthSession.self)
        } catch { }
    }
}
