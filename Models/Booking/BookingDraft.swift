import Foundation

// module 2 temporary booking form data
// this is created before the booking is confirmed and saved
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

    var seatLayout: SeatLayout {
        cinema.seatLayout
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
