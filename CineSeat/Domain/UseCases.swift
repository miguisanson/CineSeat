import Foundation

// module 6 domain use cases
// presentation calls these instead of reaching into storage directly
protocol FetchMoviesUseCase {
    func execute() -> [Movie]
}

final class LocalMovieContentClient: MovieFetching {
    private let movies: [Movie]

    init(movies: [Movie] = AppContent.movies) {
        self.movies = movies
    }

    func fetchMovies() -> [Movie] {
        movies
    }
}

final class DefaultFetchMoviesUseCase: FetchMoviesUseCase {
    private let movieFetcher: MovieFetching

    init(movieFetcher: MovieFetching) {
        self.movieFetcher = movieFetcher
    }

    func execute() -> [Movie] {
        movieFetcher.fetchMovies()
    }
}

protocol FetchEventsUseCase {
    func execute(category: EventCategory) -> [EventListing]
}

final class LocalEventContentClient: EventFetching {
    private let concerts: [EventListing]
    private let seminars: [EventListing]

    init(
        concerts: [EventListing] = AppContent.concerts,
        seminars: [EventListing] = AppContent.seminars
    ) {
        self.concerts = concerts
        self.seminars = seminars
    }

    func fetchEvents(category: EventCategory) -> [EventListing] {
        switch category {
        case .concert:
            return concerts
        case .seminar:
            return seminars
        }
    }
}

final class DefaultFetchEventsUseCase: FetchEventsUseCase {
    private let eventFetcher: EventFetching

    init(eventFetcher: EventFetching) {
        self.eventFetcher = eventFetcher
    }

    func execute(category: EventCategory) -> [EventListing] {
        eventFetcher.fetchEvents(category: category)
    }
}

protocol FetchMovieShowingsUseCase {
    func execute() -> [MovieShowing]
}

// module 6 local fetch client
// this can be replaced with a remote schedule client without changing the viewmodel
final class LocalMovieShowingContentClient: MovieShowingFetching {
    private let showings: [MovieShowing]

    init(showings: [MovieShowing] = AppContent.showings) {
        self.showings = showings
    }

    func fetchMovieShowings() -> [MovieShowing] {
        showings
    }
}

final class DefaultFetchMovieShowingsUseCase: FetchMovieShowingsUseCase {
    private let showingFetcher: MovieShowingFetching

    init(showingFetcher: MovieShowingFetching) {
        self.showingFetcher = showingFetcher
    }

    func execute() -> [MovieShowing] {
        showingFetcher.fetchMovieShowings()
    }
}

protocol FetchEventShowingsUseCase {
    func execute() -> [EventShowing]
}

final class LocalEventShowingContentClient: EventShowingFetching {
    private let showings: [EventShowing]

    init(showings: [EventShowing] = AppContent.eventShowings) {
        self.showings = showings
    }

    func fetchEventShowings() -> [EventShowing] {
        showings
    }
}

final class DefaultFetchEventShowingsUseCase: FetchEventShowingsUseCase {
    private let showingFetcher: EventShowingFetching

    init(showingFetcher: EventShowingFetching) {
        self.showingFetcher = showingFetcher
    }

    func execute() -> [EventShowing] {
        showingFetcher.fetchEventShowings()
    }
}

protocol FetchBookingsUseCase {
    var didChangeNotification: Notification.Name { get }
    func execute(showCancelled: Bool) -> [Booking]
}

final class DefaultFetchBookingsUseCase: FetchBookingsUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    var didChangeNotification: Notification.Name {
        bookingManager.didChangeNotification
    }

    func execute(showCancelled: Bool) -> [Booking] {
        guard !showCancelled else { return bookingManager.bookings }
        return bookingManager.bookings.filter(\.status.isConfirmed)
    }
}

protocol ConfirmBookingUseCase {
    func execute(draft: BookingDraft, owner: UserProfile) -> Booking
}

final class DefaultConfirmBookingUseCase: ConfirmBookingUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(draft: BookingDraft, owner: UserProfile) -> Booking {
        bookingManager.addBooking(from: draft, owner: owner)
    }
}

protocol ConfirmEventBookingUseCase {
    func execute(draft: EventBookingDraft, owner: UserProfile) -> Booking
}

final class DefaultConfirmEventBookingUseCase: ConfirmEventBookingUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(draft: EventBookingDraft, owner: UserProfile) -> Booking {
        bookingManager.addBooking(from: draft, owner: owner)
    }
}

enum TicketTransferError: LocalizedError {
    case invalidEmail
    case accountNotFound
    case bookingNotFound
    case bookingNotConfirmed
    case seatNotFound

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Enter a valid account email address."
        case .accountNotFound:
            return "No \(AppConstants.Brand.name) account uses that email yet."
        case .bookingNotFound:
            return "The booking could not be found."
        case .bookingNotConfirmed:
            return "Cancelled bookings cannot share tickets."
        case .seatNotFound:
            return "That ticket is not part of this booking."
        }
    }
}

protocol TransferTicketUseCase {
    func execute(bookingID: String, seat: String, recipientEmail: String) throws -> Booking
}

final class DefaultTransferTicketUseCase: TransferTicketUseCase {
    private let bookingManager: BookingManaging
    private let authenticationService: Authenticating

    init(
        bookingManager: BookingManaging,
        authenticationService: Authenticating
    ) {
        self.bookingManager = bookingManager
        self.authenticationService = authenticationService
    }

    func execute(bookingID: String, seat: String, recipientEmail: String) throws -> Booking {
        guard AccountValidation.isValidEmail(recipientEmail) else {
            throw TicketTransferError.invalidEmail
        }

        guard let booking = bookingManager.bookings.first(where: { $0.id == bookingID }) else {
            throw TicketTransferError.bookingNotFound
        }

        guard booking.status.isConfirmed else {
            throw TicketTransferError.bookingNotConfirmed
        }

        guard let profile = authenticationService.profile(matchingEmail: recipientEmail) else {
            throw TicketTransferError.accountNotFound
        }

        if let updatedBooking = bookingManager.transferTicket(
            bookingID: bookingID,
            seat: seat,
            to: profile
        ) {
            return updatedBooking
        }

        throw TicketTransferError.seatNotFound
    }
}

protocol CancelBookingUseCase {
    func execute(id: String, reason: BookingCancellationReason) -> Bool
}

extension CancelBookingUseCase {
    func execute(id: String) -> Bool {
        execute(id: id, reason: .user)
    }
}

final class DefaultCancelBookingUseCase: CancelBookingUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(id: String, reason: BookingCancellationReason) -> Bool {
        bookingManager.cancelBooking(id: id, reason: reason)
    }
}

protocol FetchBookedSeatsUseCase {
    func execute(for draft: BookingDraft) -> Set<String>
}

final class DefaultFetchBookedSeatsUseCase: FetchBookedSeatsUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(for draft: BookingDraft) -> Set<String> {
        bookingManager.bookedSeats(for: draft)
    }
}

protocol ClearBookingsUseCase {
    @discardableResult
    func execute() -> Int
}

final class DefaultClearBookingsUseCase: ClearBookingsUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    @discardableResult
    func execute() -> Int {
        bookingManager.clearBookings()
    }
}
