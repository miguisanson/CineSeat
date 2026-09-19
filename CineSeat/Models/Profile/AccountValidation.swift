import Foundation

// module 5 validation helpers
// profile screens call this instead of repeating email and password checks
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
