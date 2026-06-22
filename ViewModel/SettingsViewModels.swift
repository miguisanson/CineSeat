import Foundation

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

    func resetSettings() {
        settingsStore.resetToDefaults()
    }

    @discardableResult
    func clearDemoBookings() -> Int {
        clearBookingsUseCase.execute()
    }
}
