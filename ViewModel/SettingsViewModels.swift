import Foundation

// module 6 settings viewmodel
// view reads clean text and toggle values instead of touching plist storage
final class SettingsViewModel {
    private let settingsStore: AppSettingsManaging
    private let seatLayoutStore: SeatLayoutStore

    init(
        settingsStore: AppSettingsManaging = AppSettingsStore.shared,
        seatLayoutStore: SeatLayoutStore = .shared
    ) {
        self.settingsStore = settingsStore
        self.seatLayoutStore = seatLayoutStore
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

    var settingsVersionText: String {
        "Settings plist v\(settings.settingsVersion)"
    }

    var settingsPathText: String {
        settingsStore.settingsFilePath
    }

    var seatDatabaseText: String {
        "SeatLayouts.plist v\(seatLayoutStore.databaseVersion) - \(seatLayoutStore.layoutCount) cinema layouts"
    }

    var seatDatabasePathText: String {
        seatLayoutStore.editableFilePath
    }

    func resetSettings() {
        settingsStore.resetToDefaults()
    }
}
