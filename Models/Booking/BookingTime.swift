import Foundation

// selected booking time
// this is stored inside the saved booking schedule
struct BookingTime: Codable, Equatable {
    let id: String
    let showtime: String
}
