# TicketPlease

TicketPlease is a UIKit ticket-booking application for movies, concerts, and seminars. It uses MVVM, Clean Architecture boundaries, protocol-based dependency injection, and local FileManager persistence.

## Features

- Showings landing page with separate Movies, Concerts, and Seminars flows
- Uniform title, search, status, result count, rating order, and location controls
- Predetermined cinema/venue schedules with current dates and multiple showtimes
- Cinema-specific seat maps for movies and quantity booking for events
- Six standard cinemas at PHP 350 and two VIP cinemas at PHP 550
- Booking summary, `TP` booking ID, local history, cancellation, and ticket sharing by account email
- Cinema/event venue MapKit pins, callouts, assigned showings, and zoom controls
- Local reminders through `UserNotifications` without APNs
- Account registration, validation, duplicate-email prevention, login, profile editing, restored session, and Keychain passwords
- Read-only reviews from Showings and booking-owned review writing from Booking Detail after showtime
- One TicketPlease numerical rating/comment per account and item with edit/delete
- Separate TMDB online written reviews for movies without merging them into TicketPlease reviews
- Developer Mode for unlimited review testing, notification tests, and confirmed data resets
- Bundled offline movie posters with cache and URLSession fallback

## Architecture

- `Models/`: Codable/value models separated by Movies, Concerts, Seminars, Showings, Booking, Reviews, Profile, Settings, and Locations
- `Persistence/LocalContent/`: seven bundled content JSON files plus DTO, mapper, error, loader, and entry point
- `Persistence/Booking/`: `bookings.json` repository and store
- `Persistence/Profile/`: `profiles.json`, Keychain password store, session store, and authentication service
- `Persistence/Reviews/`: `reviews.json` repository and one-review-per-account store
- `Persistence/Settings/` and `Persistence/SeatLayouts/`: plist repositories
- `Persistence/Shared/`: reusable JSON reader/writer
- `Domain/`: protocol contracts and use cases
- `ViewModel/`: presentation logic separated by feature
- `View/`: storyboard-backed and programmatic UIKit controllers
- `CustomViews/`: cells, shared headers, settings rows, maps, theme, cards, posters, scroll containers, and seat map controls
- `Design/AppFactory.swift`: dependency composition root
- `Constants/`: brand, pricing, notification values, UI tokens, dates, duration parsing, booking IDs, and changelog content

## Local JSON Content

The local content is split into:

- `Cinemas.json`
- `Movies.json`
- `Concerts.json`
- `Seminars.json`
- `EventVenues.json`
- `EventShowings.json`
- `Showings.json`

`LocalContentStore` uses `JSONFileReader` and `JSONDecoder` to load these files. On first use it copies each bundled file to `Documents/LocalContent`, then `LocalContentMapper` resolves cinema, venue, event, and schedule IDs into app models. `AppContent` exposes the mapped values to protocol-backed local clients.

This is functional local/offline content storage, but it is not a shared production database. It cannot synchronize devices or enforce global inventory. See `TICKETPLEASE_LIVE_READINESS_CHECKLIST.md`.

## Runtime Persistence

- User-created bookings: `Documents/bookings.json`
- User-created profiles: `Documents/profiles.json`
- User-created reviews: `Documents/reviews.json`
- Settings: `Documents/CineSeatSettings.plist`
- Seat layouts: editable Documents copy of `SeatLayouts.plist`
- Signed-in profile ID and small preferences: UserDefaults
- Passwords: iOS Keychain
- Downloaded posters: Caches/PosterCache

New installs have no generated account, booking, or review records. Core Data is not used.

## Reviews

The Review feature is separated across Model, Persistence, Domain, ViewModel, View, and CustomViews. Showing details can read reviews but cannot write them. Writing is available from the matching Booking Detail only when:

1. An account is signed in.
2. That account owns a ticket assignment for the item.
3. The booking is confirmed.
4. The scheduled start time has passed.

`ReviewStore` updates an existing review instead of inserting a duplicate for the same profile and subject. Only its author profile ID can edit or delete it. Developer Mode's **Unlimited review testing** switch bypasses the time rule and permits repeated local test reviews from Booking Detail.

The Reviews screen has separate **TicketPlease** and **Online** segments. Online movie comments use TMDB's movie reviews endpoint and never enter `reviews.json` or the TicketPlease average. The development token is stored only in the local Xcode user scheme under `TMDB_READ_ACCESS_TOKEN`; it is not stored in app source or documentation. Before a live release, remove and rotate that token, obtain the required production/commercial access, and keep the replacement credential on a backend rather than in the distributed iOS app. Concert and seminar online written reviews remain unavailable until a suitable provider is added.

All rating displays use the shared `RatingDisplayFormatter` and the same `4.7 / 5.0` format. `ShowingMetadataFormatter` also keeps duration capitalization and movie/event metadata consistent across list, detail, summary, and saved-booking screens.

## Storyboard and Layout

`Main.storyboard` owns the Showings, Bookings, Locations, and Profile navigation tabs. The Movies scene demonstrates `IBOutlet` and `IBAction` connections for its table, search bar, segmented control, and category action. Profile and Bookings also retain storyboard connections.

Programmatic screens use Auto Layout, safe-area anchors, reusable table cells, and `UIStackView` inside `UIScrollView`. `ShowingListTableHeaderView` keeps Movie, Concert, and Seminar result controls in the same order. `SeatMapView` builds vertical rows containing horizontal seat stacks and explicit aisle spaces, allowing different layouts per cinema.

## Run and Test

Open `CineSeat.xcodeproj`, select the `CineSeat` scheme, choose an iOS 17.5 simulator, and run.

Unit tests cover local content rules, schedules, maps, seats, booking persistence, sharing, settings, authentication, Keychain, local/online review separation, ownership, and scheduled-time eligibility. UI tests cover read-only Showing reviews, sort direction, movie/event routing, booking access, and account flows.
