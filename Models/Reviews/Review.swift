import Foundation

// module 5 codable app review
// daysAgo keeps starter reviews relative to the current date
struct Review: Codable, Equatable, Identifiable {
    let id: String
    let subjectID: String
    let contentType: ReviewContentType
    let authorName: String
    let rating: Double
    let comment: String
    let daysAgo: Int
    let likes: Int

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
        switch daysAgo {
        case 0: return "today"
        case 1: return "1 day ago"
        default: return "\(daysAgo) days ago"
        }
    }
}
