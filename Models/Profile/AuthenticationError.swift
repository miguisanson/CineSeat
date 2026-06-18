import Foundation

// module 1 error handling
// viewmodels show these messages in alerts
enum AuthenticationError: LocalizedError, Equatable {
    case invalidName
    case invalidEmail
    case weakPassword
    case passwordsDoNotMatch
    case emailAlreadyExists
    case invalidCredentials
    case noSignedInUser
    case storageFailed

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Enter your full name."
        case .invalidEmail:
            return "Enter a valid email address."
        case .weakPassword:
            return "Password must be at least 8 characters and include uppercase, lowercase, and a number."
        case .passwordsDoNotMatch:
            return "The passwords do not match."
        case .emailAlreadyExists:
            return "An account already exists for this email address."
        case .invalidCredentials:
            return "The email or password is incorrect."
        case .noSignedInUser:
            return "No account is currently signed in."
        case .storageFailed:
            return "The account could not be saved. Please try again."
        }
    }
}
