import UIKit

// module 6 design tokens
// shared sizes make future ui changes less scattered across files
enum CineSeatFont {
    static let pageTitle = UIFont.systemFont(ofSize: 22, weight: .bold)
    static let pageTitleHeavy = UIFont.systemFont(ofSize: 22, weight: .heavy)
    static let formTitle = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let confirmationTitle = UIFont.systemFont(ofSize: 21, weight: .heavy)
    static let avatarInitials = UIFont.systemFont(ofSize: 30, weight: .bold)
    static let detailTitle = UIFont.systemFont(ofSize: 17, weight: .bold)
    static let body = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let bodyBold = UIFont.systemFont(ofSize: 14, weight: .bold)
    static let bodySmall = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let field = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let fieldButton = UIFont.systemFont(ofSize: 15, weight: .semibold)
    static let caption = UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
    static let metadata = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
    static let metadataSemibold = UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
    static let infoValue = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
    static let button = UIFont.monospacedSystemFont(ofSize: 13, weight: .bold)
    static let status = UIFont.monospacedSystemFont(ofSize: 9, weight: .bold)
    static let seat = UIFont.monospacedSystemFont(ofSize: 8, weight: .bold)
    static let bookingID = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
    static let statValue = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
}

enum CineSeatSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 6
    static let regular: CGFloat = 10
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let pageHorizontal: CGFloat = 20
    static let cardPadding: CGFloat = 14
}

enum CineSeatRadius {
    static let small: CGFloat = 6
    static let extraSmall: CGFloat = 3
    static let medium: CGFloat = 10
    static let large: CGFloat = 12
    static let seat: CGFloat = 5
}

enum CineSeatSize {
    static let primaryButtonHeight: CGFloat = 48
    static let textFieldHeight: CGFloat = 50
    static let posterDetailHeight: CGFloat = 220
    static let moviePosterWidth: CGFloat = 68
    static let moviePosterHeight: CGFloat = 92
    static let statusHeight: CGFloat = 22
    static let legendWidth: CGFloat = 18
    static let legendHeight: CGFloat = 16
    static let screenHeight: CGFloat = 6
    static let successIconHeight: CGFloat = 72
    static let avatarSize: CGFloat = 88
    static let profileIconHeight: CGFloat = 96
    static let seatHeight: CGFloat = 25
    static let bookBadgeWidth: CGFloat = 62
    static let bookBadgeHeight: CGFloat = 26
    static let smallIcon: CGFloat = 28
}
