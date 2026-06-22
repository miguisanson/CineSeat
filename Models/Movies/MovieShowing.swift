import Foundation

// module 4 style local api result
// a showing groups the json schedule array for one movie
struct MovieShowing: Codable, Equatable, Identifiable {
    let id: String
    let movieTitle: String
    let schedules: [ShowingSchedule]

    var allTimes: [(schedule: ShowingSchedule, time: ShowingTime)] {
        schedules.flatMap { schedule in
            schedule.times.map { (schedule, $0) }
        }
    }
}
