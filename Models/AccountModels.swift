import Foundation

// module 5 account model rules
// validation stays here so profile screens do not repeat the same checks
struct UserProfile: Codable, Equatable, Identifiable {
    let id: UUID
    var fullName: String
    var email: String
    var phoneNumber: String
    let joinedAt: Date

    var initials: String {
        let letters = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        return letters.isEmpty ? "CS" : String(letters).uppercased()
    }

    var memberSinceText: String {
        joinedAt.formatted(.dateTime.month(.wide).year())
    }
}

struct SampleProfileAccount {
    let profile: UserProfile
    let password: String
}

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

enum AccountValidation {
    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValidEmail(_ email: String) -> Bool {
        let normalized = normalizedEmail(email)
        guard !normalized.contains(".."),
              !normalized.contains(" ") else {
            return false
        }

        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return normalized.range(
            of: pattern,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    static func isStrongPassword(_ password: String) -> Bool {
        password.count >= 8 &&
            password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
            password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            password.rangeOfCharacter(from: .whitespacesAndNewlines) == nil &&
            password.rangeOfCharacter(from: .decimalDigits) != nil
    }
}
