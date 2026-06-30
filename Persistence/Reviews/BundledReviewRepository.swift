import Foundation

// module 5 bundled review repository
// this can later be replaced by a remote review api through ReviewFetching
final class BundledReviewRepository: ReviewFetching {
    private let reviews: [Review]

    init(
        fileManager: FileManager = .default,
        bundle: Bundle = .main
    ) {
        let reader = JSONFileReader(fileManager: fileManager)
        guard let url = reader.bundledResourceURL(
            named: "Reviews",
            extension: "json",
            bundle: bundle
        ) else {
            reviews = []
            return
        }
        reviews = (try? reader.read([Review].self, from: url)) ?? []
    }

    func fetchReviews() -> [Review] {
        reviews
    }
}
