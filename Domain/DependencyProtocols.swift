import Foundation

// module 6 domain contracts
// protocol-based di keeps viewmodels away from concrete stores and api clients
protocol MovieFetching {
    func fetchMovies() -> [Movie]
}

protocol AppPreferencesManaging: AnyObject {
    var hasLaunchedBefore: Bool { get set }
    var selectedMovieCategory: MovieCategory { get set }
    var showCancelledBookings: Bool { get set }
}

protocol AppSettingsManaging: AnyObject {
    var settings: AppSettings { get }
    var didChangeNotification: Notification.Name { get }
    var settingsFilePath: String { get }

    func updateSettings(_ settings: AppSettings)
    func resetToDefaults()
}

protocol BookingManaging: AnyObject {
    var bookings: [Booking] { get }
    var didChangeNotification: Notification.Name { get }

    @discardableResult
    func addBooking(from draft: BookingDraft, owner: UserProfile?) -> Booking

    @discardableResult
    func cancelBooking(id: String, reason: BookingCancellationReason) -> Bool

    func bookedSeats(for draft: BookingDraft) -> Set<String>

    @discardableResult
    func transferTicket(bookingID: String, seat: String, to profile: UserProfile) -> Booking?

    @discardableResult
    func clearBookings() -> Int
}

extension BookingManaging {
    @discardableResult
    func addBooking(from draft: BookingDraft) -> Booking {
        addBooking(from: draft, owner: nil)
    }

    @discardableResult
    func cancelBooking(id: String) -> Bool {
        cancelBooking(id: id, reason: .user)
    }
}

protocol BookingNotificationScheduling: AnyObject {
    func scheduleReminders(for booking: Booking)
    func cancelReminders(for bookingID: String)
    func clearAllNotifications()
    func scheduleCancellationNotice(for booking: Booking, reason: BookingCancellationReason)
    func scheduleDemoReminder(for booking: Booking, delay: TimeInterval, completion: @escaping (Bool) -> Void)
}

extension BookingNotificationScheduling {
    func scheduleDemoReminder(
        for booking: Booking,
        delay: TimeInterval = AppConstants.Notifications.demoDelay,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        scheduleDemoReminder(for: booking, delay: delay, completion: completion)
    }
}

protocol Authenticating: AnyObject {
    var currentProfile: UserProfile? { get }
    var didChangeNotification: Notification.Name { get }

    @discardableResult
    func createAccount(
        fullName: String,
        email: String,
        phoneNumber: String,
        password: String
    ) throws -> UserProfile

    @discardableResult
    func logIn(email: String, password: String) throws -> UserProfile

    func logOut()

    func profile(matchingEmail email: String) -> UserProfile?

    @discardableResult
    func updateCurrentProfile(
        fullName: String,
        email: String,
        phoneNumber: String
    ) throws -> UserProfile
}
