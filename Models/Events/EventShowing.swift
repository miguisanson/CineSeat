import Foundation

// module 4 style event schedule result
// this connects an event id to its nested dates and time options
struct EventShowing: Codable, Equatable, Identifiable {
    let id: String
    let eventID: String
    let schedules: [EventSchedule]

    var allTimes: [(schedule: EventSchedule, time: EventTime)] {
        schedules.flatMap { schedule in
            schedule.times.map { (schedule, $0) }
        }
    }
}
