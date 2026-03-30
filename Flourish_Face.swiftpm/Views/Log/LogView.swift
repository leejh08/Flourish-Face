import SwiftUI
import SwiftData

struct LogView: View {
    @Query(sort: \GrowthSession.date, order: .forward) private var sessions: [GrowthSession]
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.flowersEarned) private var flowersEarned: Int = 0
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue

    @State private var appeared = false

    private var daysCompletedThisWeek: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentWeekday = calendar.component(.weekday, from: today)
        let daysFromSunday = currentWeekday - 1
        let weekStart = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) ?? today
        return daysCompletedInWeek(startingSunday: weekStart)
    }

    private func daysCompletedInWeek(startingSunday sunday: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: sunday) ?? sunday
            let exercisesOnDate = sessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: date)
            }.map { $0.exerciseRaw }
            let uniqueCount = Set(exercisesOnDate).count
            let required = (Difficulty(rawValue: selectedDifficulty) ?? .basic).exerciseCount
            if uniqueCount >= required {
                count += 1
            }
        }
        return count
    }

    var body: some View {
        ZStack {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerView
                        .padding(.top, 16)

                    LogStreakCard(
                        daysCompletedThisWeek: daysCompletedThisWeek,
                        sessions: sessions,
                        totalSessions: sessions.count,
                        flowersEarned: flowersEarned
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    LogSettingsCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [Color.bgPrimary, Color.bgSecondary, Color.bgPrimary],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(sessions.count) sessions completed")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
    }
}
