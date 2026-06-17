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

protocol BookingManaging: AnyObject {
    var bookings: [Booking] { get }
    var didChangeNotification: Notification.Name { get }

    @discardableResult
    func addBooking(from draft: BookingDraft) -> Booking

    @discardableResult
    func cancelBooking(id: String) -> Bool
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

    @discardableResult
    func updateCurrentProfile(
        fullName: String,
        email: String,
        phoneNumber: String
    ) throws -> UserProfile
}
