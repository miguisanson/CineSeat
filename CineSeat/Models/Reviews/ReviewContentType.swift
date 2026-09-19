import Foundation

// review subjects stay explicit so ids from different categories cannot mix
enum ReviewContentType: String, Codable {
    case movie
    case concert
    case seminar

    var title: String {
        switch self {
        case .movie: return "Movie"
        case .concert: return "Concert"
        case .seminar: return "Seminar"
        }
    }
}
