import Foundation

// module 5 decodable json shapes
// dto structs match the json file and are mapped into app models separately
struct SampleDataDTO: Decodable {
    let cinemas: [Cinema]
    let movies: [Movie]
    let showings: [ShowingDTO]
    let bookings: [BookingDTO]
    let profileAccounts: [ProfileAccountDTO]
}

struct ShowingDTO: Decodable {
    let id: String
    let movieTitle: String
    let dateTitle: String
    let date: String
    let showtime: String
    let cinemaID: Int
}

struct BookingDTO: Decodable {
    let id: String
    let movieTitle: String
    let date: String
    let showtime: String
    let cinemaID: Int
    let seats: [String]
    let bookingFee: Double
    let status: BookingStatus
}

struct ProfileAccountDTO: Decodable {
    let profile: UserProfile
    let password: String
}
