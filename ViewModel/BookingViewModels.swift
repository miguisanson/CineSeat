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
        guard let profile = authenticationService.currentProfile else { return [] }
        return fetchBookingsUseCase
            .execute(showCancelled: showCancelledBookings)
            .filter { $0.isVisible(to: profile.email) }
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
    private(set) var selectedScheduleIndex: Int?
    private(set) var selectedTimeIndex: Int?

    init(movie: Movie, showings: [MovieShowing]? = nil, preselectedTimeID: String? = nil) {
        self.movie = movie
        self.showings = showings ?? AppCatalog.showings(for: movie)

        guard movie.isNowPlaying else { return }

        // a tapped showtime (from the cinema map) preselects its own date and time
        if let preselectedTimeID, let indices = indicesForTime(id: preselectedTimeID) {
            selectedScheduleIndex = indices.schedule
            selectedTimeIndex = indices.time
        } else {
            let hasSchedule = selectedShowing?.schedules.isEmpty == false
            selectedScheduleIndex = hasSchedule ? 0 : nil
            selectedTimeIndex = selectedSchedule?.times.isEmpty == false ? 0 : nil
        }
    }

    // matches a showtime id to its schedule and time slot within the movie showing
    private func indicesForTime(id: String) -> (schedule: Int, time: Int)? {
        guard let showing = selectedShowing else { return nil }
        for (scheduleIndex, schedule) in showing.schedules.enumerated() {
            if let timeIndex = schedule.times.firstIndex(where: { $0.id == id }) {
                return (scheduleIndex, timeIndex)
            }
        }
        return nil
    }

    var showingCount: Int {
        showings.reduce(0) { count, showing in
            count + showing.allTimes.count
        }
    }

    var isBookingAvailable: Bool {
        movie.isNowPlaying && selectedSchedule != nil && selectedTime != nil
    }

    var selectedShowing: MovieShowing? {
        showings.first
    }

    var selectedSchedule: ShowingSchedule? {
        guard let selectedScheduleIndex,
              let showing = selectedShowing,
              showing.schedules.indices.contains(selectedScheduleIndex) else {
            return nil
        }
        return showing.schedules[selectedScheduleIndex]
    }

    var selectedTime: ShowingTime? {
        guard let selectedTimeIndex,
              let selectedSchedule,
              selectedSchedule.times.indices.contains(selectedTimeIndex) else {
            return nil
        }
        return selectedSchedule.times[selectedTimeIndex]
    }

    var minimumDate: Date? {
        selectedShowing?.schedules.map(\.date).min()
    }

    var maximumDate: Date? {
        selectedShowing?.schedules.map(\.date).max()
    }

    func schedule(at index: Int) -> ShowingSchedule? {
        guard let showing = selectedShowing,
              showing.schedules.indices.contains(index) else {
            return nil
        }
        return showing.schedules[index]
    }

    func time(at index: Int) -> ShowingTime? {
        guard let selectedSchedule,
              selectedSchedule.times.indices.contains(index) else {
            return nil
        }
        return selectedSchedule.times[index]
    }

    func selectDate(_ date: Date) {
        guard movie.isNowPlaying,
              let showing = selectedShowing,
              let index = showing.schedules.firstIndex(where: {
                  CineSeatDateFormatters.isSameDay($0.date, date)
              }) else {
            return
        }

        selectedScheduleIndex = index
        selectedTimeIndex = showing.schedules[index].times.isEmpty ? nil : 0
    }

    func selectTime(at index: Int) {
        guard movie.isNowPlaying,
              let selectedSchedule,
              selectedSchedule.times.indices.contains(index) else {
            return
        }
        selectedTimeIndex = index
    }

    func makeDraft() -> BookingDraft? {
        guard let selectedShowing,
              let selectedSchedule,
              let selectedTime else {
            return nil
        }
        return BookingDraft(
            movie: movie,
            showing: selectedShowing,
            schedule: selectedSchedule,
            time: selectedTime
        )
    }
}

