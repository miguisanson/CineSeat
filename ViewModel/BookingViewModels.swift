import Foundation

// module 2 bookings viewmodel
// bookings are read through use cases so the screen does not touch storage
final class BookingsViewModel {
    private let fetchBookingsUseCase: FetchBookingsUseCase
    private let preferences: AppPreferencesManaging
    private let authenticationService: Authenticating

    init(
        fetchBookingsUseCase: FetchBookingsUseCase,
        preferences: AppPreferencesManaging,
        authenticationService: Authenticating
    ) {
        self.fetchBookingsUseCase = fetchBookingsUseCase
        self.preferences = preferences
        self.authenticationService = authenticationService
    }

    convenience init(
        store: BookingManaging = BookingStore.shared,
        preferences: AppPreferencesManaging = AppPreferences.shared,
        authenticationService: Authenticating = AuthenticationService.shared
    ) {
        self.init(
            fetchBookingsUseCase: DefaultFetchBookingsUseCase(bookingManager: store),
            preferences: preferences,
            authenticationService: authenticationService
        )
    }

    var showCancelledBookings: Bool {
        get { preferences.showCancelledBookings }
        set { preferences.showCancelledBookings = newValue }
    }

    var bookingsDidChangeNotification: Notification.Name {
        fetchBookingsUseCase.didChangeNotification
    }

    var authenticationDidChangeNotification: Notification.Name {
        authenticationService.didChangeNotification
    }

    var isLoggedIn: Bool {
        authenticationService.currentProfile != nil
    }

    var bookings: [Booking] {
        guard isLoggedIn else { return [] }
        return fetchBookingsUseCase.execute(showCancelled: showCancelledBookings)
    }

    var countText: String {
        guard isLoggedIn else { return "LOG IN TO VIEW BOOKINGS" }
        guard !bookings.isEmpty else { return "NO BOOKINGS YET" }
        return "\(bookings.count) BOOKINGS TOTAL"
    }

    var emptyStateText: String {
        if !isLoggedIn {
            return "Log in from Profile to view and manage your saved bookings."
        }
        return "Your confirmed bookings will appear here after checkout."
    }

    func booking(at index: Int) -> Booking {
        bookings[index]
    }
}

// module 2 movie schedule viewmodel
// movie detail uses this so the cinema comes from the fixed showing
final class MovieScheduleViewModel {
    private let movie: Movie
    private let showings: [MovieShowing]
    private(set) var selectedShowingIndex: Int?

    init(movie: Movie, showings: [MovieShowing]? = nil) {
        self.movie = movie
        self.showings = showings ?? SampleData.showings(for: movie)
        selectedShowingIndex = movie.isNowPlaying && !self.showings.isEmpty ? 0 : nil
    }

    var showingCount: Int {
        showings.count
    }

    var isBookingAvailable: Bool {
        movie.isNowPlaying && selectedShowing != nil
    }

    var selectedShowing: MovieShowing? {
        guard let selectedShowingIndex,
              showings.indices.contains(selectedShowingIndex) else {
            return nil
        }
        return showings[selectedShowingIndex]
    }

    func showing(at index: Int) -> MovieShowing? {
        guard showings.indices.contains(index) else { return nil }
        return showings[index]
    }

    func selectShowing(at index: Int) {
        guard movie.isNowPlaying,
              showings.indices.contains(index) else {
            return
        }
        selectedShowingIndex = index
    }

    func makeDraft() -> BookingDraft? {
        guard let selectedShowing else { return nil }
        return BookingDraft(movie: movie, showing: selectedShowing)
    }
}

// module 2 seat selection viewmodel
// seat rules and total price math stay here before the ui updates
final class SeatSelectionViewModel {
    let layout: SeatLayout
    private(set) var selectedSeats: Set<String>
    let ticketPrice: Double

    var reservedSeats: Set<String> {
        layout.reservedSeats
    }

    init(
        layout: SeatLayout = SeatLayout.layout(forCinemaID: 1, type: .standard),
        selectedSeats: Set<String> = ["D2", "D3"],
        ticketPrice: Double = 350
    ) {
        self.layout = layout
        self.selectedSeats = Set(selectedSeats.filter { layout.isSelectable($0) })
        self.ticketPrice = ticketPrice
    }

    @discardableResult
    func toggleSeat(_ seat: String) -> Bool {
        guard layout.isSelectable(seat) else { return false }

        if selectedSeats.contains(seat) {
            selectedSeats.remove(seat)
        } else {
            selectedSeats.insert(seat)
        }
        return true
    }

    var sortedSelectedSeats: [String] {
        selectedSeats.sorted { first, second in
            seatSortKey(first) < seatSortKey(second)
        }
    }

    var total: Double {
        Double(selectedSeats.count) * ticketPrice
    }

    private func seatSortKey(_ seat: String) -> String {
        let rowLabel = String(seat.prefix(while: { !$0.isNumber }))
        let seatNumber = Int(seat.drop { !$0.isNumber }) ?? 0
        let rowIndex = layout.rows.firstIndex { $0.label == rowLabel } ?? 999
        return String(format: "%03d-%03d", rowIndex, seatNumber)
    }
}
