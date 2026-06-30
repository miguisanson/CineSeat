import Foundation

// module 6 shared ticketed showing time
// concerts and seminars both use a venue price and capacity
struct EventTime: Codable, Equatable, Identifiable {
    let id: String
    let showtime: String
    let venue: EventVenue
    let ticketPrice: Double
    let capacity: Int
}
