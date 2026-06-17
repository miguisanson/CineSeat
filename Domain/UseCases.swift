import Foundation

// module 6 domain use cases
// presentation calls these instead of reaching into storage directly
protocol FetchMoviesUseCase {
    func execute() -> [Movie]
}

final class MockMovieAPIClient: MovieFetching {
    private let movies: [Movie]

    init(movies: [Movie] = SampleData.movies) {
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
        return bookingManager.bookings.filter { $0.status == .confirmed }
    }
}

protocol ConfirmBookingUseCase {
    func execute(draft: BookingDraft) -> Booking
}

final class DefaultConfirmBookingUseCase: ConfirmBookingUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(draft: BookingDraft) -> Booking {
        bookingManager.addBooking(from: draft)
    }
}

protocol CancelBookingUseCase {
    func execute(id: String) -> Bool
}

final class DefaultCancelBookingUseCase: CancelBookingUseCase {
    private let bookingManager: BookingManaging

    init(bookingManager: BookingManaging) {
        self.bookingManager = bookingManager
    }

    func execute(id: String) -> Bool {
        bookingManager.cancelBooking(id: id)
    }
}
