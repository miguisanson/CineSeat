import Foundation

enum MovieCategory: Int, CaseIterable {
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

struct Movie: Equatable {
    let title: String
    let genre: String
    let duration: String
    let rating: Double
    let synopsis: String
    let isNowPlaying: Bool
    let isComingSoon: Bool
}

enum BookingStatus: String {
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}

struct Booking: Equatable {
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
    var cinema: String = "Screen 3 - CineMax"
    var seats: [String] = []
    let ticketPrice: Double = 14.00
    let bookingFee: Double = 1.50

    var subtotal: Double {
        Double(seats.count) * ticketPrice
    }

    var total: Double {
        subtotal + bookingFee
    }
}

enum SampleData {
    static let movies = [
        Movie(
            title: "Interstellar Echoes",
            genre: "Sci-Fi / Drama",
            duration: "2h 28m",
            rating: 4.7,
            synopsis: "A crew of astronauts ventures beyond the edge of the known universe, guided by distorted signals from a civilization that may no longer exist. When time begins to fracture, their only hope lies in a message hidden inside the stars.",
            isNowPlaying: true,
            isComingSoon: false
        ),
        Movie(
            title: "The Last Horizon",
            genre: "Action / Thriller",
            duration: "1h 54m",
            rating: 4.2,
            synopsis: "A rescue pilot crosses a collapsing border to bring a missing research team home before the final evacuation begins.",
            isNowPlaying: true,
            isComingSoon: false
        ),
        Movie(
            title: "Midnight Garden",
            genre: "Romance / Drama",
            duration: "2h 05m",
            rating: 4.5,
            synopsis: "Two strangers meet in a garden that opens only at midnight and discover that every visit changes one memory from their past.",
            isNowPlaying: true,
            isComingSoon: false
        ),
        Movie(
            title: "Neon Requiem",
            genre: "Crime / Noir",
            duration: "1h 47m",
            rating: 4.0,
            synopsis: "A detective follows a trail of coded broadcasts through a rain-soaked city where every witness seems to know the ending.",
            isNowPlaying: false,
            isComingSoon: true
        )
    ]

    static var bookings: [Booking] {
        [
            Booking(id: "CS-2024-7839", movie: movies[0], date: "Saturday, June 15", showtime: "4:15 PM", cinema: "Screen 3 - CineMax", seats: ["D2", "D3"], ticketPrice: 14, bookingFee: 1.50, status: .confirmed),
            Booking(id: "CS-2024-6120", movie: movies[1], date: "Monday, June 10", showtime: "7:00 PM", cinema: "Screen 2 - CineMax", seats: ["F5", "F6", "F7"], ticketPrice: 14, bookingFee: 1.50, status: .confirmed),
            Booking(id: "CS-2024-5901", movie: movies[2], date: "Saturday, June 1", showtime: "1:45 PM", cinema: "Screen 1 - CineMax", seats: ["B3"], ticketPrice: 14, bookingFee: 1.50, status: .cancelled),
            Booking(id: "CS-2024-4440", movie: movies[3], date: "Friday, May 24", showtime: "9:30 PM", cinema: "Screen 4 - CineMax", seats: ["A7", "A8"], ticketPrice: 14, bookingFee: 1.50, status: .confirmed)
        ]
    }
}

final class BookingStore {
    static let shared = BookingStore()
    static let bookingsDidChange = Notification.Name("bookingsDidChange")

    private(set) var bookings: [Booking]

    init(bookings: [Booking] = SampleData.bookings) {
        self.bookings = bookings
    }

    @discardableResult
    func addBooking(from draft: BookingDraft) -> Booking {
        let booking = Booking(
            id: "CS-2024-\(8000 + bookings.count)",
            movie: draft.movie,
            date: draft.date,
            showtime: draft.showtime,
            cinema: draft.cinema,
            seats: draft.seats,
            ticketPrice: draft.ticketPrice,
            bookingFee: draft.bookingFee,
            status: .confirmed
        )
        bookings.insert(booking, at: 0)
        NotificationCenter.default.post(name: Self.bookingsDidChange, object: nil)
        return booking
    }

    @discardableResult
    func cancelBooking(id: String) -> Bool {
        guard let index = bookings.firstIndex(where: { $0.id == id }),
              bookings[index].status == .confirmed else {
            return false
        }

        bookings[index].status = .cancelled
        NotificationCenter.default.post(name: Self.bookingsDidChange, object: nil)
        return true
    }
}
