import Foundation

// module 2 profile viewmodels
// account screens call these instead of saving data directly
final class LoginViewModel {
    private let authenticationService: Authenticating

    init(authenticationService: Authenticating = AuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    func logIn(email: String, password: String) throws {
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        guard !password.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }
        try authenticationService.logIn(email: email, password: password)
    }
}

final class CreateAccountViewModel {
    private let authenticationService: Authenticating

    init(authenticationService: Authenticating = AuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    func createAccount(
        fullName: String,
        email: String,
        phoneNumber: String,
        password: String,
        confirmPassword: String
    ) throws {
        guard fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            throw AuthenticationError.invalidName
        }
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        guard AccountValidation.isStrongPassword(password) else {
            throw AuthenticationError.weakPassword
        }
        guard password == confirmPassword else {
            throw AuthenticationError.passwordsDoNotMatch
        }

        try authenticationService.createAccount(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            password: password
        )
    }
}

final class ProfileViewModel {
    private let authenticationService: Authenticating
    private let fetchBookingsUseCase: FetchBookingsUseCase

    init(
        authenticationService: Authenticating = AuthenticationService.shared,
        fetchBookingsUseCase: FetchBookingsUseCase = DefaultFetchBookingsUseCase(
            bookingManager: BookingStore.shared
        )
    ) {
        self.authenticationService = authenticationService
        self.fetchBookingsUseCase = fetchBookingsUseCase
    }

    var currentProfile: UserProfile? {
        authenticationService.currentProfile
    }

    var authenticationDidChangeNotification: Notification.Name {
        authenticationService.didChangeNotification
    }

    var confirmedBookingsCount: Int {
        accountBookings(showCancelled: false).count
    }

    var totalBookingsCount: Int {
        accountBookings(showCancelled: true).count
    }

    func updateProfile(fullName: String, email: String, phoneNumber: String) throws {
        guard fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            throw AuthenticationError.invalidName
        }
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        try authenticationService.updateCurrentProfile(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber
        )
    }

    func logOut() {
        authenticationService.logOut()
    }

    private func accountBookings(showCancelled: Bool) -> [Booking] {
        guard let profile = authenticationService.currentProfile else { return [] }
        return fetchBookingsUseCase
            .execute(showCancelled: showCancelled)
            .filter { $0.isVisible(to: profile.email) }
    }
}
