import Foundation

// module 6 event time option
// price capacity and venue belong to the selected event time
struct EventTime: Codable, Equatable, Identifiable {
    let id: String
    let showtime: String
    let venue: EventVenue
    let ticketPrice: Double
    let capacity: Int
}
