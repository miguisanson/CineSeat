import Foundation

// module 1 enum example
// ticket price and seat layout depend on standard or vip
enum CinemaType: String, Codable {
    case standard = "Standard"
    case vip = "VIP"
}
