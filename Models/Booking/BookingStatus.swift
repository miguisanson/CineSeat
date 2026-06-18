import Foundation

// module 1 enum for simple booking state
enum BookingStatus: String, Codable {
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}
