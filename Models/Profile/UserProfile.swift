import Foundation

// module 5 profile model
// codable lets profile json save and load cleanly
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
