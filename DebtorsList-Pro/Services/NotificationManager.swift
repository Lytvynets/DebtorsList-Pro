

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }


    func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }


    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    
    func scheduleDueDateReminder(for debtor: Debtor) async {
        guard let dueDate = debtor.dueDate else { return }
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Debt reminder"
        content.body = "\(debtor.name)'s debt is due today."
        content.sound = .default

        let startOfDueDay = Calendar.current.startOfDay(for: dueDate)
        let triggerDate = Calendar.current.date(byAdding: .hour, value: 9, to: startOfDueDay) ?? dueDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "due-\(debtor.id)", content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    
    func cancelDueDateReminder(for debtor: Debtor) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["due-\(debtor.id)"])
    }


    func scheduleWeeklyReminder(weekday: Int, hour: Int, minute: Int = 0) async {
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Debtors List Pro"
        content.body = "Check in on your debts for the week."
        content.sound = .default

        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-reminder", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-reminder"])
        try? await center.add(request)
    }
}
