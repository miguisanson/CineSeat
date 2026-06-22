import Foundation

// module 5 booking storage service
// file persistence is injected through the protocol so tests can swap it
final class BookingStore: BookingManaging {
    static let shared = BookingStore(
        persistence: BookingFileRepository(),
        notificationScheduler: LocalNotificationService.shared
    )
    static let bookingsDidChange = Notification.Name("bookingsDidChange")

    private(set) var bookings: [Booking]
    private let persistence: BookingPersisting?
    private let notificationScheduler: BookingNotificationScheduling?

    var didChangeNotification: Notification.Name {
        Self.bookingsDidChange
    }

    init(
        bookings: [Booking]? = nil,
        persistence: BookingPersisting? = nil,
        notificationScheduler: BookingNotificationScheduling? = nil
    ) {
        self.persistence = persistence
        self.notificationScheduler = notificationScheduler

        if let bookings {
            self.bookings = bookings
        } else if let persistence,
                  let savedBookings = try? persistence.loadBookings() {
            let realBookings = savedBookings.filter { !SampleData.sampleBookingIDs.contains($0.id) }
            self.bookings = realBookings
            if realBookings.count != savedBookings.count {
                try? persistence.saveBookings(realBookings)
            }
        } else {
            self.bookings = []
        }
    }

    @discardableResult
    func addBooking(from draft: BookingDraft) -> Booking {
        let booking = Booking(
            id: BookingNumberFormatter.makeID(sequence: nextBookingSequence),
            movie: draft.movie,
            schedule: draft.schedule,
            cinema: draft.cinema.name,
            cinemaID: draft.cinema.id,
            seats: draft.seats,
            ticketPrice: draft.ticketPrice,
            bookingFee: draft.bookingFee,
            status: .confirmed
        )
        bookings.insert(booking, at: 0)
        saveChanges()
        notificationScheduler?.scheduleReminders(for: booking)
        return booking
    }

    @discardableResult
    func cancelBooking(id: String, reason: BookingCancellationReason = .user) -> Bool {
        guard let index = bookings.firstIndex(where: { $0.id == id }),
              bookings[index].status.isConfirmed else {
            return false
        }

        bookings[index].status = .cancelled(reason: reason)
        saveChanges()
        notificationScheduler?.cancelReminders(for: id)
        notificationScheduler?.scheduleCancellationNotice(for: bookings[index], reason: reason)
        return true
    }

    func bookedSeats(for draft: BookingDraft) -> Set<String> {
        Set(bookings
            .filter { booking in
                booking.status.isConfirmed &&
                    booking.movie.title == draft.movie.title &&
                    bookingMatchesCinema(booking, draft: draft) &&
                    CineSeatDateFormatters.isSameDay(booking.schedule.date, draft.schedule.date) &&
                    booking.showtime == draft.showtime
            }
            .flatMap(\.seats))
    }

    @discardableResult
    func clearBookings() -> Int {
        let removedCount = bookings.count
        bookings.removeAll()
        notificationScheduler?.clearAllNotifications()
        saveChanges()
        return removedCount
    }

    private var nextBookingSequence: Int {
        let savedSequences = bookings.compactMap { BookingNumberFormatter.sequence(from: $0.id) }
        return (savedSequences.max() ?? 0) + 1
    }

    private func saveChanges() {
        do {
            try persistence?.saveBookings(bookings)
        } catch {
            print("Could not save bookings: \(error.localizedDescription)")
        }
        NotificationCenter.default.post(name: Self.bookingsDidChange, object: nil)
    }

    private func bookingMatchesCinema(_ booking: Booking, draft: BookingDraft) -> Bool {
        if let cinemaID = booking.cinemaID {
            return cinemaID == draft.cinema.id
        }
        return booking.cinema == draft.cinema.name
    }
}
