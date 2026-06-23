import Foundation

struct SettingsChangelogEntry {
    let day: String
    let title: String
    let details: String
}

// module 6 settings viewmodel
// view reads clean text and toggle values instead of touching plist storage
final class SettingsViewModel {
    private let settingsStore: AppSettingsManaging
    private let clearBookingsUseCase: ClearBookingsUseCase

    init(
        settingsStore: AppSettingsManaging = AppSettingsStore.shared,
        clearBookingsUseCase: ClearBookingsUseCase = DefaultClearBookingsUseCase(bookingManager: BookingStore.shared)
    ) {
        self.settingsStore = settingsStore
        self.clearBookingsUseCase = clearBookingsUseCase
    }

    var settings: AppSettings {
        settingsStore.settings
    }

    var settingsDidChangeNotification: Notification.Name {
        settingsStore.didChangeNotification
    }

    var showCancelledBookings: Bool {
        get { settings.showCancelledBookings }
        set {
            var updatedSettings = settings
            updatedSettings.showCancelledBookings = newValue
            settingsStore.updateSettings(updatedSettings)
        }
    }

    var bookingRemindersEnabled: Bool {
        get { settings.bookingRemindersEnabled }
        set {
            var updatedSettings = settings
            updatedSettings.bookingRemindersEnabled = newValue
            settingsStore.updateSettings(updatedSettings)
        }
    }

    var demoNotificationsEnabled: Bool {
        get { settings.demoNotificationsEnabled }
        set {
            var updatedSettings = settings
            updatedSettings.demoNotificationsEnabled = newValue
            settingsStore.updateSettings(updatedSettings)
        }
    }

    var changelogEntries: [SettingsChangelogEntry] {
        [
            SettingsChangelogEntry(
                day: "June 15, 2026 (Monday)",
                title: "Initial setup and UIKit/MVVM structure",
                details: "Created the project, storyboard tabs, Models/View/ViewModel folders, outlet/action connections, table views, reusable cells, and the first Movies, Bookings, and Profile flows"
            ),
            SettingsChangelogEntry(
                day: "June 17, 2026 (Wednesday)",
                title: "Booking flow",
                details: "Added movie detail, assigned showings, peso pricing, seat selection, booking summary, and confirmation flow"
            ),
            SettingsChangelogEntry(
                day: "June 17, 2026 (Wednesday)",
                title: "Profile and account flow",
                details: "Added account creation, login, logout, profile editing, session restore, validation rules, duplicate email checks, and Keychain password storage"
            ),
            SettingsChangelogEntry(
                day: "June 17, 2026 (Wednesday)",
                title: "Data persistence",
                details: "Added FileManager-backed JSON persistence for profiles and bookings, separated reader/writer helpers, moved sample data into JSON, and kept poster images available offline"
            ),
            SettingsChangelogEntry(
                day: "June 19, 2026 (Friday)",
                title: "Movie data and posters",
                details: "Expanded to real movie names, ratings, categories, schedules, offline posters, URL/cache fallback image loading, and rating sort controls"
            ),
            SettingsChangelogEntry(
                day: "June 19, 2026 (Friday)",
                title: "Cinema rules and seating",
                details: "Changed booking to predetermined showings, added eight cinemas, standard/VIP pricing, varied seat layouts, reserved/unavailable seats, and booking detail seat maps"
            ),
            SettingsChangelogEntry(
                day: "June 22, 2026 (Monday)",
                title: "Schedules and local reminders",
                details: "Changed schedules into nested date/time structs, extended booking dates to one week, added multiple daily showtimes, current date labels, and local reminder notifications without APNs"
            ),
            SettingsChangelogEntry(
                day: "June 22, 2026 (Monday)",
                title: "Architecture cleanup",
                details: "Separated presentation, domain, design, model, and persistence layers, then added protocol-based dependency injection, use cases, AppFactory, DTOs, and mappers"
            ),
            SettingsChangelogEntry(
                day: "June 23, 2026 (Tuesday)",
                title: "Plist settings and seat database",
                details: "Added plist-backed settings, Settings menu, plist-backed seat layouts, shared UI constants, updated comments, and extra tests"
            ),
            SettingsChangelogEntry(
                day: "June 23, 2026 (Tuesday)",
                title: "Demo reset and UI polish",
                details: "Hid technical file paths, increased small font sizes proportionally, fixed compiler warnings, made confirmed booking seats reserved for the same showing, and added Clear Demo Bookings"
            )
        ]
    }

    func resetSettings() {
        settingsStore.resetToDefaults()
    }

    @discardableResult
    func clearDemoBookings() -> Int {
        clearBookingsUseCase.execute()
    }
}
