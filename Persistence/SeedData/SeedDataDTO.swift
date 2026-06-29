import Foundation

// module 5 decodable json shapes
// dto structs match the json file and are mapped into app models separately
struct SeedDataDTO: Decodable {
    let cinemas: [Cinema]
    let movies: [Movie]
    let concerts: [EventListing]
    let seminars: [EventListing]
    let eventVenues: [EventVenue]
    let eventShowings: [EventShowingDTO]
    let showings: [ShowingDTO]
    let bookings: [BookingDTO]
    let profileAccounts: [ProfileAccountDTO]
}

struct EventShowingDTO: Decodable {
    let id: String
    let eventID: String
    let schedules: [EventScheduleDTO]
}

struct EventScheduleDTO: Decodable {
    let id: String
    let daysFromToday: Int
    let times: [EventTimeDTO]
}

struct EventTimeDTO: Decodable {
    let id: String
    let time: String
    let venueID: String
    let ticketPrice: Double
    let capacity: Int
}

struct ShowingDTO: Decodable {
    let id: String
    let movieTitle: String
    let schedules: [ShowingScheduleDTO]
}

struct ShowingScheduleDTO: Decodable {
    let id: String
    let daysFromToday: Int
    let times: [ShowingTimeDTO]
}

struct ShowingTimeDTO: Decodable {
    let id: String
    let time: String
    let cinemaID: Int
}

struct BookingDTO: Decodable {
    let id: String?
    let idSeed: Int?
    let movieTitle: String
    let schedule: BookingScheduleDTO
    let seats: [String]
    let bookingFee: Double
    let status: BookingStatus
    let ownerEmail: String?
    let ownerName: String?
    let ticketAssignments: [TicketAssignment]?
}

struct BookingScheduleDTO: Decodable {
    let daysFromToday: Int
    let time: BookingTimeDTO
}

struct BookingTimeDTO: Decodable {
    let id: String
    let time: String
    let cinemaID: Int
}

struct ProfileAccountDTO: Decodable {
    let profile: UserProfile
    let password: String
}
