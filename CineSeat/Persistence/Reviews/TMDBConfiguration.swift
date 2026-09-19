import Foundation

// the api token stays outside source control and can be set in the xcode scheme
enum TMDBConfiguration {
    static var readAccessToken: String? {
        let environmentToken = ProcessInfo.processInfo.environment["TMDB_READ_ACCESS_TOKEN"]
        if let token = usableToken(environmentToken) { return token }

        let plistToken = Bundle.main.object(forInfoDictionaryKey: "TMDBReadAccessToken") as? String
        return usableToken(plistToken)
    }

    private static func usableToken(_ value: String?) -> String? {
        guard let value else { return nil }
        let token = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty, !token.contains("$(") else { return nil }
        return token
    }
}
