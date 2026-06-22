import Foundation

// module 5 saved booking model
// cinemaID is optional so older saved json can still decode
struct Booking: Codable, Equatable {
    let id: String
    let movie: Movie
    let schedule: BookingSchedule
    let cinema: String
    let cinemaID: Int?
    let seats: [String]
    let ticketPrice: Double
    let bookingFee: Double
    var status: BookingStatus

    private enum CodingKeys: String, CodingKey {
        case id
        case movie
        case schedule
        case date
        case showtime
        case cinema
        case cinemaID
        case seats
        case ticketPrice
        case bookingFee
        case status
    }

    init(
        id: String,
        movie: Movie,
        schedule: BookingSchedule,
        cinema: String,
        cinemaID: Int? = nil,
        seats: [String],
        ticketPrice: Double,
        bookingFee: Double,
        status: BookingStatus
    ) {
        self.id = id
        self.movie = movie
        self.schedule = schedule
        self.cinema = cinema
        self.cinemaID = cinemaID
        self.seats = seats
        self.ticketPrice = ticketPrice
        self.bookingFee = bookingFee
        self.status = status
    }

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
        let bookingSchedule = BookingSchedule(
            date: CineSeatDateFormatters.date(fromDisplayText: date),
            time: BookingTime(id: "\(id)-time", showtime: showtime)
        )
        self.init(
            id: id,
            movie: movie,
            schedule: bookingSchedule,
            cinema: cinema,
            cinemaID: cinemaID,
            seats: seats,
            ticketPrice: ticketPrice,
            bookingFee: bookingFee,
            status: status
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        movie = try container.decode(Movie.self, forKey: .movie)
        cinema = try container.decode(String.self, forKey: .cinema)
        cinemaID = try container.decodeIfPresent(Int.self, forKey: .cinemaID)
        seats = try container.decode([String].self, forKey: .seats)
        ticketPrice = try container.decode(Double.self, forKey: .ticketPrice)
        bookingFee = try container.decode(Double.self, forKey: .bookingFee)
        status = try container.decode(BookingStatus.self, forKey: .status)

        if let savedSchedule = try container.decodeIfPresent(BookingSchedule.self, forKey: .schedule) {
            schedule = savedSchedule
        } else {
            let savedDate = try container.decode(String.self, forKey: .date)
            let savedShowtime = try container.decode(String.self, forKey: .showtime)
            schedule = BookingSchedule(
                date: CineSeatDateFormatters.date(fromDisplayText: savedDate),
                time: BookingTime(id: "\(id)-time", showtime: savedShowtime)
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(movie, forKey: .movie)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(cinema, forKey: .cinema)
        try container.encodeIfPresent(cinemaID, forKey: .cinemaID)
        try container.encode(seats, forKey: .seats)
        try container.encode(ticketPrice, forKey: .ticketPrice)
        try container.encode(bookingFee, forKey: .bookingFee)
        try container.encode(status, forKey: .status)
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

    var startsAt: Date {
        schedule.startsAt
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
