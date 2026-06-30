import Foundation

// release notes stay outside the settings viewmodel
enum AppChangelog {
    static let entries: [SettingsChangelogEntry] = [
        SettingsChangelogEntry(
            day: "June 15, 2026 (Monday)",
            title: "Initial setup and UIKit/MVVM structure",
            details: "Created the project, storyboard tabs, Models/View/ViewModel folders, outlet/action connections, table views, reusable cells, and the first Movies, Bookings, and Profile flows"
        ),
        SettingsChangelogEntry(
            day: "June 17, 2026 (Wednesday)",
            title: "Booking, profile, and persistence",
            details: "Added movie detail, assigned showings, peso pricing, seat selection, confirmation, account creation/login/logout/editing, session restore, validation, Keychain passwords, and FileManager JSON persistence"
        ),
        SettingsChangelogEntry(
            day: "June 19, 2026 (Friday)",
            title: "Movie data, posters, cinema rules, and seating",
            details: "Expanded movie data, ratings, schedules, offline posters, URL/cache fallback images, rating sort, predetermined showings, eight cinemas, standard/VIP pricing, varied seat layouts, and booking detail seat maps"
        ),
        SettingsChangelogEntry(
            day: "June 22, 2026 (Monday)",
            title: "Schedule, notifications, and architecture cleanup",
            details: "Added nested schedules, one-week dates, multiple showtimes, current date labels, local reminders without APNs, Clean Architecture folders, protocol DI, use cases, AppFactory, DTOs, and mappers"
        ),
        SettingsChangelogEntry(
            day: "June 23, 2026 (Tuesday)",
            title: "Plist settings, seat database, and UI polish",
            details: "Added plist settings, Settings menu, plist-backed seat layouts, shared UI constants, comments, tests, hidden technical paths, larger small fonts, warning fixes, reserved confirmed seats, and confirmed local booking reset controls"
        ),
        SettingsChangelogEntry(
            day: "June 24, 2026 (Wednesday)",
            title: "Showings expansion, map, sharing, and launch cleanup",
            details: "Renamed Movies tab to Showings, added Movies/Concerts/Seminars selection, event JSON and browsing screens, Locations MapKit pins and zoom buttons, ticket sharing, empty launch bookings, and separate device storage for runtime data"
        ),
        SettingsChangelogEntry(
            day: "June 25, 2026 (Thursday)",
            title: "Interactive cinema pins and showtime shortcuts",
            details: "Added MapKit pin callouts, Cinema Details, grouped assigned showtimes, preselected movie dates/times, scalable showtime lists, Apple Maps pins, and assigned-cinema-only booking"
        ),
        SettingsChangelogEntry(
            day: "June 29, 2026 (Monday)",
            title: "Concert/seminar booking and feature separation",
            details: "Kept the Showings category landing page, separated Concert and Seminar models/screens, added search and venue filters, coordinate-backed venues, live schedules, quantity booking, reminders, sharing, cancellation, history, venue details, app icon, and tests"
        ),
        SettingsChangelogEntry(
            day: "June 30, 2026 (Tuesday)",
            title: "TicketPlease reviews and release organization",
            details: "Applied the TicketPlease public brand and TP booking IDs, standardized Movie/Concert/Seminar list controls, replaced bundled reviews with account-owned FileManager JSON reviews, enforced booking and completed-showing eligibility, added one-review create/edit/delete rules, isolated testing controls in Developer Mode, and renamed starter content to the local Catalog"
        )
    ]
}
