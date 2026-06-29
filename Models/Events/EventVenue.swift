import Foundation

// module 1 codable event venue
// one venue record is shared by every event that uses the same map location
struct EventVenue: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
