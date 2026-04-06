import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let reminderID = "daily_streak_reminder"

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // Call when app opens and today's exercises are NOT complete.
    // Schedules a daily repeating 8 PM reminder (idempotent — safe to call multiple times).
    func scheduleStreakReminder() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            // Avoid duplicates
            center.getPendingNotificationRequests { pending in
                guard !pending.contains(where: { $0.identifier == self.reminderID }) else { return }

                let content = UNMutableNotificationContent()
                content.title = String(localized: "Don't forget to exercise today! 🌸")
                content.body = String(localized: "Keep your streak going — exercise now.")
                content.sound = .default

                var components = DateComponents()
                components.hour = 20
                components.minute = 0

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: self.reminderID,
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }

    // Call when today's exercises are all complete.
    // Cancels the pending reminder — it gets rescheduled next time the app opens on a new day.
    func cancelStreakReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminderID])
    }

    // Call on full data reset.
    func cancelAll() {
        cancelStreakReminder()
    }
}
