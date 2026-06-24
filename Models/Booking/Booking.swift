import Foundation

// module 5 saved ticket owner model
// each purchased seat can be assigned to the buyer or shared to another account
struct TicketAssignment: Codable, Equatable, Identifiable {
    let id: String
    let seat: String
    var ownerEmail: String
    var ownerName: String

    init(id: String, seat: String, ownerEmail: String, ownerName: String) {
        self.id = id
        self.seat = seat
        self.ownerEmail = AccountValidation.normalizedEmail(ownerEmail)
        self.ownerName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var ownerText: String {
        ownerName.isEmpty ? ownerEmail : "\(ownerName) (\(ownerEmail))"
    }
}

// module 5 saved booking model
// cinemaID and ticketAssignments keep older saved json compatible
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
    var ticketAssignments: [TicketAssignment]

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
        case ticketAssignments
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
        status: BookingStatus,
        ownerEmail: String? = nil,
        ownerName: String? = nil,
        ticketAssignments: [TicketAssignment] = []
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
        self.ticketAssignments = ticketAssignments.isEmpty
            ? Self.makeTicketAssignments(
                bookingID: id,
                seats: seats,
                ownerEmail: ownerEmail,
                ownerName: ownerName
            )
            : ticketAssignments
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
        status: BookingStatus,
        ownerEmail: String? = nil,
        ownerName: String? = nil,
        ticketAssignments: [TicketAssignment] = []
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
            status: status,
            ownerEmail: ownerEmail,
            ownerName: ownerName,
            ticketAssignments: ticketAssignments
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
        ticketAssignments = try container.decodeIfPresent(
            [TicketAssignment].self,
            forKey: .ticketAssignments
        ) ?? []

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
        try container.encode(ticketAssignments, forKey: .ticketAssignments)
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

    var ticketAssignmentSummary: String {
        guard !ticketAssignments.isEmpty else { return "Not assigned yet" }
        return ticketAssignments
            .sorted { $0.seat < $1.seat }
            .map { "\($0.seat): \($0.ownerText)" }
            .joined(separator: "\n")
    }

    func assignment(for seat: String) -> TicketAssignment? {
        ticketAssignments.first { $0.seat == seat }
    }

    func isVisible(to email: String) -> Bool {
        guard !ticketAssignments.isEmpty else { return true }
        let normalizedEmail = AccountValidation.normalizedEmail(email)
        return ticketAssignments.contains { $0.ownerEmail == normalizedEmail }
    }

    static func makeTicketAssignments(
        bookingID: String,
        seats: [String],
        ownerEmail: String?,
        ownerName: String?
    ) -> [TicketAssignment] {
        guard let ownerEmail,
              AccountValidation.isValidEmail(ownerEmail) else {
            return []
        }

        return seats.map { seat in
            TicketAssignment(
                id: "\(bookingID)-\(seat)",
                seat: seat,
                ownerEmail: ownerEmail,
                ownerName: ownerName ?? ""
            )
        }
    }

    private var inferredCinemaID: Int {
        let digits = cinema.compactMap { $0.wholeNumberValue }
        return digits.first ?? (ticketPrice >= 550 ? 7 : 1)
    }
}
