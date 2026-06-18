import Foundation

// module 5 saved booking model
// cinemaID is optional so older saved json can still decode
struct Booking: Codable, Equatable {
    let id: String
    let movie: Movie
    let date: String
    let showtime: String
    let cinema: String
    let cinemaID: Int?
    let seats: [String]
    let ticketPrice: Double
    let bookingFee: Double
    var status: BookingStatus

    init(
        id: String,
        movie: Movie,
        date: String,
        showtime: String,
        cinema: String,
        cinemaID: Int? = nil,
        seats: [String],
        ticketPrice: Double,
        bookingFee: Double,
        status: BookingStatus
    ) {
        self.id = id
        self.movie = movie
        self.date = date
        self.showtime = showtime
        self.cinema = cinema
        self.cinemaID = cinemaID
        self.seats = seats
        self.ticketPrice = ticketPrice
        self.bookingFee = bookingFee
        self.status = status
    }

    var subtotal: Double {
        Double(seats.count) * ticketPrice
    }

    var total: Double {
        subtotal + bookingFee
    }

    var seatLayout: SeatLayout {
        SeatLayout.layout(
            forCinemaID: cinemaID ?? inferredCinemaID,
            type: ticketPrice >= 550 ? .vip : .standard
        )
    }

    private var inferredCinemaID: Int {
        let digits = cinema.compactMap { $0.wholeNumberValue }
        return digits.first ?? (ticketPrice >= 550 ? 7 : 1)
    }
}
