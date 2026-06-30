import Foundation

// module 5 codable app review
// user ownership and timestamps support one editable review per showing
struct Review: Codable, Equatable, Identifiable {
    let id: String
    let subjectID: String
    let contentType: ReviewContentType
    let authorProfileID: UUID
    let authorName: String
    let rating: Double
    let comment: String
    let createdAt: Date
    let updatedAt: Date?

    var authorInitials: String {
        authorName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }

    var relativeDateText: String {
        let date = updatedAt ?? createdAt
        let days = max(0, Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0)
        switch days {
        case 0: return updatedAt == nil ? "today" : "edited today"
        case 1: return updatedAt == nil ? "1 day ago" : "edited 1 day ago"
        default: return updatedAt == nil ? "\(days) days ago" : "edited \(days) days ago"
        }
    }
}
