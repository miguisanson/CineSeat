import Foundation
import UserNotifications

// local notification service
// this is local only and does not use remote push notifications
final class LocalNotificationService: BookingNotificationScheduling {
    static let shared = LocalNotificationService()

    private let center: UNUserNotificationCenter
    private let settingsStore: AppSettingsManaging

    init(
        center: UNUserNotificationCenter = .current(),
        settingsStore: AppSettingsManaging = AppSettingsStore.shared
    ) {
        self.center = center
        self.settingsStore = settingsStore
    }

    func scheduleReminders(for booking: Booking) {
        guard settingsStore.settings.bookingRemindersEnabled else { return }
        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else { return }
            self?.addReminderRequests(for: booking)
        }
    }

    func cancelReminders(for bookingID: String) {
        let identifiers = AppConstants.Notifications.reminderLeadTimes.map {
            reminderIdentifier(bookingID: bookingID, leadTime: $0)
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func scheduleCancellationNotice(for booking: Booking, reason: BookingCancellationReason) {
        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else { return }
            self?.addCancellationNotice(for: booking, reason: reason)
        }
    }

    func scheduleDemoReminder(
        for booking: Booking,
        delay: TimeInterval = AppConstants.Notifications.demoDelay,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        guard settingsStore.settings.demoNotificationsEnabled else {
            completion(false)
            return
        }
        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else {
                completion(false)
                return
            }
            self?.addDemoReminder(for: booking, delay: delay, completion: completion)
        }
    }

    private func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                self?.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            case .denied:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func addReminderRequests(for booking: Booking) {
        for leadTime in AppConstants.Notifications.reminderLeadTimes {
            let fireDate = booking.startsAt.addingTimeInterval(-leadTime)
            guard fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "CineSeat reminder"
            content.body = "\(booking.title) starts in \(leadTimeText(leadTime)) at \(booking.showtime)."
            content.sound = .default

            let components = CineSeatDateFormatters.calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: reminderIdentifier(bookingID: booking.id, leadTime: leadTime),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    private func addCancellationNotice(for booking: Booking, reason: BookingCancellationReason) {
        let content = UNMutableNotificationContent()
        content.title = "Booking cancelled"
        content.body = "\(booking.title) was cancelled due to \(reason.notificationText)."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(AppConstants.Notifications.cancellationIdentifierPrefix)\(booking.id)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        center.add(request)
    }

    private func addDemoReminder(
        for booking: Booking,
        delay: TimeInterval,
        completion: @escaping (Bool) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = "CineSeat reminder"
        content.body = "Demo: \(booking.title) starts at \(booking.showtime) in \(booking.locationName)."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(AppConstants.Notifications.demoIdentifierPrefix)\(booking.id)-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        )
        center.add(request) { error in
            completion(error == nil)
        }
    }

    private func reminderIdentifier(bookingID: String, leadTime: TimeInterval) -> String {
        "\(AppConstants.Notifications.reminderIdentifierPrefix)\(bookingID)-\(Int(leadTime))"
    }

    private func leadTimeText(_ leadTime: TimeInterval) -> String {
        switch Int(leadTime) {
        case 10_800:
            return "3 hours"
        case 7_200:
            return "2 hours"
        case 3_600:
            return "1 hour"
        case 1_800:
            return "30 minutes"
        default:
            return "\(Int(leadTime / 60)) minutes"
        }
    }
}
