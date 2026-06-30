import Foundation

// module 2 cinema detail viewmodel
// a cinema pin shows assigned schedules without letting users pick any cinema freely
final class CinemaDetailViewModel {
    struct AssignedShowing {
        let movie: Movie
        let schedule: ShowingSchedule
        let time: ShowingTime

        var displayText: String {
            "\(schedule.displayDateWithTitle) - \(time.showtime)"
        }
    }

    // module 2 grouped view data
    // one movie groups its dates, and each date groups its showtimes
    struct MovieGroup {
        let movie: Movie
        let dateGroups: [DateGroup]

        var metadataText: String {
            "\(movie.genre)  ·  ★ \(String(format: "%.1f", movie.rating))  ·  \(movie.duration)"
        }

        var showtimeCount: Int {
            dateGroups.reduce(0) { $0 + $1.times.count }
        }

        var showtimeCountText: String {
            let suffix = showtimeCount == 1 ? "SHOWTIME" : "SHOWTIMES"
            return "\(showtimeCount) \(suffix)"
        }
    }

    struct DateGroup {
        let schedule: ShowingSchedule
        let times: [ShowingTime]
    }

    private let cinemaSource: () -> [Cinema]
    private let movieSource: () -> [Movie]
    private let showingSource: () -> [MovieShowing]

    let cinema: Cinema

    init(
        cinema: Cinema,
        cinemaSource: @escaping () -> [Cinema] = { AppCatalog.cinemas },
        movieSource: @escaping () -> [Movie] = { AppCatalog.movies },
        showingSource: @escaping () -> [MovieShowing] = { AppCatalog.showings }
    ) {
        self.cinema = cinema
        self.cinemaSource = cinemaSource
        self.movieSource = movieSource
        self.showingSource = showingSource
    }

    var addressText: String {
        cinema.location?.address ?? "No address saved yet"
    }

    var priceText: String {
        String(format: "₱%.2f", cinema.ticketPrice)
    }

    var scheduleCountText: String {
        let movieCount = movieGroups.count
        let movieSuffix = movieCount == 1 ? "MOVIE" : "MOVIES"
        let showtimeCount = assignedShowings.count
        let showtimeSuffix = showtimeCount == 1 ? "SHOWTIME" : "SHOWTIMES"
        return "\(movieCount) \(movieSuffix)  ·  \(showtimeCount) \(showtimeSuffix)"
    }

    // groups the flat assigned showtimes by movie, then by date, keeping the sorted order
    var movieGroups: [MovieGroup] {
        var orderedTitles: [String] = []
        var showingsByTitle: [String: [AssignedShowing]] = [:]

        for assigned in assignedShowings {
            let title = assigned.movie.title
            if showingsByTitle[title] == nil {
                orderedTitles.append(title)
            }
            showingsByTitle[title, default: []].append(assigned)
        }

        return orderedTitles.compactMap { title in
            guard let showings = showingsByTitle[title],
                  let movie = showings.first?.movie else {
                return nil
            }
            return MovieGroup(movie: movie, dateGroups: dateGroups(from: showings))
        }
    }

    private func dateGroups(from showings: [AssignedShowing]) -> [DateGroup] {
        var orderedScheduleIDs: [String] = []
        var schedulesByID: [String: ShowingSchedule] = [:]
        var timesByScheduleID: [String: [ShowingTime]] = [:]

        for showing in showings {
            let scheduleID = showing.schedule.id
            if schedulesByID[scheduleID] == nil {
                orderedScheduleIDs.append(scheduleID)
                schedulesByID[scheduleID] = showing.schedule
            }
            timesByScheduleID[scheduleID, default: []].append(showing.time)
        }

        return orderedScheduleIDs.compactMap { scheduleID in
            guard let schedule = schedulesByID[scheduleID],
                  let times = timesByScheduleID[scheduleID] else {
                return nil
            }
            return DateGroup(schedule: schedule, times: times)
        }
    }

    var assignedShowings: [AssignedShowing] {
        let movieByTitle = Dictionary(uniqueKeysWithValues: movieSource().map { ($0.title, $0) })
        return showingSource()
            .flatMap { showing -> [AssignedShowing] in
                guard let movie = movieByTitle[showing.movieTitle] else { return [] }
                return showing.allTimes.compactMap { item in
                    guard item.time.cinema.id == cinema.id else { return nil }
                    return AssignedShowing(movie: movie, schedule: item.schedule, time: item.time)
                }
            }
            .sorted { first, second in
                if first.schedule.date == second.schedule.date {
                    return first.time.startsAt(on: first.schedule.date) < second.time.startsAt(on: second.schedule.date)
                }
                return first.schedule.date < second.schedule.date
            }
    }

    func assignedShowing(at index: Int) -> AssignedShowing {
        assignedShowings[index]
    }
}
