import Foundation

// module 4 get request for tmdb movie reviews
final class TMDBReviewAPIClient: OnlineReviewFetching {
    private let session: URLSession
    private let tokenProvider: () -> String?

    init(
        session: URLSession = .shared,
        tokenProvider: @escaping () -> String? = { TMDBConfiguration.readAccessToken }
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    func fetchReviews(movieID: Int) async throws -> [OnlineReview] {
        guard let token = tokenProvider() else {
            throw OnlineReviewError.missingConfiguration
        }
        guard let url = URL(
            string: "https://api.themoviedb.org/3/movie/\(movieID)/reviews?language=en-US&page=1"
        ) else {
            throw OnlineReviewError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OnlineReviewError.invalidResponse
            }
            let responseDTO = try JSONDecoder().decode(TMDBReviewResponseDTO.self, from: data)
            return responseDTO.results.map(\.onlineReview)
        } catch let error as OnlineReviewError {
            throw error
        } catch {
            throw OnlineReviewError.requestFailed
        }
    }
}

private struct TMDBReviewResponseDTO: Decodable {
    let results: [TMDBReviewDTO]
}

private struct TMDBReviewDTO: Decodable {
    let id: String
    let author: String
    let authorDetails: TMDBAuthorDetailsDTO
    let content: String
    let createdAt: String
    let url: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case author
        case authorDetails = "author_details"
        case content
        case createdAt = "created_at"
        case url
    }

    var onlineReview: OnlineReview {
        OnlineReview(
            id: id,
            authorName: authorDetails.displayName(fallback: author),
            rating: authorDetails.rating.map { $0 / 2 },
            content: content,
            createdAt: ISO8601DateFormatter().date(from: createdAt),
            sourceURL: url.flatMap(URL.init(string:))
        )
    }
}

private struct TMDBAuthorDetailsDTO: Decodable {
    let name: String?
    let username: String?
    let rating: Double?

    func displayName(fallback: String) -> String {
        if let name, !name.isEmpty { return name }
        if let username, !username.isEmpty { return username }
        return fallback.isEmpty ? "TMDB User" : fallback
    }
}
