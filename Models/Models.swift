import Foundation

// module 1 and 5 app model types
// these structs are the basic data shapes used by the viewmodels
enum MovieCategory: Int, CaseIterable, Codable {
    case all
    case nowPlaying
    case comingSoon
    case topRated

    var title: String {
        switch self {
        case .all: return "All"
        case .nowPlaying: return "Now Playing"
        case .comingSoon: return "Coming Soon"
        case .topRated: return "Top Rated"
        }
    }
}

enum RatingSortOrder: Int, Codable {
    case highestFirst
    case lowestFirst

    var title: String {
        switch self {
        case .highestFirst: return "Highest First"
        case .lowestFirst: return "Lowest First"
        }
    }
}

enum CinemaType: String, Codable {
    case standard = "Standard"
    case vip = "VIP"
}

struct Cinema: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let type: CinemaType
    let ticketPrice: Double

    var shortName: String {
        "Cinema \(id)"
    }
}

struct MovieShowing: Codable, Equatable, Identifiable {
    let id: String
    let movieTitle: String
    let dateTitle: String
    let date: String
    let showtime: String
    let cinema: Cinema

    var ticketPrice: Double {
        cinema.ticketPrice
    }
}

struct Movie: Codable, Equatable {
    let title: String
    let genre: String
    let duration: String
    let rating: Double
    let synopsis: String
    let posterURLString: String?
    let localPosterName: String?
    let isNowPlaying: Bool
    let isComingSoon: Bool
}

enum BookingStatus: String, Codable {
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}

struct Booking: Codable, Equatable {
    let id: String
    let movie: Movie
    let date: String
    let showtime: String
    let cinema: String
    let seats: [String]
    let ticketPrice: Double
    let bookingFee: Double
    var status: BookingStatus

    var subtotal: Double {
        Double(seats.count) * ticketPrice
    }

    var total: Double {
        subtotal + bookingFee
    }
}

struct BookingDraft {
    let movie: Movie
    var date: String
    var showtime: String
    var cinema: Cinema
    var seats: [String] = []
    let bookingFee: Double = 35.00

    var ticketPrice: Double {
        cinema.ticketPrice
    }

    var subtotal: Double {
        Double(seats.count) * ticketPrice
    }

    var total: Double {
        subtotal + bookingFee
    }
}

extension BookingDraft {
    init(movie: Movie, showing: MovieShowing) {
        self.movie = movie
        date = showing.date
        showtime = showing.showtime
        cinema = showing.cinema
    }
}

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
