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
                title: "Booking, profile, and persistence",
                details: "Added movie detail, assigned showings, peso pricing, seat selection, confirmation, account creation/login/logout/editing, session restore, validation, Keychain passwords, and FileManager JSON persistence"
            ),
            SettingsChangelogEntry(
                day: "June 19, 2026 (Friday)",
                title: "Movie data, posters, cinema rules, and seating",
                details: "Expanded real movie data, ratings, schedules, offline posters, URL/cache fallback images, rating sort, predetermined showings, eight cinemas, standard/VIP pricing, varied seat layouts, and booking detail seat maps"
            ),
            SettingsChangelogEntry(
                day: "June 22, 2026 (Monday)",
                title: "Schedule, notifications, and architecture cleanup",
                details: "Added nested schedules, one-week dates, multiple showtimes, current date labels, local reminders without APNs, Clean Architecture folders, protocol DI, use cases, AppFactory, DTOs, and mappers"
            ),
            SettingsChangelogEntry(
                day: "June 23, 2026 (Tuesday)",
                title: "Plist settings, seat database, and UI polish",
                details: "Added plist settings, Settings menu, plist-backed seat layouts, shared UI constants, comments, tests, hidden technical paths, larger small fonts, warning fixes, reserved confirmed seats, and Clear Demo Bookings"
            ),
            SettingsChangelogEntry(
                day: "June 24, 2026 (Wednesday)",
                title: "Showings expansion, map, sharing, and launch cleanup",
                details: "Renamed Movies tab to Showings, added Movies/Concerts/Seminars selection, added event JSON and event browsing screens, added Locations MapKit pins and zoom buttons, added ticket sharing, cleared starter bookings, and kept runtime data in device storage"
            ),
            SettingsChangelogEntry(
                day: "June 25, 2026 (Thursday)",
                title: "Interactive cinema pins and showtime shortcuts",
                details: "Added MapKit pin callout info buttons, a Cinema Details screen, assigned cinema schedules, grouped showtimes by movie and date, added tappable showtime chips that open movie detail with the date and time preselected, made movie detail list all showtimes instead of three fixed buttons, restored the stock Apple Maps red pin, and kept assigned-cinema-only booking"
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
