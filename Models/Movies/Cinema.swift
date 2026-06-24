import Foundation

struct CinemaLocation: Codable, Equatable {
    let address: String
    let latitude: Double
    let longitude: Double
}

// module 1 codable struct
// each cinema has its own layout so seats are not one-size-fits-all
struct Cinema: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let type: CinemaType
    let ticketPrice: Double
    let location: CinemaLocation?

    var shortName: String {
        "Cinema \(id)"
    }

    var seatLayout: SeatLayout {
        SeatLayout.layout(forCinemaID: id, type: type)
    }
}
