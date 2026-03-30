import SwiftUI

struct LogStreakCard: View {
    let daysCompletedThisWeek: Int
    let sessions: [GrowthSession]
    let totalSessions: Int
    let flowersEarned: Int

    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private var requiredExerciseCount: Int {
        (Difficulty(rawValue: selectedDifficulty) ?? .basic).exerciseCount
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.accentOrange)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(daysCompletedThisWeek) of 7 days completed")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { weekdayIndex in
                    let date = dateForWeekday(weekdayIndex)
                    let hasSession = hasCompletedAllOnDate(date)
                    let isToday = Calendar.current.isDateInToday(date)
                    let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
                    let dayNumber = Calendar.current.component(.day, from: date)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(hasSession ? Color.accentOrange : .white.opacity(0.1))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .strokeBorder(isToday ? .white : .clear, lineWidth: 2)
                                        .shadow(color: isToday ? .white.opacity(0.5) : .clear, radius: 4)
                                )

                            if hasSession {
                                Text("🌸")
                                    .font(.system(size: 16))
                            } else {
                                Text(dayLabels[weekdayIndex])
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(isToday ? .white : .white.opacity(0.4))
                            }
                        }

                        Text("\(dayNumber)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(isToday ? .white : .white.opacity(0.4))
                    }
                    .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("This week")
            .accessibilityValue({
                let completed = (0..<7).compactMap { i -> String? in
                    let date = dateForWeekday(i)
                    return hasCompletedAllOnDate(date) ? Self.weekdayFormatter.string(from: date) : nil
                }
                let summary = "\(daysCompletedThisWeek) of 7 days completed"
                if completed.isEmpty {
                    return summary
                }
                return "\(summary). \(completed.joined(separator: ", ")) done"
            }())
            .padding(.vertical, 8)

            HStack(spacing: 16) {
                LogStatBox(value: "\(totalSessions)", label: "Sessions", icon: "figure.run")
                LogStatBox(value: "\(flowersEarned)", label: "Flowers", icon: "🌸")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.accentOrange.opacity(0.2), Color.orangeDark.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.accentOrange.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func dateForWeekday(_ weekdayIndex: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentWeekday = calendar.component(.weekday, from: today)
        let daysFromSunday = currentWeekday - 1
        let sunday = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) ?? today
        return calendar.date(byAdding: .day, value: weekdayIndex, to: sunday) ?? today
    }

    private func hasCompletedAllOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let exercisesOnDate = sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }.map { $0.exerciseRaw }

        let uniqueCount = Set(exercisesOnDate).count
        return uniqueCount >= requiredExerciseCount
    }
}
