import Foundation

// module 5 json mapper
// ids in json are connected to full app models here
enum SeedDataMapper {
    static func makeStore(from dto: SeedDataDTO) throws -> SeedDataStore {
        let cinemaByID = Dictionary(uniqueKeysWithValues: dto.cinemas.map { ($0.id, $0) })
        let movieByTitle = Dictionary(uniqueKeysWithValues: dto.movies.map { ($0.title, $0) })

        let mappedShowings = try dto.showings.map { showing -> MovieShowing in
            let schedules = try showing.schedules.map { schedule -> ShowingSchedule in
                let times = try schedule.times.map { time -> ShowingTime in
                    guard let cinema = cinemaByID[time.cinemaID] else {
                        throw SeedDataError.missingCinema(time.cinemaID)
                    }
                    return ShowingTime(
                        id: time.id,
                        showtime: time.time,
                        cinema: cinema
                    )
                }

                return ShowingSchedule(
                    id: schedule.id,
                    date: CineSeatDateFormatters.dateFromToday(daysFromToday: schedule.daysFromToday),
                    times: times
                )
            }

            return MovieShowing(
                id: showing.id,
                movieTitle: showing.movieTitle,
                schedules: schedules
            )
        }

        let mappedBookings = try dto.bookings.map { booking -> Booking in
            guard let movie = movieByTitle[booking.movieTitle] else {
                throw SeedDataError.missingMovie(booking.movieTitle)
            }
            guard let cinema = cinemaByID[booking.schedule.time.cinemaID] else {
                throw SeedDataError.missingCinema(booking.schedule.time.cinemaID)
            }
            return Booking(
                id: booking.id ?? BookingNumberFormatter.makeID(sequence: booking.idSeed ?? 1),
                movie: movie,
                schedule: BookingSchedule(
                    date: CineSeatDateFormatters.dateFromToday(daysFromToday: booking.schedule.daysFromToday),
                    time: BookingTime(
                        id: booking.schedule.time.id,
                        showtime: booking.schedule.time.time
                    )
                ),
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: booking.seats,
                ticketPrice: cinema.ticketPrice,
                bookingFee: booking.bookingFee,
                status: booking.status,
                ownerEmail: booking.ownerEmail,
                ownerName: booking.ownerName,
                ticketAssignments: booking.ticketAssignments ?? []
            )
        }

        let mappedAccounts = dto.profileAccounts.map {
            SeedProfileAccount(profile: $0.profile, password: $0.password)
        }

        return SeedDataStore(
            cinemas: dto.cinemas,
            movies: dto.movies,
            concerts: dto.concerts,
            seminars: dto.seminars,
            showings: mappedShowings,
            bookings: mappedBookings,
            profileAccounts: mappedAccounts
        )
    }
}
