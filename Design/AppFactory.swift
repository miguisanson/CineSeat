import UIKit

// module 6 factory pattern
// singleton stays at the composition root while features receive protocols
struct AppDependencies {
    let preferences: AppPreferencesManaging
    let settingsStore: AppSettingsManaging
    let authenticationService: Authenticating
    let fetchMoviesUseCase: FetchMoviesUseCase
    let fetchEventsUseCase: FetchEventsUseCase
    let fetchBookingsUseCase: FetchBookingsUseCase
    let confirmBookingUseCase: ConfirmBookingUseCase
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

        return AppDependencies(
            preferences: preferences,
            settingsStore: settingsStore,
            authenticationService: authenticationService,
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(movieFetcher: movieFetcher),
            fetchEventsUseCase: DefaultFetchEventsUseCase(eventFetcher: eventFetcher),
            fetchBookingsUseCase: DefaultFetchBookingsUseCase(bookingManager: bookingManager),
            confirmBookingUseCase: DefaultConfirmBookingUseCase(bookingManager: bookingManager),
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
        ShowingsViewModel()
    }

    func makeEventListViewModel(category: EventCategory) -> EventListViewModel {
        EventListViewModel(
            category: category,
            fetchEventsUseCase: dependencies.fetchEventsUseCase
        )
    }

    func makeBookingsViewModel() -> BookingsViewModel {
        BookingsViewModel(
            fetchBookingsUseCase: dependencies.fetchBookingsUseCase,
            preferences: dependencies.preferences,
            authenticationService: dependencies.authenticationService
        )
    }

    func makeMovieScheduleViewModel(movie: Movie) -> MovieScheduleViewModel {
        MovieScheduleViewModel(movie: movie)
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
        viewController.event = event
        return viewController
    }

    func makeEditProfileViewController(profile: UserProfile?) -> EditProfileViewController {
        let viewController = EditProfileViewController()
        viewController.profile = profile
        viewController.factory = self
        return viewController
    }

    func makeMovieDetailViewController(movie: Movie) -> MovieDetailViewController {
        let viewController = MovieDetailViewController()
        viewController.movie = movie
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
