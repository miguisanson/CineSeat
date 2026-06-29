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
        let movieFetcher = MockMovieAPIClient()
        let eventFetcher = MockEventAPIClient()
        let showingFetcher = MockMovieShowingAPIClient()
        let eventShowingFetcher = MockEventShowingAPIClient()

        return AppDependencies(
            preferences: preferences,
            settingsStore: settingsStore,
            authenticationService: authenticationService,
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(movieFetcher: movieFetcher),
            fetchEventsUseCase: DefaultFetchEventsUseCase(eventFetcher: eventFetcher),
            fetchMovieShowingsUseCase: DefaultFetchMovieShowingsUseCase(showingFetcher: showingFetcher),
            fetchEventShowingsUseCase: DefaultFetchEventShowingsUseCase(showingFetcher: eventShowingFetcher),
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
            preferences: dependencies.preferences
        )
    }

    func makeShowingsViewModel() -> ShowingsViewModel {
        ShowingsViewModel(
            fetchMoviesUseCase: dependencies.fetchMoviesUseCase,
            fetchEventsUseCase: dependencies.fetchEventsUseCase,
            fetchMovieShowingsUseCase: dependencies.fetchMovieShowingsUseCase,
            preferences: dependencies.preferences
        )
    }

    func makeEventListViewModel(category: EventCategory) -> EventListViewModel {
        EventListViewModel(
            category: category,
            fetchEventsUseCase: dependencies.fetchEventsUseCase
        )
    }

    func makeEventScheduleViewModel(event: EventListing) -> EventScheduleViewModel {
        EventScheduleViewModel(
            event: event,
            fetchEventShowingsUseCase: dependencies.fetchEventShowingsUseCase
        )
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
        SettingsViewModel(
            settingsStore: dependencies.settingsStore,
            clearBookingsUseCase: dependencies.clearBookingsUseCase
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
        viewController.viewModel = makeSettingsViewModel()
        return viewController
    }

    func makeEventListViewController(category: EventCategory) -> EventListViewController {
        let viewController = EventListViewController()
        viewController.factory = self
        viewController.viewModel = makeEventListViewModel(category: category)
        return viewController
    }

    func makeEventDetailViewController(event: EventListing) -> EventDetailViewController {
        let viewController = EventDetailViewController()
        viewController.factory = self
        viewController.viewModel = makeEventScheduleViewModel(event: event)
        return viewController
    }

    func makeEventBookingSummaryViewController(draft: EventBookingDraft) -> EventBookingSummaryViewController {
        let viewController = EventBookingSummaryViewController()
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

    func makeEventVenueDetailViewController(venue: EventVenue) -> EventVenueDetailViewController {
        let viewController = EventVenueDetailViewController()
        viewController.factory = self
        viewController.viewModel = EventVenueDetailViewModel(venue: venue)
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
        viewController.notificationScheduler = dependencies.notificationScheduler
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