// module 2 seat selection viewmodel
// seat rules and total price math stay here before the ui updates
final class SeatSelectionViewModel {
    let layout: SeatLayout
    let bookedSeats: Set<String>
    private(set) var selectedSeats: Set<String>
    let ticketPrice: Double

    var reservedSeats: Set<String> {
        layout.reservedSeats.union(bookedSeats)
    }

    init(
        layout: SeatLayout = SeatLayout.layout(forCinemaID: 1, type: .standard),
        bookedSeats: Set<String> = [],
        ticketPrice: Double = 350
    ) {
        self.layout = layout
        let bookedSeatsForShowing = Set(bookedSeats.filter { layout.containsSeat($0) })
        self.bookedSeats = bookedSeatsForShowing
        self.selectedSeats = Self.defaultSelectedSeats(for: layout, bookedSeats: bookedSeatsForShowing)
        self.ticketPrice = ticketPrice
    }

    init(
        layout: SeatLayout = SeatLayout.layout(forCinemaID: 1, type: .standard),
        bookedSeats: Set<String> = [],
        selectedSeats: Set<String>,
        ticketPrice: Double = 350
    ) {
        self.layout = layout
        let bookedSeatsForShowing = Set(bookedSeats.filter { layout.containsSeat($0) })
        self.bookedSeats = bookedSeatsForShowing
        self.selectedSeats = Set(selectedSeats.filter {
            layout.isSelectable($0) && !bookedSeatsForShowing.contains($0)
        })
        self.ticketPrice = ticketPrice
    }

    @discardableResult
    func toggleSeat(_ seat: String) -> Bool {
        guard isSelectable(seat) else { return false }

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

    func visualState(for seat: String, isHighlighted: Bool = false) -> SeatVisualState {
        if isHighlighted {
            return .highlighted
        }

        if selectedSeats.contains(seat) {
            return .selected
        }

        if reservedSeats.contains(seat) {
            return .reserved
        }

        if layout.unavailableSeats.contains(seat) {
            return .unavailable
        }

        return .available
    }

    private func seatSortKey(_ seat: String) -> String {
        let rowLabel = String(seat.prefix(while: { !$0.isNumber }))
        let seatNumber = Int(seat.drop { !$0.isNumber }) ?? 0
        let rowIndex = layout.rows.firstIndex { $0.label == rowLabel } ?? 999
        return String(format: "%03d-%03d", rowIndex, seatNumber)
    }

    private func isSelectable(_ seat: String) -> Bool {
        layout.isSelectable(seat) && !bookedSeats.contains(seat)
    }

    private static func defaultSelectedSeats(for layout: SeatLayout, bookedSeats: Set<String>) -> Set<String> {
        let middleIndex = layout.rows.count / 2
        let orderedRows = layout.rows.indices.sorted { first, second in
            let firstDistance = abs(first - middleIndex)
            let secondDistance = abs(second - middleIndex)
            if firstDistance == secondDistance {
                return first < second
            }
            return firstDistance < secondDistance
        }.map { layout.rows[$0] }

        for row in orderedRows {
            let selectableSeats = row.seatNumbers
                .map { row.seatID(for: $0) }
                .filter { layout.isSelectable($0) && !bookedSeats.contains($0) }

            for index in selectableSeats.indices.dropLast() {
                let firstSeat = selectableSeats[index]
                let secondSeat = selectableSeats[selectableSeats.index(after: index)]
                if areSideBySide(firstSeat, secondSeat) {
                    return [firstSeat, secondSeat]
                }
            }

            if let firstSeat = selectableSeats.first {
                return [firstSeat]
            }
        }

        return []
    }

    private static func areSideBySide(_ firstSeat: String, _ secondSeat: String) -> Bool {
        let firstRow = String(firstSeat.prefix(while: { !$0.isNumber }))
        let secondRow = String(secondSeat.prefix(while: { !$0.isNumber }))
        let firstNumber = Int(firstSeat.drop { !$0.isNumber }) ?? 0
        let secondNumber = Int(secondSeat.drop { !$0.isNumber }) ?? 0
        return firstRow == secondRow && secondNumber == firstNumber + 1
    }
}
