import Foundation

// module 5 plist model
// settings are small app preferences that are readable in a property list
struct AppSettings: Codable, Equatable {
    var showCancelledBookings: Bool
    var bookingRemindersEnabled: Bool
    var demoNotificationsEnabled: Bool
    var settingsVersion: String

    static let defaults = AppSettings(
        showCancelledBookings: true,
        bookingRemindersEnabled: true,
        demoNotificationsEnabled: true,
        settingsVersion: "2026.06.22"
    )
}
