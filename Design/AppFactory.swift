import UIKit

// module 6 factory pattern
// singleton stays at the composition root while features receive protocols
struct AppDependencies {
    let preferences: AppPreferencesManaging
    let settingsStore: AppSettingsManaging
    let authenticationService: Authenticating
    let fetchMoviesUseCase: FetchMoviesUseCase
    let fetchEventsUseCase: FetchEventsUseCase
    let fetchMovieShowingsUseCase: FetchMovieShowingsUseCase
    let fetchEventShowingsUseCase: FetchEventShowingsUseCase
    let fetchReviewsUseCase: FetchReviewsUseCase
    let manageReviewsUseCase: ManageReviewsUseCase
    let checkReviewEligibilityUseCase: CheckReviewEligibilityUseCase
    let fetchBookingsUseCase: FetchBookingsUseCase
    let confirmBookingUseCase: ConfirmBookingUseCase
    let confirmEventBookingUseCase: ConfirmEventBookingUseCase
    let transferTicketUseCase: TransferTicketUseCase
    let cancelBookingUseCase: CancelBookingUseCase
    let fetchBookedSeatsUseCase: FetchBookedSeatsUseCase
    let clearBookingsUseCase: ClearBookingsUseCase
    let notificationScheduler: BookingNotificationScheduling

    static var live: AppDependencies {
        let settingsStore = AppSettingsStore.shared
        let preferences = AppPreferences.shared
        let bookingManager = BookingStore.shared
        let authenticationService = AuthenticationService.shared
        let movieFetcher = LocalMovieCatalogClient()
        let eventFetcher = LocalEventCatalogClient()
        let showingFetcher = LocalMovieShowingCatalogClient()
        let eventShowingFetcher = LocalEventShowingCatalogClient()
        let reviewManager = ReviewStore.shared

        return AppDependencies(
            preferences: preferences,
            settingsStore: settingsStore,
            authenticationService: authenticationService,
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(movieFetcher: movieFetcher),
            fetchEventsUseCase: DefaultFetchEventsUseCase(eventFetcher: eventFetcher),
            fetchMovieShowingsUseCase: DefaultFetchMovieShowingsUseCase(showingFetcher: showingFetcher),
            fetchEventShowingsUseCase: DefaultFetchEventShowingsUseCase(showingFetcher: eventShowingFetcher),
            fetchReviewsUseCase: DefaultFetchReviewsUseCase(reviewFetcher: reviewManager),
            manageReviewsUseCase: DefaultManageReviewsUseCase(reviewManager: reviewManager),
            checkReviewEligibilityUseCase: DefaultCheckReviewEligibilityUseCase(
                bookingManager: bookingManager,
                settingsStore: settingsStore
            ),
            fetchBookingsUseCase: DefaultFetchBookingsUseCase(bookingManager: bookingManager),
            confirmBookingUseCase: DefaultConfirmBookingUseCase(bookingManager: bookingManager),
            confirmEventBookingUseCase: DefaultConfirmEventBookingUseCase(bookingManager: bookingManager),
            transferTicketUseCase: DefaultTransferTicketUseCase(
                bookingManager: bookingManager,
                authenticationService: authenticationService
            ),
            cancelBookingUseCase: DefaultCancelBookingUseCase(bookingManager: bookingManager),
            fetchBookedSeatsUseCase: DefaultFetchBookedSeatsUseCase(bookingManager: bookingManager),
            clearBookingsUseCase: DefaultClearBookingsUseCase(bookingManager: bookingManager),
            notificationScheduler: LocalNotificationService.shared
        )
    }
}

