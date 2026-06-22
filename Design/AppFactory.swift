import UIKit

// module 6 factory pattern
// singleton stays at the composition root while features receive protocols
struct AppDependencies {
    let preferences: AppPreferencesManaging
    let authenticationService: Authenticating
    let fetchMoviesUseCase: FetchMoviesUseCase
    let fetchBookingsUseCase: FetchBookingsUseCase
    let confirmBookingUseCase: ConfirmBookingUseCase
    let cancelBookingUseCase: CancelBookingUseCase
    let notificationScheduler: BookingNotificationScheduling

    static var live: AppDependencies {
        let preferences = AppPreferences.shared
        let bookingManager = BookingStore.shared
        let authenticationService = AuthenticationService.shared
        let movieFetcher = MockMovieAPIClient()

        return AppDependencies(
            preferences: preferences,
            authenticationService: authenticationService,
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(movieFetcher: movieFetcher),
            fetchBookingsUseCase: DefaultFetchBookingsUseCase(bookingManager: bookingManager),
            confirmBookingUseCase: DefaultConfirmBookingUseCase(bookingManager: bookingManager),
            cancelBookingUseCase: DefaultCancelBookingUseCase(bookingManager: bookingManager),
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
        return viewController
    }

    func makeBookingDetailViewController(booking: Booking) -> BookingDetailViewController {
        let viewController = BookingDetailViewController()
        viewController.booking = booking
        viewController.cancelBookingUseCase = dependencies.cancelBookingUseCase
        return viewController
    }
}
