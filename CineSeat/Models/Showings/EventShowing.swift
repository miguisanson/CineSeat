import Foundation

// module 4 shared ticketed showing schedule result
// eventID connects concert or seminar json to nested dates and times
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
