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
- Account-owned reviews with one rating/comment per showing, edit/delete, and completed-booking eligibility
- Developer Mode for isolated eligibility simulation, notification tests, and confirmed data resets
- Bundled offline movie posters with cache and URLSession fallback

## Architecture

- `Models/`: Codable/value models separated by Movies, Concerts, Seminars, Showings, Booking, Reviews, Profile, Settings, and Locations
- `Persistence/Catalog/`: seven local content JSON files plus catalog DTO, mapper, error, loader, and entry point
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

## Local JSON Catalog

The catalog is split into:

- `Cinemas.json`
- `Movies.json`
- `Concerts.json`
- `Seminars.json`
- `EventVenues.json`
- `EventShowings.json`
- `Showings.json`

`CatalogStore` uses `JSONFileReader` and `JSONDecoder` to load these files. On first use it copies each bundled file to `Documents/Catalog`, then `CatalogMapper` resolves cinema, venue, event, and schedule IDs into app models. `AppCatalog` exposes the mapped content to protocol-backed local clients.

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

The Review feature is separated across Model, Persistence, Domain, ViewModel, View, and CustomViews. A review is eligible only when:

1. An account is signed in.
2. That account owns a ticket assignment for the item.
3. The booking is confirmed.
4. The scheduled start plus the movie/event duration has passed.

`ReviewStore` updates an existing review instead of inserting a duplicate for the same profile and subject. Only its author profile ID can edit or delete it. Developer Mode can simulate eligibility for local presentation testing.

## Storyboard and Layout

`Main.storyboard` owns the Showings, Bookings, Locations, and Profile navigation tabs. The Movies scene demonstrates `IBOutlet` and `IBAction` connections for its table, search bar, segmented control, and category action. Profile and Bookings also retain storyboard connections.

Programmatic screens use Auto Layout, safe-area anchors, reusable table cells, and `UIStackView` inside `UIScrollView`. `ShowingListTableHeaderView` keeps Movie, Concert, and Seminar result controls in the same order. `SeatMapView` builds vertical rows containing horizontal seat stacks and explicit aisle spaces, allowing different layouts per cinema.

## Run and Test

Open `CineSeat.xcodeproj`, select the `CineSeat` scheme, choose an iOS 17.5 simulator, and run.

Unit tests cover catalog rules, schedules, maps, seats, booking persistence, sharing, settings, authentication, Keychain, review persistence, ownership, and completed-showing eligibility. UI tests cover movie/event review routing, booking access, and account flows.
