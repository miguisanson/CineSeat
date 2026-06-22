import Foundation

// module 2 temporary booking form data
// this is created before the booking is confirmed and saved
struct BookingDraft {
    let movie: Movie
    var schedule: BookingSchedule
    var cinema: Cinema
    var seats: [String] = []
    let bookingFee: Double = AppConstants.Booking.defaultFee

    init(movie: Movie, schedule: BookingSchedule, cinema: Cinema, seats: [String] = []) {
        self.movie = movie
        self.schedule = schedule
        self.cinema = cinema
        self.seats = seats
    }

    init(movie: Movie, date: String, showtime: String, cinema: Cinema, seats: [String] = []) {
        self.init(
            movie: movie,
            schedule: BookingSchedule(
                date: CineSeatDateFormatters.date(fromDisplayText: date),
                time: BookingTime(id: "\(movie.title)-manual-time", showtime: showtime)
            ),
            cinema: cinema,
            seats: seats
        )
    }

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

    var date: String {
        schedule.displayDate
    }

    var dateSummary: String {
        schedule.displayDateWithTitle
    }

    var showtime: String {
        schedule.showtime
    }
}

extension BookingDraft {
    init(movie: Movie, showing: MovieShowing, schedule: ShowingSchedule, time: ShowingTime) {
        self.movie = movie
        self.schedule = BookingSchedule(
            date: schedule.date,
            time: BookingTime(id: time.id, showtime: time.showtime)
        )
        cinema = time.cinema
    }
}
