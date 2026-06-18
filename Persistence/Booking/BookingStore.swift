import Foundation

// module 5 booking storage service
// file persistence is injected through the protocol so tests can swap it
final class BookingStore: BookingManaging {
    static let shared = BookingStore(persistence: BookingFileRepository())
    static let bookingsDidChange = Notification.Name("bookingsDidChange")

    private(set) var bookings: [Booking]
    private let persistence: BookingPersisting?

    var didChangeNotification: Notification.Name {
        Self.bookingsDidChange
    }

    init(bookings: [Booking]? = nil, persistence: BookingPersisting? = nil) {
        self.persistence = persistence

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
            id: "CS-2024-\(8000 + bookings.count)",
            movie: draft.movie,
            date: draft.date,
            showtime: draft.showtime,
            cinema: draft.cinema.name,
            cinemaID: draft.cinema.id,
            seats: draft.seats,
            ticketPrice: draft.ticketPrice,
            bookingFee: draft.bookingFee,
            status: .confirmed
        )
        bookings.insert(booking, at: 0)
        saveChanges()
        return booking
    }

    @discardableResult
    func cancelBooking(id: String) -> Bool {
        guard let index = bookings.firstIndex(where: { $0.id == id }),
              bookings[index].status == .confirmed else {
            return false
        }

        bookings[index].status = .cancelled
        saveChanges()
        return true
    }

    private func saveChanges() {
        do {
            try persistence?.saveBookings(bookings)
        } catch {
            print("Could not save bookings: \(error.localizedDescription)")
        }
        NotificationCenter.default.post(name: Self.bookingsDidChange, object: nil)
    }
}
