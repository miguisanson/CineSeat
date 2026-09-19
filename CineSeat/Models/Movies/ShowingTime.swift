import Foundation

// module 6 nested time model
// the cinema is attached here so users cannot freely pick any cinema
struct ShowingTime: Codable, Equatable, Identifiable {
    let id: String
    let showtime: String
    let cinema: Cinema

    var ticketPrice: Double {
        cinema.ticketPrice
    }

    func startsAt(on date: Date) -> Date {
        CineSeatDateFormatters.dateTime(date: date, timeText: showtime)
    }
}
