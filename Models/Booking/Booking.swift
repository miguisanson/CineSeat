import Foundation

// module 5 saved ticket owner model
// the identifier is a seat for movies and a numbered ticket for events
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
// legacy movie and seat keys are still decoded from older bookings json files
struct Booking: Codable, Equatable {
    let id: String
    let item: BookingItem
    let schedule: BookingSchedule
    let locationName: String
    let cinemaID: Int?
    let eventVenue: EventVenue?
    let ticketIdentifiers: [String]
    let ticketPrice: Double
    let bookingFee: Double
    var status: BookingStatus
    var ticketAssignments: [TicketAssignment]

    private enum CodingKeys: String, CodingKey {
        case id
        case item
        case movie
        case event
        case schedule
        case date
        case showtime
        case locationName
        case cinema
        case cinemaID
        case eventVenue
        case ticketIdentifiers
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
        item = .movie(movie)
        self.schedule = schedule
        locationName = cinema
        self.cinemaID = cinemaID
        eventVenue = nil
        ticketIdentifiers = seats
        self.ticketPrice = ticketPrice
        self.bookingFee = bookingFee
        self.status = status
        self.ticketAssignments = ticketAssignments.isEmpty
            ? Self.makeTicketAssignments(
                bookingID: id,
                identifiers: seats,
                ownerEmail: ownerEmail,
                ownerName: ownerName
            )
            : ticketAssignments
    }

    init(
        id: String,
        event: EventListing,
        schedule: BookingSchedule,
        venue: EventVenue,
        ticketIdentifiers: [String],
        ticketPrice: Double,
        bookingFee: Double,
        status: BookingStatus,
        ownerEmail: String? = nil,
        ownerName: String? = nil
    ) {
        self.id = id
        item = .event(event)
        self.schedule = schedule
        locationName = venue.name
        cinemaID = nil
        eventVenue = venue
        self.ticketIdentifiers = ticketIdentifiers
        self.ticketPrice = ticketPrice
        self.bookingFee = bookingFee
        self.status = status
        ticketAssignments = Self.makeTicketAssignments(
            bookingID: id,
            identifiers: ticketIdentifiers,
            ownerEmail: ownerEmail,
            ownerName: ownerName
        )
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
        self.init(
            id: id,
            movie: movie,
            schedule: BookingSchedule(
                date: CineSeatDateFormatters.date(fromDisplayText: date),
                time: BookingTime(id: "\(id)-time", showtime: showtime)
            ),
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

        if let savedItem = try container.decodeIfPresent(BookingItem.self, forKey: .item) {
            item = savedItem
        } else if let legacyEvent = try container.decodeIfPresent(EventListing.self, forKey: .event) {
            item = .event(legacyEvent)
        } else {
            item = .movie(try container.decode(Movie.self, forKey: .movie))
        }

        locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
            ?? container.decode(String.self, forKey: .cinema)
        cinemaID = try container.decodeIfPresent(Int.self, forKey: .cinemaID)
        eventVenue = try container.decodeIfPresent(EventVenue.self, forKey: .eventVenue)
        ticketIdentifiers = try container.decodeIfPresent([String].self, forKey: .ticketIdentifiers)
            ?? container.decode([String].self, forKey: .seats)
        ticketPrice = try container.decode(Double.self, forKey: .ticketPrice)
        bookingFee = try container.decode(Double.self, forKey: .bookingFee)
        status = try container.decode(BookingStatus.self, forKey: .status)
        ticketAssignments = try container.decodeIfPresent([TicketAssignment].self, forKey: .ticketAssignments) ?? []

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
        try container.encode(item, forKey: .item)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(locationName, forKey: .locationName)
        try container.encodeIfPresent(cinemaID, forKey: .cinemaID)
        try container.encodeIfPresent(eventVenue, forKey: .eventVenue)
        try container.encode(ticketIdentifiers, forKey: .ticketIdentifiers)
        try container.encode(ticketPrice, forKey: .ticketPrice)
        try container.encode(bookingFee, forKey: .bookingFee)
        try container.encode(status, forKey: .status)
        try container.encode(ticketAssignments, forKey: .ticketAssignments)
    }

    var movie: Movie? {
        guard case .movie(let movie) = item else { return nil }
        return movie
    }

    var event: EventListing? {
        guard case .event(let event) = item else { return nil }
        return event
    }

    var title: String { item.title }
    var itemDetailText: String { item.detailText }
    var isMovieBooking: Bool { item.isMovie }
    var locationLabel: String { isMovieBooking ? "Cinema" : "Venue" }
    var ticketLabel: String { isMovieBooking ? "Seats" : "Tickets" }
    var date: String { schedule.displayDate }
    var dateSummary: String { schedule.displayDateWithTitle }
    var showtime: String { schedule.showtime }
    var startsAt: Date { schedule.startsAt }
    var ticketCount: Int { ticketIdentifiers.count }
    var seats: [String] { isMovieBooking ? ticketIdentifiers : [] }
    var cinema: String { locationName }
    var subtotal: Double { Double(ticketCount) * ticketPrice }
    var total: Double { subtotal + bookingFee }

    var seatLayout: SeatLayout {
        SeatLayout.layout(
            forCinemaID: cinemaID ?? inferredCinemaID,
            type: ticketPrice >= AppConstants.Booking.vipTicketPrice ? .vip : .standard
        )
    }

    var ticketAssignmentSummary: String {
        guard !ticketAssignments.isEmpty else { return "Not assigned yet" }
        return sortedTicketAssignments
            .map { "\($0.seat): \($0.ownerText)" }
            .joined(separator: "\n")
    }

    var sortedTicketAssignments: [TicketAssignment] {
        ticketAssignments.sorted { first, second in
            let firstIndex = ticketIdentifiers.firstIndex(of: first.seat) ?? ticketIdentifiers.endIndex
            let secondIndex = ticketIdentifiers.firstIndex(of: second.seat) ?? ticketIdentifiers.endIndex
            return firstIndex < secondIndex
        }
    }

    func assignment(for identifier: String) -> TicketAssignment? {
        ticketAssignments.first { $0.seat == identifier }
    }

    func isVisible(to email: String) -> Bool {
        guard !ticketAssignments.isEmpty else { return true }
        let normalizedEmail = AccountValidation.normalizedEmail(email)
        return ticketAssignments.contains { $0.ownerEmail == normalizedEmail }
    }

    private static func makeTicketAssignments(
        bookingID: String,
        identifiers: [String],
        ownerEmail: String?,
        ownerName: String?
    ) -> [TicketAssignment] {
        guard let ownerEmail, AccountValidation.isValidEmail(ownerEmail) else { return [] }
        return identifiers.map { identifier in
            TicketAssignment(
                id: "\(bookingID)-\(identifier)",
                seat: identifier,
                ownerEmail: ownerEmail,
                ownerName: ownerName ?? ""
            )
        }
    }

    private var inferredCinemaID: Int {
        let digits = locationName.compactMap { $0.wholeNumberValue }
        return digits.first ?? (ticketPrice >= AppConstants.Booking.vipTicketPrice ? 7 : 1)
    }
}
