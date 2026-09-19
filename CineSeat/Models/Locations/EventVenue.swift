import Foundation

// module 1 reusable ticketed showing venue
// concert and seminar schedules reference one coordinate-backed location
struct EventVenue: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
