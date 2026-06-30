import Foundation

// developer-only settings and reset actions
// normal app screens do not expose these controls
final class DeveloperModeViewModel {
    private let settingsStore: AppSettingsManaging
    private let clearBookingsUseCase: ClearBookingsUseCase
    private let manageReviewsUseCase: ManageReviewsUseCase
    private let notificationScheduler: BookingNotificationScheduling

    init(
        settingsStore: AppSettingsManaging,
        clearBookingsUseCase: ClearBookingsUseCase,
        manageReviewsUseCase: ManageReviewsUseCase,
        notificationScheduler: BookingNotificationScheduling
    ) {
        self.settingsStore = settingsStore
        self.clearBookingsUseCase = clearBookingsUseCase
        self.manageReviewsUseCase = manageReviewsUseCase
        self.notificationScheduler = notificationScheduler
    }

    var settingsDidChangeNotification: Notification.Name { settingsStore.didChangeNotification }

    var developerModeEnabled: Bool {
        get { settingsStore.settings.developerModeEnabled }
        set {
            var settings = settingsStore.settings
            settings.developerModeEnabled = newValue
            if !newValue {
                settings.simulateReviewEligibility = false
                settings.testNotificationsEnabled = false
            }
            settingsStore.updateSettings(settings)
        }
    }

    var simulateReviewEligibility: Bool {
        get { settingsStore.settings.simulateReviewEligibility }
        set {
            var settings = settingsStore.settings
            settings.simulateReviewEligibility = developerModeEnabled && newValue
            settingsStore.updateSettings(settings)
        }
    }

    var testNotificationsEnabled: Bool {
        get { settingsStore.settings.testNotificationsEnabled }
        set {
            var settings = settingsStore.settings
            settings.testNotificationsEnabled = developerModeEnabled && newValue
            settingsStore.updateSettings(settings)
        }
    }

    @discardableResult
    func clearBookings() -> Int {
        clearBookingsUseCase.execute()
    }

    @discardableResult
    func clearReviews() -> Int {
        manageReviewsUseCase.clearAll()
    }

    func scheduleTestNotification(completion: @escaping (Bool) -> Void) {
        notificationScheduler.scheduleDeveloperTestNotification(completion: completion)
    }
}
