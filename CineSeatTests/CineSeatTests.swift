import XCTest
@testable import CineSeat

// module 5 and 6 tests
// these check persistence validation viewmodels and protocol-based fakes
final class CineSeatTests: XCTestCase {
    func testTicketPleaseBrandAndBookingPrefix() {
        XCTAssertEqual(AppConstants.Brand.name, "TicketPlease")
        XCTAssertTrue(BookingNumberFormatter.makeID(sequence: 1).hasPrefix("TP-"))
        XCTAssertEqual(RatingSortOrder.highestFirst.buttonTitle, "Rating: High to Low ↓")
        XCTAssertEqual(RatingSortOrder.lowestFirst.buttonTitle, "Rating: Low to High ↑")
    }

    func testMovieSearchAndRatingSortAcrossCategories() {
        let viewModel = MoviesViewModel()
        XCTAssertEqual(viewModel.movieCountText, "Movie library - 10 films")

        viewModel.searchText = "dune"
        XCTAssertEqual(viewModel.filteredMovies.map(\.title), ["Dune: Part Two"])

        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredMovies.map(\.title), [
            "The Dark Knight",
            "Inception",
            "Star Wars: Episode IV - A New Hope",
            "Dune: Part Two",
            "Oppenheimer",
            "Inside Out 2",
            "The Lord of the Rings: The Fellowship of the Ring",
            "Spider-Man: No Way Home",
            "Harry Potter and the Sorcerer's Stone",
            "Avatar: The Way of Water"
        ])

        viewModel.toggleRatingSortOrder()
        XCTAssertEqual(viewModel.filteredMovies.map(\.title), [
            "Avatar: The Way of Water",
            "Harry Potter and the Sorcerer's Stone",
            "Spider-Man: No Way Home",
            "Inside Out 2",
            "The Lord of the Rings: The Fellowship of the Ring",
            "Dune: Part Two",
            "Oppenheimer",
            "Inception",
            "Star Wars: Episode IV - A New Hope",
            "The Dark Knight"
        ])

        viewModel.selectedCategory = .comingSoon
        XCTAssertEqual(viewModel.filteredMovies.map(\.title), [
            "Avatar: The Way of Water",
            "Harry Potter and the Sorcerer's Stone"
        ])