final class AppFactory {
    static let shared = AppFactory()

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
    }

    func makeMoviesViewModel() -> MoviesViewModel {
        MoviesViewModel(
            fetchMoviesUseCase: dependencies.fetchMoviesUseCase,
            fetchMovieShowingsUseCase: dependencies.fetchMovieShowingsUseCase,
            fetchReviewsUseCase: dependencies.fetchReviewsUseCase,
            preferences: dependencies.preferences
        )
    }

    func makeShowingsViewModel() -> ShowingsViewModel {
        ShowingsViewModel(
            fetchMoviesUseCase: dependencies.fetchMoviesUseCase,
            fetchEventsUseCase: dependencies.fetchEventsUseCase
        )
    }

    func makeConcertListViewModel() -> ConcertListViewModel {
        ConcertListViewModel(
            fetchEventsUseCase: dependencies.fetchEventsUseCase,
            fetchReviewsUseCase: dependencies.fetchReviewsUseCase
        )
    }

    func makeSeminarListViewModel() -> SeminarListViewModel {
        SeminarListViewModel(
            fetchEventsUseCase: dependencies.fetchEventsUseCase,
            fetchReviewsUseCase: dependencies.fetchReviewsUseCase
        )
    }

    func makeTicketedShowingScheduleViewModel(listing: EventListing) -> TicketedShowingScheduleViewModel {
        TicketedShowingScheduleViewModel(
            event: listing,
            fetchEventShowingsUseCase: dependencies.fetchEventShowingsUseCase
        )
    }

    func makeReviewsViewModel(subject: ReviewSubject) -> ReviewsViewModel {
        ReviewsViewModel(
            subject: subject,
            fetchReviewsUseCase: dependencies.fetchReviewsUseCase,
            manageReviewsUseCase: dependencies.manageReviewsUseCase,
            checkEligibilityUseCase: dependencies.checkReviewEligibilityUseCase,
            authenticationService: dependencies.authenticationService
        )
    }

    func makeReviewsViewController(subject: ReviewSubject) -> ReviewsViewController {
        let viewController = ReviewsViewController()
        viewController.factory = self
        viewController.viewModel = makeReviewsViewModel(subject: subject)
        return viewController
    }

    func makeReviewEditorViewController(
        subject: ReviewSubject,
        author: UserProfile,
        existingReview: Review?
    ) -> ReviewEditorViewController {
        let viewController = ReviewEditorViewController()
        viewController.viewModel = ReviewEditorViewModel(
            subject: subject,
            author: author,
            existingReview: existingReview,
            manageReviewsUseCase: dependencies.manageReviewsUseCase
        )
        return viewController
    }

    func makeBookingsViewModel() -> BookingsViewModel {
        BookingsViewModel(
            fetchBookingsUseCase: dependencies.fetchBookingsUseCase,
            preferences: dependencies.preferences,
            authenticationService: dependencies.authenticationService
        )
    }

    func makeMovieScheduleViewModel(movie: Movie, preselectedTimeID: String? = nil) -> MovieScheduleViewModel {
        MovieScheduleViewModel(movie: movie, preselectedTimeID: preselectedTimeID)
    }

    func makeSeatSelectionViewModel(layout: SeatLayout, ticketPrice: Double = 350) -> SeatSelectionViewModel {
        SeatSelectionViewModel(layout: layout, ticketPrice: ticketPrice)
    }

    func makeSeatSelectionViewModel(draft: BookingDraft) -> SeatSelectionViewModel {
        SeatSelectionViewModel(
            layout: draft.seatLayout,
            bookedSeats: dependencies.fetchBookedSeatsUseCase.execute(for: draft),
            ticketPrice: draft.ticketPrice
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            authenticationService: dependencies.authenticationService,
            fetchBookingsUseCase: dependencies.fetchBookingsUseCase
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authenticationService: dependencies.authenticationService)
    }

    func makeCreateAccountViewModel() -> CreateAccountViewModel {
        CreateAccountViewModel(authenticationService: dependencies.authenticationService)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsStore: dependencies.settingsStore)
    }

    func makeDeveloperModeViewModel() -> DeveloperModeViewModel {
        DeveloperModeViewModel(
            settingsStore: dependencies.settingsStore,
            clearBookingsUseCase: dependencies.clearBookingsUseCase,
            manageReviewsUseCase: dependencies.manageReviewsUseCase,
            notificationScheduler: dependencies.notificationScheduler
        )
    }

    func makeLoginViewController() -> LoginViewController {
        let viewController = LoginViewController()
        viewController.factory = self
        return viewController
    }

    func makeCreateAccountViewController() -> CreateAccountViewController {
        let viewController = CreateAccountViewController()
        viewController.factory = self
        return viewController
    }

    func makeSettingsViewController() -> SettingsViewController {
        let viewController = SettingsViewController()
        viewController.factory = self
        viewController.viewModel = makeSettingsViewModel()
        return viewController
    }

    func makeDeveloperModeViewController() -> DeveloperModeViewController {
        let viewController = DeveloperModeViewController()
        viewController.viewModel = makeDeveloperModeViewModel()
        return viewController
    }

    func makeConcertListViewController() -> ConcertListViewController {
        let viewController = ConcertListViewController()
        viewController.factory = self
        viewController.viewModel = makeConcertListViewModel()
        return viewController
    }

    func makeSeminarListViewController() -> SeminarListViewController {
        let viewController = SeminarListViewController()
        viewController.factory = self
        viewController.viewModel = makeSeminarListViewModel()
        return viewController
    }

    func makeConcertDetailViewController(concert: Concert) -> ConcertDetailViewController {
        let listing = EventListing.concert(concert)
        let viewController = ConcertDetailViewController()
        viewController.factory = self
        viewController.viewModel = makeTicketedShowingScheduleViewModel(listing: listing)
        return viewController
    }

    func makeSeminarDetailViewController(seminar: Seminar) -> SeminarDetailViewController {
        let listing = EventListing.seminar(seminar)
        let viewController = SeminarDetailViewController()
        viewController.factory = self
        viewController.viewModel = makeTicketedShowingScheduleViewModel(listing: listing)
        return viewController
    }

    func makeTicketedShowingDetailViewController(listing: EventListing) -> UIViewController {
        switch listing {
        case .concert(let concert): return makeConcertDetailViewController(concert: concert)
        case .seminar(let seminar): return makeSeminarDetailViewController(seminar: seminar)
        }
    }

    func makeTicketedShowingBookingSummaryViewController(draft: EventBookingDraft) -> TicketedShowingBookingSummaryViewController {
        let viewController = TicketedShowingBookingSummaryViewController()
        viewController.draft = draft
        viewController.factory = self
        viewController.confirmBookingUseCase = dependencies.confirmEventBookingUseCase
        viewController.authenticationService = dependencies.authenticationService
        return viewController
    }

    func makeCinemaDetailViewController(cinema: Cinema) -> CinemaDetailViewController {
        let viewController = CinemaDetailViewController()
        viewController.factory = self
        viewController.viewModel = CinemaDetailViewModel(cinema: cinema)
        return viewController
    }

    func makeShowingVenueDetailViewController(venue: EventVenue) -> ShowingVenueDetailViewController {
        let viewController = ShowingVenueDetailViewController()
        viewController.factory = self
        viewController.viewModel = ShowingVenueDetailViewModel(venue: venue)
        return viewController
    }

    func makeEditProfileViewController(profile: UserProfile?) -> EditProfileViewController {
        let viewController = EditProfileViewController()
        viewController.profile = profile
        viewController.factory = self
        return viewController
    }

    func makeMovieDetailViewController(movie: Movie, preselectedTimeID: String? = nil) -> MovieDetailViewController {
        let viewController = MovieDetailViewController()
        viewController.movie = movie
        viewController.preselectedTimeID = preselectedTimeID
        viewController.factory = self
        return viewController
    }

    func makeSeatSelectionViewController(draft: BookingDraft) -> SeatSelectionViewController {
        let viewController = SeatSelectionViewController()
        viewController.draft = draft
        viewController.factory = self
        return viewController
    }

    func makeBookingSummaryViewController(draft: BookingDraft) -> BookingSummaryViewController {
        let viewController = BookingSummaryViewController()
        viewController.draft = draft
        viewController.factory = self
        viewController.confirmBookingUseCase = dependencies.confirmBookingUseCase
        viewController.authenticationService = dependencies.authenticationService
        return viewController
    }

    func makeConfirmationViewController(booking: Booking) -> ConfirmationViewController {
        let viewController = ConfirmationViewController()
        viewController.booking = booking
        viewController.transferTicketUseCase = dependencies.transferTicketUseCase
        return viewController
    }

    func makeBookingDetailViewController(booking: Booking) -> BookingDetailViewController {
        let viewController = BookingDetailViewController()
        viewController.booking = booking
        viewController.cancelBookingUseCase = dependencies.cancelBookingUseCase
        viewController.transferTicketUseCase = dependencies.transferTicketUseCase
        return viewController
    }
}
