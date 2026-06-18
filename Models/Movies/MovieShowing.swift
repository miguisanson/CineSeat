import Foundation

// module 4 style local api result
// a showing already has the cinema assigned by the sample json data
struct MovieShowing: Codable, Equatable, Identifiable {
    let id: String
    let movieTitle: String
    let dateTitle: String
    let date: String
    let showtime: String
    let cinema: Cinema

    var ticketPrice: Double {
        cinema.ticketPrice
    }
}