        viewModel.toggleRatingSortOrder()
        XCTAssertEqual(viewModel.filteredMovies.map(\.title), [
            "Harry Potter and the Sorcerer's Stone",
            "Avatar: The Way of Water"
        ])
    }

    func testLocalContentHasExpectedReleaseData() {
        XCTAssertEqual(AppContent.movies.count, 10)
        XCTAssertEqual(AppContent.cinemas.count, 8)
        XCTAssertEqual(AppContent.cinemas.filter { $0.type == .standard }.count, 6)
        XCTAssertEqual(AppContent.cinemas.filter { $0.type == .vip }.count, 2)
        XCTAssertTrue(AppContent.cinemas.filter { $0.type == .standard }.allSatisfy { $0.ticketPrice == 350 })
        XCTAssertTrue(AppContent.cinemas.filter { $0.type == .vip }.allSatisfy { $0.ticketPrice == 550 })
        XCTAssertTrue(AppContent.cinemas.allSatisfy { $0.location != nil })
        XCTAssertEqual(AppContent.concerts.count, 15)
        XCTAssertEqual(AppContent.seminars.count, 5)
        XCTAssertEqual(AppContent.eventVenues.count, 18)
        XCTAssertEqual(AppContent.eventShowings.count, 20)
        XCTAssertTrue(AppContent.concerts.allSatisfy { $0.category == .concert })
        XCTAssertTrue(AppContent.seminars.allSatisfy { $0.category == .seminar })
        XCTAssertEqual(AppContent.concerts.compactMap(\.concert).count, 15)
        XCTAssertEqual(AppContent.seminars.compactMap(\.seminar).count, 5)
        XCTAssertTrue((AppContent.concerts + AppContent.seminars).allSatisfy { $0.posterURLString?.isEmpty == false })
    }

    func testLocalContentJsonFilesAreSplitByCategory() {
        let resourceNames = [
            "Cinemas",
            "Movies",
            "Concerts",
            "Seminars",
            "EventVenues",
            "EventShowings",
            "Showings"
        ]

        XCTAssertTrue(resourceNames.allSatisfy {
            Bundle.main.url(forResource: $0, withExtension: "json") != nil
        })
        XCTAssertNotNil(Bundle.main.url(forResource: "LocalContentMetadata", withExtension: "json"))
    }

    func testLocalContentStoreInitializesWritableDocumentsCopies() {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let store = LocalContentStore.load(directoryURL: directoryURL)
        let contentDirectory = directoryURL.appendingPathComponent("LocalContent", isDirectory: true)
        let resourceNames = [
            "Cinemas",
            "Movies",
            "Concerts",
            "Seminars",
            "EventVenues",
            "EventShowings",
            "Showings"
        ]

        XCTAssertEqual(store.movies.count, 10)
        XCTAssertEqual(store.concerts.count, 15)
        XCTAssertTrue(store.movies.allSatisfy { $0.tmdbID != nil })
        XCTAssertTrue(resourceNames.allSatisfy {
            FileManager.default.fileExists(
                atPath: contentDirectory.appendingPathComponent("\($0).json").path
            )
        })
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: contentDirectory.appendingPathComponent("LocalContentMetadata.json").path
        ))
    }

    func testReviewRatingUsesOnlineFirstAndAppAverageAsFallback() {
        let reviewStore = ReviewStore(reviews: [])
        let useCase = DefaultFetchReviewsUseCase(reviewFetcher: reviewStore)
        let movieSummary = useCase.ratingSummary(for: ReviewSubject(movie: AppContent.movies[0]))
        XCTAssertEqual(movieSummary.onlineRating, 4.7)
        XCTAssertEqual(movieSummary.effectiveRating, 4.7)
        XCTAssertEqual(movieSummary.effectiveSource, "Online")

        let seminar = AppContent.seminars[0]
        let subject = ReviewSubject(event: seminar)
        _ = try? reviewStore.saveReview(
            subject: subject,
            author: makeProfile(name: "Maria Reyes", email: "maria@example.com"),
            rating: 4,
            comment: "clear examples and useful exercises"
        )
        _ = try? reviewStore.saveReview(
            subject: subject,
            author: makeProfile(name: "Paolo Cruz", email: "paolo@example.com"),
            rating: 4.5,
            comment: "the pacing worked well for me"
        )
        let seminarSummary = useCase.ratingSummary(for: ReviewSubject(event: seminar))
        XCTAssertNil(seminarSummary.onlineRating)
        XCTAssertEqual(seminarSummary.appRating ?? 0, 4.25, accuracy: 0.001)
        XCTAssertEqual(seminarSummary.effectiveRating, 4.25, accuracy: 0.001)
        XCTAssertEqual(seminarSummary.effectiveSource, "TicketPlease")
    }

    func testOnlineReviewsStaySeparateAndRequireAMovieSourceID() async throws {
        let onlineReview = OnlineReview(
            id: "tmdb-review-1",
            authorName: "Online Viewer",
            rating: 4.5,
            content: "online review text",
            createdAt: Date(),
            sourceURL: URL(string: "https://www.themoviedb.org/review/example")
        )
        let useCase = DefaultFetchOnlineReviewsUseCase(
            onlineReviewFetcher: FakeOnlineReviewFetcher(reviews: [onlineReview])
        )

        let reviews = try await useCase.execute(for: ReviewSubject(movie: AppContent.movies[0]))
        XCTAssertEqual(reviews, [onlineReview])

        do {
            _ = try await useCase.execute(for: ReviewSubject(event: AppContent.seminars[0]))
            XCTFail("Seminars should not be sent to the movie review api")
        } catch {
            XCTAssertEqual(error as? OnlineReviewError, .unavailableForContent)
        }
    }

    func testReviewsSaveUpdateReloadAndDeleteAsJSON() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let repository = ReviewFileRepository(directoryURL: directoryURL)
        let store = ReviewStore(reviews: [], persistence: repository)
        let subject = ReviewSubject(movie: AppContent.movies[0])
        let author = makeProfile(name: "Maria Reyes", email: "maria@example.com")

        let original = try store.saveReview(
            subject: subject,
            author: author,
            rating: 4,
            comment: "strong movie, the middle was a little slow"
        )
        let updated = try store.saveReview(
            subject: subject,
            author: author,
            rating: 5,
            comment: "watched it again and liked it more"
        )

        XCTAssertEqual(store.fetchReviews().count, 1)
        XCTAssertEqual(updated.id, original.id)
        XCTAssertEqual(updated.createdAt, original.createdAt)
        XCTAssertNotNil(updated.updatedAt)

        let reloadedStore = ReviewStore(persistence: repository)
        let reloadedReview = try XCTUnwrap(reloadedStore.fetchReviews().first)
        XCTAssertEqual(reloadedStore.fetchReviews().count, 1)
        XCTAssertEqual(reloadedReview.id, updated.id)
        XCTAssertEqual(reloadedReview.authorProfileID, updated.authorProfileID)
        XCTAssertEqual(reloadedReview.rating, updated.rating)
        XCTAssertEqual(reloadedReview.comment, updated.comment)
        XCTAssertThrowsError(try reloadedStore.deleteReview(id: updated.id, authorProfileID: UUID())) { error in
            XCTAssertEqual(error as? ReviewError, .notReviewOwner)
        }
        XCTAssertTrue(try reloadedStore.deleteReview(id: updated.id, authorProfileID: author.id))
        XCTAssertTrue(try repository.loadReviews().isEmpty)
    }

    func testReviewEligibilityRequiresConfirmedPastBooking() {
        let profile = makeProfile(name: "Maria Reyes", email: "maria@example.com")
        let subject = ReviewSubject(movie: AppContent.movies[0])
        let settingsStore = makeSettingsStore()
        let now = Date()
        let pastBooking = makeReviewBooking(
            owner: profile,
            movie: AppContent.movies[0],
            date: now.addingTimeInterval(-86_400),
            status: .confirmed
        )
        let useCase = DefaultCheckReviewEligibilityUseCase(
            bookingManager: BookingStore(bookings: [pastBooking]),
            settingsStore: settingsStore,
            now: { now }
        )

        XCTAssertTrue(useCase.execute(booking: pastBooking, subject: subject, profile: profile).canReview)
        XCTAssertFalse(useCase.execute(booking: pastBooking, subject: subject, profile: nil).canReview)

        let futureBooking = makeReviewBooking(
            owner: profile,
            movie: AppContent.movies[0],
            date: now.addingTimeInterval(86_400),
            status: .confirmed
        )
        let futureUseCase = DefaultCheckReviewEligibilityUseCase(
            bookingManager: BookingStore(bookings: [futureBooking]),
            settingsStore: settingsStore,
            now: { now }
        )
        XCTAssertFalse(futureUseCase.execute(booking: futureBooking, subject: subject, profile: profile).canReview)
    }

    func testReviewEligibilityOpensAfterTheScheduledStartTime() {
        let profile = makeProfile(name: "Maria Reyes", email: "maria@example.com")
        let movie = AppContent.movies[0]
        let now = CineSeatDateFormatters.dateTime(
            date: CineSeatDateFormatters.calendar.startOfDay(for: Date()),
            timeText: "3:00 PM"
        )
        let booking = Booking(
            id: "TP-DURATION-TEST",
            movie: movie,
            schedule: BookingSchedule(
                date: now,
                time: BookingTime(id: "duration-time", showtime: "2:00 PM")
            ),
            cinema: AppContent.cinemas[0].name,
            cinemaID: AppContent.cinemas[0].id,
            seats: ["A1"],
            ticketPrice: AppContent.cinemas[0].ticketPrice,
            bookingFee: AppConstants.Booking.defaultFee,
            status: .confirmed,
            ownerEmail: profile.email,
            ownerName: profile.fullName
        )
        let useCase = DefaultCheckReviewEligibilityUseCase(
            bookingManager: BookingStore(bookings: [booking]),
            settingsStore: makeSettingsStore(),
            now: { now }
        )

        XCTAssertTrue(useCase.execute(
            booking: booking,
            subject: ReviewSubject(movie: movie),
            profile: profile
        ).canReview)
    }

    func testDeveloperModeCanBypassReviewTime() {
        let settingsStore = makeSettingsStore()
        var settings = settingsStore.settings
        settings.developerModeEnabled = true
        settings.reviewTestingEnabled = true
        settingsStore.updateSettings(settings)
        let profile = makeProfile(name: "Maria Reyes", email: "maria@example.com")
        let futureBooking = makeReviewBooking(
            owner: profile,
            movie: AppContent.movies[0],
            date: Date().addingTimeInterval(86_400),
            status: .confirmed
        )
        let useCase = DefaultCheckReviewEligibilityUseCase(
            bookingManager: BookingStore(bookings: [futureBooking]),
            settingsStore: settingsStore
        )

        XCTAssertTrue(useCase.execute(
            booking: futureBooking,
            subject: ReviewSubject(movie: AppContent.movies[0]),
            profile: profile
        ).canReview)
    }

    func testDeveloperReviewModeAllowsMultipleReviewsFromOneAccount() throws {
        let store = ReviewStore(reviews: [])
        let subject = ReviewSubject(movie: AppContent.movies[0])
        let author = makeProfile(name: "Maria Reyes", email: "maria@example.com")

        _ = try store.saveReview(
            subject: subject,
            author: author,
            rating: 4,
            comment: "first test review",
            existingReviewID: nil,
            allowsMultipleReviews: true
        )
        _ = try store.saveReview(
            subject: subject,
            author: author,
            rating: 5,
            comment: "second test review",
            existingReviewID: nil,
            allowsMultipleReviews: true
        )

        XCTAssertEqual(store.fetchReviews().count, 2)
    }

    func testReviewWritingIsOnlyExposedFromBookingDetail() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let authenticationService = AuthenticationService(
            profileRepository: InMemoryProfileRepository(),
            passwordStore: InMemoryPasswordStore(),
            sessionStore: AccountSessionStore(defaults: defaults)
        )
        let profile = try authenticationService.createAccount(
            fullName: "Maria Reyes",
            email: "maria@example.com",
            phoneNumber: "09171234567",
            password: "MoviePass2026"
        )
        let booking = makeReviewBooking(
            owner: profile,
            movie: AppContent.movies[0],
            date: Date().addingTimeInterval(-86_400),
            status: .confirmed
        )
        let bookingStore = BookingStore(bookings: [booking])
        let reviewStore = ReviewStore(reviews: [])
        let settingsStore = makeSettingsStore()
        let subject = ReviewSubject(movie: AppContent.movies[0])

        func makeViewModel(context: ReviewAccessContext) -> ReviewsViewModel {
            ReviewsViewModel(
                subject: subject,
                accessContext: context,
                fetchReviewsUseCase: DefaultFetchReviewsUseCase(reviewFetcher: reviewStore),
                manageReviewsUseCase: DefaultManageReviewsUseCase(reviewManager: reviewStore),
                checkEligibilityUseCase: DefaultCheckReviewEligibilityUseCase(
                    bookingManager: bookingStore,
                    settingsStore: settingsStore
                ),
                authenticationService: authenticationService,
                settingsStore: settingsStore
            )
        }

        let showingReviews = makeViewModel(context: .readOnly)
        XCTAssertFalse(showingReviews.showsReviewAction)
        XCTAssertFalse(showingReviews.eligibility.canReview)

        let bookingReviews = makeViewModel(context: .booking(booking))
        XCTAssertTrue(bookingReviews.showsReviewAction)
        XCTAssertTrue(bookingReviews.eligibility.canReview)
    }

    func testLocalContentJsonIncludesOfflinePosterFiles() {
        XCTAssertTrue(AppContent.movies.allSatisfy { $0.localPosterName?.isEmpty == false })
        XCTAssertEqual(Set(AppContent.movies.compactMap(\.localPosterName)).count, 10)
        XCTAssertTrue(AppContent.movies.compactMap(\.localPosterName).allSatisfy { posterName in
            Bundle.main.url(
                forResource: posterName,
                withExtension: nil,
                subdirectory: "PosterImages"
            ) != nil
        })
    }

    func testMovieShowingsUsePredeterminedCinemaRotation() {
        let nowPlayingMovies = AppContent.movies.filter(\.isNowPlaying)
        XCTAssertTrue(nowPlayingMovies.allSatisfy {
            AppContent.showings(for: $0).first?.schedules.count == 7
        })
        XCTAssertTrue(nowPlayingMovies.allSatisfy {
            AppContent.showings(for: $0).first?.allTimes.count == 14
        })
        XCTAssertTrue(AppContent.showings.allSatisfy { showing in
            showing.schedules.allSatisfy { $0.times.count >= 2 }
        })
        XCTAssertTrue(AppContent.movies.filter(\.isComingSoon).allSatisfy { AppContent.showings(for: $0).isEmpty })

        let scheduledTimes = AppContent.showings.flatMap { showing in
            showing.allTimes.map { (movieTitle: showing.movieTitle, schedule: $0.schedule, time: $0.time) }
        }
        let showingCounts = Dictionary(grouping: scheduledTimes, by: { $0.time.cinema.id }).mapValues(\.count)
        for cinema in AppContent.cinemas {
            XCTAssertGreaterThanOrEqual(showingCounts[cinema.id] ?? 0, 12)
        }

        let vipMovieTitles = Set(scheduledTimes
            .filter { $0.time.cinema.type == .vip }
            .map(\.movieTitle))
        XCTAssertEqual(vipMovieTitles, Set([
            "Dune: Part Two",
            "The Dark Knight",
            "Oppenheimer"
        ]))
    }

    func testNestedSchedulesUseCurrentCalendarDates() {
        let schedules = AppContent.showings[0].schedules
        let firstSchedule = schedules[0]
        let lastSchedule = schedules[6]

        XCTAssertTrue(CineSeatDateFormatters.calendar.isDateInToday(firstSchedule.date))
        XCTAssertEqual(schedules.count, 7)
        XCTAssertEqual(firstSchedule.displayDate, CineSeatDateFormatters.displayDate.string(from: Date()))
        XCTAssertEqual(firstSchedule.shortDisplayDate, "Today")
        XCTAssertEqual(schedules[1].shortDisplayDate, "Tomorrow")
        XCTAssertEqual(lastSchedule.shortDisplayDate, "In 6 Days")
        XCTAssertEqual(lastSchedule.displayDate, CineSeatDateFormatters.displayDate.string(from: CineSeatDateFormatters.dateFromToday(daysFromToday: 6)))
        XCTAssertEqual(firstSchedule.times.first?.cinema.id, 1)
    }

    func testCinemaSeatLayoutsDifferByLocation() {
        let layouts = AppContent.cinemas.map(\.seatLayout)
        XCTAssertEqual(Set(layouts.map(\.name)).count, 8)
        XCTAssertNotEqual(AppContent.cinemas[0].seatLayout.allSeatIDs.count, AppContent.cinemas[6].seatLayout.allSeatIDs.count)
        XCTAssertFalse(AppContent.cinemas[6].seatLayout.isSelectable("A2"))
        XCTAssertTrue(AppContent.cinemas[6].seatLayout.isSelectable("B2"))
    }

    func testCinemaDetailViewModelShowsAssignedSchedules() {
        let cinema = AppContent.cinemas[6]
        let viewModel = CinemaDetailViewModel(cinema: cinema)

        XCTAssertEqual(viewModel.addressText, cinema.location?.address)
        XCTAssertEqual(viewModel.priceText, "₱550.00")
        XCTAssertFalse(viewModel.assignedShowings.isEmpty)
        XCTAssertTrue(viewModel.assignedShowings.allSatisfy { $0.time.cinema.id == cinema.id })
        XCTAssertTrue(viewModel.assignedShowings.contains { $0.movie.title == "Dune: Part Two" })
    }

    func testCinemaDetailViewModelGroupsShowtimesByMovie() {
        let cinema = AppContent.cinemas[6]
        let viewModel = CinemaDetailViewModel(cinema: cinema)
        let groups = viewModel.movieGroups

        // one group per distinct movie, with no duplicates
        let titles = groups.map(\.movie.title)
        XCTAssertEqual(Set(titles).count, titles.count)

        // grouping preserves every assigned showtime
        let groupedShowtimeCount = groups.reduce(0) { $0 + $1.showtimeCount }
        XCTAssertEqual(groupedShowtimeCount, viewModel.assignedShowings.count)

        // every grouped time still belongs to this cinema
        for group in groups {
            for dateGroup in group.dateGroups {
                XCTAssertTrue(dateGroup.times.allSatisfy { $0.cinema.id == cinema.id })
            }
        }
    }

    func testMovieScheduleViewModelPreselectsAssignedTime() {
        let movie = AppContent.movies[1]
        let baseline = MovieScheduleViewModel(movie: movie)
        // pick a showtime that is NOT the default first slot
        let target = baseline.schedule(at: 1)!.times[1]

        let viewModel = MovieScheduleViewModel(movie: movie, preselectedTimeID: target.id)
        XCTAssertEqual(viewModel.selectedTime?.id, target.id)
        XCTAssertEqual(viewModel.makeDraft()?.showtime, target.showtime)
    }

    func testDefaultSelectedSeatsAreValidForEveryCinema() {
        for cinema in AppContent.cinemas {
            let viewModel = SeatSelectionViewModel(
                layout: cinema.seatLayout,
                ticketPrice: cinema.ticketPrice
            )

            XCTAssertEqual(viewModel.selectedSeats.count, 2, "cinema \(cinema.id) should start with two selected seats")
            XCTAssertTrue(viewModel.selectedSeats.allSatisfy { cinema.seatLayout.isSelectable($0) })
        }
    }

    func testMovieScheduleViewModelBuildsDraftFromAssignedCinema() {
        let viewModel = MovieScheduleViewModel(movie: AppContent.movies[1])
        XCTAssertEqual(viewModel.showingCount, 14)

        let secondSchedule = viewModel.schedule(at: 1)
        viewModel.selectDate(secondSchedule!.date)
        let draft = viewModel.makeDraft()

        XCTAssertEqual(draft?.movie.title, "Dune: Part Two")
        XCTAssertEqual(draft?.date, secondSchedule?.displayDate)
        XCTAssertEqual(secondSchedule?.times.count, 2)
        XCTAssertEqual(draft?.showtime, secondSchedule?.times.first?.showtime)
        XCTAssertEqual(draft?.cinema.id, 7)
        XCTAssertEqual(draft?.ticketPrice, 550)
    }

    func testShowingsLandingAndCategoryViewModelsStaySeparate() {
        let showingsViewModel = ShowingsViewModel()
        XCTAssertEqual(showingsViewModel.categories, [.movies, .concerts, .seminars])
        XCTAssertEqual(showingsViewModel.countText(for: .movies), "10 movies")
        XCTAssertEqual(showingsViewModel.countText(for: .concerts), "15 concerts")
        XCTAssertEqual(showingsViewModel.countText(for: .seminars), "5 seminars")

        let vipCinema = AppContent.cinemas[7]
        let moviesViewModel = MoviesViewModel()
        moviesViewModel.selectCinema(vipCinema.name)
        let filteredMovieTitles = moviesViewModel.filteredMovies.map(\.title)
        XCTAssertFalse(filteredMovieTitles.isEmpty)
        XCTAssertTrue(filteredMovieTitles.allSatisfy { movieTitle in
            AppContent.showings.contains { showing in
                showing.movieTitle == movieTitle && showing.allTimes.contains {
                    $0.time.cinema.id == vipCinema.id
                }
            }
        })

        let concertViewModel = ConcertListViewModel()
        XCTAssertEqual(concertViewModel.filteredConcerts.count, 15)
        concertViewModel.selectedStatusFilter = .comingSoon
        XCTAssertEqual(concertViewModel.filteredConcerts.count, 3)
        XCTAssertTrue(concertViewModel.filteredConcerts.allSatisfy(\.isComingSoon))
        concertViewModel.selectedStatusFilter = .all
        let highestConcertRating = concertViewModel.ratingSummary(
            for: .concert(concertViewModel.filteredConcerts[0])
        ).effectiveRating
        concertViewModel.toggleRatingSortOrder()
        let lowestConcertRating = concertViewModel.ratingSummary(
            for: .concert(concertViewModel.filteredConcerts[0])
        ).effectiveRating
        XCTAssertGreaterThan(highestConcertRating, lowestConcertRating)
        concertViewModel.toggleRatingSortOrder()
        concertViewModel.searchText = "orchestra"
        XCTAssertTrue(concertViewModel.filteredConcerts.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("orchestra") ||
                $0.eventType.localizedCaseInsensitiveContains("orchestra") ||
                $0.venue.localizedCaseInsensitiveContains("orchestra")
        })
        concertViewModel.searchText = ""
        concertViewModel.selectVenue("Philippine Arena")
        XCTAssertFalse(concertViewModel.filteredConcerts.isEmpty)
        XCTAssertTrue(concertViewModel.filteredConcerts.allSatisfy { $0.venue == "Philippine Arena" })

        let seminarViewModel = SeminarListViewModel()
        XCTAssertEqual(seminarViewModel.filteredSeminars.count, 5)
        XCTAssertTrue(seminarViewModel.filteredSeminars.first?.isFeatured == true)
        seminarViewModel.selectedStatusFilter = .comingSoon
        XCTAssertEqual(seminarViewModel.filteredSeminars.map(\.title), ["Digital Marketing Growth Summit"])
        seminarViewModel.selectedStatusFilter = .all
        seminarViewModel.searchText = "Swift"
        XCTAssertEqual(seminarViewModel.filteredSeminars.map(\.title), ["Swift UIKit Practical Workshop"])
    }

    func testEventSchedulesUseLiveDatesVenuesAndTicketQuantities() {
        let events = AppContent.concerts + AppContent.seminars
        XCTAssertTrue(events.allSatisfy { AppContent.eventShowings(for: $0).count == 1 })
        XCTAssertTrue(AppContent.eventShowings.allSatisfy { showing in
            guard let event = events.first(where: { $0.id == showing.eventID }) else { return false }
            return showing.schedules.allSatisfy { schedule in
                schedule.date >= CineSeatDateFormatters.calendar.startOfDay(for: Date()) &&
                    schedule.times.allSatisfy { $0.venue.name == event.venue && $0.ticketPrice > 0 }
            }
        })

        let event = AppContent.seminars[0]
        let viewModel = TicketedShowingScheduleViewModel(event: event)
        XCTAssertEqual(viewModel.selectedSchedule?.times.count, 2)
        viewModel.selectTime(at: 1)
        viewModel.setQuantity(3)

        let draft = viewModel.makeDraft()
        XCTAssertEqual(draft?.event, event)
        XCTAssertEqual(draft?.quantity, 3)
        XCTAssertEqual(draft?.ticketIdentifiers, ["Ticket 1", "Ticket 2", "Ticket 3"])
        XCTAssertEqual(draft?.venue.name, event.venue)
        XCTAssertEqual(draft?.total, (draft?.ticketPrice ?? 0) * 3 + AppConstants.Booking.defaultFee)
    }

    func testEventBookingPersistsWithoutCinemaSeats() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let event = AppContent.concerts[0]
        let viewModel = TicketedShowingScheduleViewModel(event: event)
        viewModel.setQuantity(2)
        let draft = try XCTUnwrap(viewModel.makeDraft())
        let repository = BookingFileRepository(directoryURL: directoryURL)
        let store = BookingStore(bookings: [], persistence: repository)
        let owner = makeProfile(name: "Maria Reyes", email: "maria@example.com")

        let booking = store.addBooking(from: draft, owner: owner)
        XCTAssertFalse(booking.isMovieBooking)
        XCTAssertEqual(booking.event, event)
        XCTAssertTrue(booking.seats.isEmpty)
        XCTAssertEqual(booking.ticketIdentifiers, ["Ticket 1", "Ticket 2"])
        XCTAssertEqual(booking.ticketAssignments.count, 2)
        XCTAssertEqual(booking.eventVenue, draft.venue)

        let loadedBooking = try XCTUnwrap(repository.loadBookings().first)
        XCTAssertEqual(loadedBooking, booking)
        XCTAssertTrue(store.cancelBooking(id: booking.id))
    }

    func testLocationsViewModelSwitchesBetweenCinemaAndEventVenuePins() {
        let viewModel = CinemaLocationsViewModel()
        XCTAssertEqual(viewModel.mapItems.count, 8)
        XCTAssertTrue(viewModel.mapItems.allSatisfy {
            if case .cinema = $0 { return true }
            return false
        })

        viewModel.selectCategory(at: LocationCategory.eventVenues.rawValue)
        XCTAssertEqual(viewModel.mapItems.count, 18)
        XCTAssertTrue(viewModel.mapItems.allSatisfy {
            if case .eventVenue = $0 { return true }
            return false
        })

        let venue = AppContent.eventVenues.first { $0.name == "Philippine Arena" }!
        XCTAssertEqual(ShowingVenueDetailViewModel(venue: venue).events.count, 2)
    }

    func testReservedSeatCannotBeSelected() {
        let viewModel = SeatSelectionViewModel(selectedSeats: [])

        XCTAssertFalse(viewModel.toggleSeat("A2"))
        XCTAssertFalse(viewModel.selectedSeats.contains("A2"))
    }

    func testSeatSelectionUpdatesTotal() {
        let viewModel = SeatSelectionViewModel(selectedSeats: [])

        XCTAssertTrue(viewModel.toggleSeat("B1"))
        XCTAssertTrue(viewModel.toggleSeat("B2"))
        XCTAssertEqual(viewModel.sortedSelectedSeats, ["B1", "B2"])
        XCTAssertEqual(viewModel.total, 700)

        XCTAssertTrue(viewModel.toggleSeat("B1"))
        XCTAssertEqual(viewModel.total, 350)
    }

    func testPesoCurrencyFormatting() {
        XCTAssertEqual(CineSeatTheme.money(350), "₱350.00")
        XCTAssertEqual(CineSeatTheme.money(35.5), "₱35.50")
    }

    func testBookingCanBeAddedAndCancelled() {
        let store = BookingStore(bookings: [])
        var draft = BookingDraft(
            movie: AppContent.movies[0],
            date: "Saturday, June 15",
            showtime: "4:15 PM",
            cinema: AppContent.cinemas[2]
        )
        draft.seats = ["D2", "D3"]

        let booking = store.addBooking(
            from: draft,
            owner: makeProfile(name: "Maria Reyes", email: "maria@example.com")
        )
        XCTAssertEqual(store.bookings.count, 1)
        XCTAssertTrue(booking.id.contains("-\(CineSeatDateFormatters.calendar.component(.year, from: Date()))-"))
        XCTAssertEqual(booking.total, 735)
        XCTAssertTrue(store.cancelBooking(id: booking.id))
        XCTAssertEqual(store.bookings[0].status, .cancelledByUser)
        XCTAssertFalse(store.cancelBooking(id: booking.id))
    }

    func testConfirmedBookingsReserveSeatsAndDeveloperResetClearsThem() {
        let store = BookingStore(bookings: [])
        let movie = AppContent.movies[0]
        let showing = AppContent.showings(for: movie).first!
        let schedule = showing.schedules[0]
        let time = schedule.times[0]
        var draft = BookingDraft(movie: movie, showing: showing, schedule: schedule, time: time)
        draft.seats = Array(draft.seatLayout.allSeatIDs
            .filter { draft.seatLayout.isSelectable($0) }
            .prefix(2))

        store.addBooking(
            from: draft,
            owner: makeProfile(name: "Maria Reyes", email: "maria@example.com")
        )

        XCTAssertEqual(store.bookedSeats(for: draft), Set(draft.seats))
        let blockedSeatViewModel = SeatSelectionViewModel(
            layout: draft.seatLayout,
            bookedSeats: store.bookedSeats(for: draft),
            selectedSeats: []
        )
        XCTAssertFalse(blockedSeatViewModel.toggleSeat(draft.seats[0]))
        XCTAssertEqual(blockedSeatViewModel.visualState(for: draft.seats[0]), .reserved)

        XCTAssertEqual(store.clearBookings(), 1)
        XCTAssertTrue(store.bookings.isEmpty)
        XCTAssertTrue(store.bookedSeats(for: draft).isEmpty)

        let cleanSeatViewModel = SeatSelectionViewModel(
            layout: draft.seatLayout,
            bookedSeats: store.bookedSeats(for: draft),
            selectedSeats: []
        )
        XCTAssertTrue(cleanSeatViewModel.toggleSeat(draft.seats[0]))
    }

    func testBookingsAreSavedAndLoadedAsJSON() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let repository = BookingFileRepository(directoryURL: directoryURL)
        var draft = BookingDraft(
            movie: AppContent.movies[0],
            date: "Saturday, June 15",
            showtime: "4:15 PM",
            cinema: AppContent.cinemas[2]
        )
        draft.seats = ["D2", "D3"]

        let writingStore = BookingStore(bookings: [], persistence: repository)
        let savedBooking = writingStore.addBooking(
            from: draft,
            owner: makeProfile(name: "Maria Reyes", email: "maria@example.com")
        )

        let loadedBookings = try repository.loadBookings()
        XCTAssertEqual(loadedBookings, [savedBooking])

        XCTAssertTrue(writingStore.cancelBooking(id: savedBooking.id))
        XCTAssertEqual(try repository.loadBookings().first?.status, .cancelledByUser)
    }

    func testUserDefaultsPreferencesAreSavedAndRetrieved() {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = AppPreferences(defaults: defaults)

        XCTAssertTrue(preferences.showCancelledBookings)
        preferences.showCancelledBookings = false
        preferences.selectedMovieCategory = .comingSoon
        preferences.hasLaunchedBefore = true

        let reloadedPreferences = AppPreferences(defaults: defaults)
        XCTAssertFalse(reloadedPreferences.showCancelledBookings)
        XCTAssertEqual(reloadedPreferences.selectedMovieCategory, .comingSoon)
        XCTAssertTrue(reloadedPreferences.hasLaunchedBefore)
    }

    func testAppSettingsAreSavedAsPropertyList() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let repository = AppSettingsPropertyListRepository(directoryURL: directoryURL)
        let store = AppSettingsStore(repository: repository)
        XCTAssertTrue(store.settings.showCancelledBookings)
        XCTAssertTrue(store.settings.bookingRemindersEnabled)

        var updatedSettings = store.settings
        updatedSettings.showCancelledBookings = false
        updatedSettings.bookingRemindersEnabled = false
        store.updateSettings(updatedSettings)

        let reloadedStore = AppSettingsStore(repository: repository)
        XCTAssertFalse(reloadedStore.settings.showCancelledBookings)
        XCTAssertFalse(reloadedStore.settings.bookingRemindersEnabled)
        XCTAssertTrue(FileManager.default.fileExists(atPath: repository.settingsURL.path))

        let data = try Data(contentsOf: repository.settingsURL)
        let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )
        XCTAssertNotNil(plist)
    }

    func testSeatLayoutsLoadFromPropertyListDatabase() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let repository = SeatLayoutPropertyListRepository(directoryURL: directoryURL)
        let database = try repository.loadDatabase()
        let store = SeatLayoutStore(repository: repository)
        let vipLayout = store.layout(forCinemaID: 8, type: .vip)

        XCTAssertEqual(database.layouts.count, 8)
        XCTAssertEqual(store.layoutCount, 8)
        XCTAssertEqual(store.databaseVersion, "2026.06.22")
        XCTAssertTrue(FileManager.default.fileExists(atPath: repository.editableURL.path))
        XCTAssertEqual(vipLayout.name, "vip directors club")
        XCTAssertFalse(vipLayout.isSelectable("A1"))
        XCTAssertTrue(vipLayout.isSelectable("B2"))
    }

    func testBookingsViewModelFiltersCancelledBookings() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = AppPreferences(defaults: defaults)
        let authenticationService = AuthenticationService(
            profileRepository: InMemoryProfileRepository(),
            passwordStore: InMemoryPasswordStore(),
            sessionStore: AccountSessionStore(defaults: defaults)
        )
        let profile = try authenticationService.createAccount(
            fullName: "Maria Reyes",
            email: "maria@example.com",
            phoneNumber: "09171234567",
            password: "MoviePass2026"
        )
        let fixtureBookings = makeBookingFixture(owner: profile)
        let viewModel = BookingsViewModel(
            store: BookingStore(bookings: fixtureBookings),
            preferences: preferences,
            authenticationService: authenticationService
        )

        viewModel.showCancelledBookings = false
        XCTAssertEqual(viewModel.bookings.count, 2)
        XCTAssertTrue(viewModel.bookings.allSatisfy(\.status.isConfirmed))
        XCTAssertTrue(viewModel.bookings.allSatisfy { $0.isVisible(to: profile.email) })
    }

    func testBookingsViewModelHidesBookingsWhenLoggedOut() {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = AppPreferences(defaults: defaults)
        let authenticationService = AuthenticationService(
            profileRepository: InMemoryProfileRepository(),
            passwordStore: InMemoryPasswordStore(),
            sessionStore: AccountSessionStore(defaults: defaults)
        )
        let viewModel = BookingsViewModel(
            store: BookingStore(bookings: makeBookingFixture(
                owner: makeProfile(name: "Maria Reyes", email: "maria@example.com")
            )),
            preferences: preferences,
            authenticationService: authenticationService
        )

        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertTrue(viewModel.bookings.isEmpty)
        XCTAssertEqual(viewModel.countText, "LOG IN TO VIEW BOOKINGS")
    }

    func testTicketCanBeSharedToAnotherAccountByEmail() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let authenticationService = AuthenticationService(
            profileRepository: InMemoryProfileRepository(),
            passwordStore: InMemoryPasswordStore(),
            sessionStore: AccountSessionStore(defaults: defaults)
        )
        let owner = try authenticationService.createAccount(
            fullName: "Maria Reyes",
            email: "maria@example.com",
            phoneNumber: "09171234567",
            password: "MoviePass2026"
        )
        let recipient = try authenticationService.createAccount(
            fullName: "Miguel Santos",
            email: "miguel.santos@example.com",
            phoneNumber: "09175551234",
            password: "MoviePass2026"
        )
        let store = BookingStore(bookings: [])
        var draft = BookingDraft(
            movie: AppContent.movies[0],
            date: "Saturday, June 15",
            showtime: "4:15 PM",
            cinema: AppContent.cinemas[2]
        )
        draft.seats = ["D2", "D3"]

        let booking = store.addBooking(from: draft, owner: owner)
        let useCase = DefaultTransferTicketUseCase(
            bookingManager: store,
            authenticationService: authenticationService
        )
        let updatedBooking = try useCase.execute(
            bookingID: booking.id,
            seat: "D3",
            recipientEmail: recipient.email
        )

        XCTAssertEqual(updatedBooking.assignment(for: "D3")?.ownerEmail, recipient.email)
        XCTAssertTrue(updatedBooking.isVisible(to: owner.email))
        XCTAssertTrue(updatedBooking.isVisible(to: recipient.email))
        XCTAssertThrowsError(try useCase.execute(
            bookingID: booking.id,
            seat: "D2",
            recipientEmail: "missing@example.com"
        )) { error in
            XCTAssertEqual(error as? TicketTransferError, .accountNotFound)
        }

        store.cancelBooking(id: booking.id)
        XCTAssertThrowsError(try useCase.execute(
            bookingID: booking.id,
            seat: "D2",
            recipientEmail: recipient.email
        )) { error in
            XCTAssertEqual(error as? TicketTransferError, .bookingNotConfirmed)
        }
    }

    func testAccountCreationLoginUpdateAndLogout() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = InMemoryProfileRepository()
        let passwordStore = InMemoryPasswordStore()
        let service = AuthenticationService(
            profileRepository: repository,
            passwordStore: passwordStore,
            sessionStore: AccountSessionStore(defaults: defaults)
        )

        let createdProfile = try service.createAccount(
            fullName: "Maria Reyes",
            email: " MARIA.REYES@EXAMPLE.COM ",
            phoneNumber: "09171234567",
            password: "MoviePass2026"
        )
        XCTAssertEqual(createdProfile.email, "maria.reyes@example.com")
        XCTAssertEqual(service.currentProfile, createdProfile)

        service.logOut()
        XCTAssertNil(service.currentProfile)

        let loggedInProfile = try service.logIn(
            email: "maria.reyes@example.com",
            password: "MoviePass2026"
        )
        XCTAssertEqual(loggedInProfile.id, createdProfile.id)

        let updatedProfile = try service.updateCurrentProfile(
            fullName: "Maria L. Reyes",
            email: "maria.l.reyes@example.com",
            phoneNumber: "09991234567"
        )
        XCTAssertEqual(updatedProfile.fullName, "Maria L. Reyes")
        XCTAssertEqual(repository.profiles.first, updatedProfile)
    }

    func testAuthenticationServiceStartsWithoutGeneratedProfiles() {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = InMemoryProfileRepository()
        let passwordStore = InMemoryPasswordStore()
        let service = AuthenticationService(
            profileRepository: repository,
            passwordStore: passwordStore,
            sessionStore: AccountSessionStore(defaults: defaults)
        )

        XCTAssertTrue(service.profiles.isEmpty)
        XCTAssertTrue(repository.profiles.isEmpty)
    }

    func testAuthenticationServiceRemovesLegacyGeneratedProfiles() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = InMemoryProfileRepository()
        let oldProfileID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let passwordStore = InMemoryPasswordStore()
        try passwordStore.savePassword("OldPass2026", accountID: oldProfileID)
        repository.profiles = [
            UserProfile(
                id: oldProfileID,
                fullName: "Legacy Generated Account",
                email: "legacy.generated@example.com",
                phoneNumber: "09170000000",
                joinedAt: Date()
            ),
            UserProfile(
                id: UUID(),
                fullName: "Manual Tester",
                email: "manual.tester@example.com",
                phoneNumber: "09179990000",
                joinedAt: Date()
            )
        ]

        let service = AuthenticationService(
            profileRepository: repository,
            passwordStore: passwordStore,
            sessionStore: AccountSessionStore(defaults: defaults)
        )

        XCTAssertFalse(service.profiles.contains { $0.fullName == "Legacy Generated Account" })
        XCTAssertTrue(service.profiles.contains { $0.email == "manual.tester@example.com" })
        XCTAssertEqual(repository.profiles.count, 1)
        XCTAssertNil(try passwordStore.password(accountID: oldProfileID))
    }

    func testDuplicateAccountAndInvalidLoginAreRejected() throws {
        let suiteName = "CineSeatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let service = AuthenticationService(
            profileRepository: InMemoryProfileRepository(),
            passwordStore: InMemoryPasswordStore(),
            sessionStore: AccountSessionStore(defaults: defaults)
        )

        try service.createAccount(
            fullName: "Nina Santos",
            email: "nina.santos@example.com",
            phoneNumber: "",
            password: "MoviePass2026"
        )

        XCTAssertThrowsError(try service.createAccount(
            fullName: "Nina Marie Santos",
            email: "NINA.SANTOS@example.com",
            phoneNumber: "",
            password: "MoviePass2027"
        )) { error in
            XCTAssertEqual(error as? AuthenticationError, .emailAlreadyExists)
        }

        service.logOut()
        XCTAssertThrowsError(try service.logIn(email: "nina.santos@example.com", password: "WrongPass2026")) { error in
            XCTAssertEqual(error as? AuthenticationError, .invalidCredentials)
        }
    }

    func testCreateAccountValidation() {
        XCTAssertFalse(AccountValidation.isValidEmail("not-an-email"))
        XCTAssertFalse(AccountValidation.isValidEmail("user@example"))
        XCTAssertFalse(AccountValidation.isValidEmail("user name@example.com"))
        XCTAssertTrue(AccountValidation.isValidEmail("user.name+cinema@example.com"))
        XCTAssertFalse(AccountValidation.isStrongPassword("short"))
        XCTAssertFalse(AccountValidation.isStrongPassword("moviepass2026"))
        XCTAssertFalse(AccountValidation.isStrongPassword("MOVIEPASS2026"))
        XCTAssertFalse(AccountValidation.isStrongPassword("Movie Pass2026"))
        XCTAssertTrue(AccountValidation.isStrongPassword("MoviePass2026"))
    }

    func testKeychainPasswordStoreSavesReadsAndDeletesPassword() throws {
        let store = KeychainPasswordStore(service: "CineSeatTests.\(UUID().uuidString)")
        let accountID = UUID()
        defer { try? store.deletePassword(accountID: accountID) }

        try store.savePassword("MoviePass2026", accountID: accountID)
        XCTAssertEqual(try store.password(accountID: accountID), "MoviePass2026")

        try store.deletePassword(accountID: accountID)
        XCTAssertNil(try store.password(accountID: accountID))
    }

    func testRatingsUseConsistentNumericalPresentation() {
        XCTAssertEqual(RatingDisplayFormatter.text(for: 4.7), "4.7 / 5.0")
        XCTAssertEqual(RatingDisplayFormatter.text(for: 5), "5.0 / 5.0")
        XCTAssertEqual(RatingDisplayFormatter.text(for: 1), "1.0 / 5.0")

        let summary = ReviewRatingSummary(onlineRating: 4.2, appRating: nil, reviewCount: 0)
        XCTAssertEqual(summary.compactText, "Online 4.2 / 5.0")
    }

    func testShowingMetadataNormalizesDurationAndRatingText() {
        XCTAssertEqual(ShowingMetadataFormatter.duration("2H 3M"), "2h 03m")
        XCTAssertEqual(ShowingMetadataFormatter.duration("2h 32m"), "2h 32m")

        let movie = AppContent.movies[0]
        let metadata = ShowingMetadataFormatter.movie(movie)
        XCTAssertTrue(metadata.contains(ShowingMetadataFormatter.duration(movie.duration)))
        XCTAssertTrue(metadata.contains(RatingDisplayFormatter.text(for: movie.rating)))
    }

    private func makeProfile(name: String, email: String) -> UserProfile {
        UserProfile(
            id: UUID(),
            fullName: name,
            email: email,
            phoneNumber: "09171234567",
            joinedAt: Date()
        )
    }

    private func makeSettingsStore() -> AppSettingsStore {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return AppSettingsStore(
            repository: AppSettingsPropertyListRepository(directoryURL: directoryURL)
        )
    }

    private func makeReviewBooking(
        owner: UserProfile,
        movie: Movie,
        date: Date,
        status: BookingStatus
    ) -> Booking {
        let cinema = AppContent.cinemas[0]
        return Booking(
            id: "TP-REVIEW-TEST",
            movie: movie,
            schedule: BookingSchedule(
                date: date,
                time: BookingTime(id: "review-time", showtime: "12:00 AM")
            ),
            cinema: cinema.name,
            cinemaID: cinema.id,
            seats: ["A1"],
            ticketPrice: cinema.ticketPrice,
            bookingFee: AppConstants.Booking.defaultFee,
            status: status,
            ownerEmail: owner.email,
            ownerName: owner.fullName
        )
    }

    private func makeBookingFixture(owner: UserProfile) -> [Booking] {
        let movie = AppContent.movies[0]
        let cinema = AppContent.cinemas[2]
        let schedule = BookingSchedule(
            date: Date(),
            time: BookingTime(id: "fixture-415pm", showtime: "4:15 PM")
        )

        return [
            Booking(
                id: "TEST-BOOKING-001",
                movie: movie,
                schedule: schedule,
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: ["D2"],
                ticketPrice: cinema.ticketPrice,
                bookingFee: 35,
                status: .confirmed,
                ownerEmail: owner.email,
                ownerName: owner.fullName
            ),
            Booking(
                id: "TEST-BOOKING-002",
                movie: movie,
                schedule: schedule,
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: ["D3"],
                ticketPrice: cinema.ticketPrice,
                bookingFee: 35,
                status: .confirmed,
                ownerEmail: owner.email,
                ownerName: owner.fullName
            ),
            Booking(
                id: "TEST-BOOKING-003",
                movie: movie,
                schedule: schedule,
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: ["D4"],
                ticketPrice: cinema.ticketPrice,
                bookingFee: 35,
                status: .cancelledByUser,
                ownerEmail: owner.email,
                ownerName: owner.fullName
            )
        ]
    }
}

private final class InMemoryProfileRepository: ProfilePersisting {
    var profiles: [UserProfile] = []

    func loadProfiles() throws -> [UserProfile] {
        profiles
    }

    func saveProfiles(_ profiles: [UserProfile]) throws {
        self.profiles = profiles
    }
}

private final class InMemoryPasswordStore: PasswordStoring {
    private var passwords: [UUID: String] = [:]

    func savePassword(_ password: String, accountID: UUID) throws {
        passwords[accountID] = password
    }

    func password(accountID: UUID) throws -> String? {
        passwords[accountID]
    }

    func deletePassword(accountID: UUID) throws {
        passwords[accountID] = nil
    }
}

private final class FakeOnlineReviewFetcher: OnlineReviewFetching {
    let reviews: [OnlineReview]

    init(reviews: [OnlineReview]) {
        self.reviews = reviews
    }

    func fetchReviews(movieID: Int) async throws -> [OnlineReview] {
        reviews
    }
}
