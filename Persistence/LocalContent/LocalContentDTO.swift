import Foundation

// module 5 decodable local content shapes
// dto structs match the json files and are mapped into app models separately
struct LocalContentDTO: Decodable {
    let cinemas: [Cinema]
    let movies: [Movie]
    let concerts: [Concert]
    let seminars: [Seminar]
    let eventVenues: [EventVenue]
    let eventShowings: [EventShowingDTO]
    let showings: [ShowingDTO]
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
