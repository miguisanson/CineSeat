# TicketPlease: Application and Module Reflection

**Platform:** iOS 17.5 | **Language/UI:** Swift 5 and UIKit | **Architecture:** MVVM with protocol-based DI | **Storage:** local JSON, plist, UserDefaults, Keychain, and FileManager | **Core Data:** not used

## Application Overview

TicketPlease books movies, concerts, and seminars. **Showings** opens separate category cards. Each category page uses the same order: title, search, All/Now Showing/Coming Soon control, result count, rating order, location filter, then results. Movie schedules already determine the cinema and use cinema-specific seat maps. Concerts and seminars determine the venue and use ticket quantity instead of seats. Detail pages provide schedules, maps, ratings, and user reviews. Booking requires login, saves locally, supports cancellation and per-ticket email sharing, and schedules local reminders. **Locations** displays MapKit cinema and event-venue pins with assigned showings. **Profile** provides account creation, login, editing, restored sessions, Settings, and a separate Developer Mode page.

Reviews contain no bundled posts. A signed-in account can create one rating/comment per movie, concert, or seminar only when it owns a confirmed ticket and the scheduled start time plus catalog duration has passed. The same account can edit or delete its review. Reviews are stored in Documents as `reviews.json`. Developer Mode can locally simulate eligibility for presentation testing without weakening the normal rule.

**Main flow:** Showings -> Category -> Search/Status/Rating/Location -> Detail -> Reviews. Movie -> Date/Time -> Seats -> Summary -> Confirmation. Concert/Seminar -> Date/Time -> Quantity -> Summary -> Confirmation. Locations -> Pin -> Assigned Showings. Profile -> Account -> Settings -> Developer Mode.

## Lecture Module Reflection

| Module | How TicketPlease Applies the Concepts |
| --- | --- |
| **1: Swift Fundamentals** | Uses constants/variables, Swift data types, arrays, dictionaries, sets, optionals, operators, conditions, loops, functions, enums, structs, classes, protocols, error handling, `Codable`, `JSONEncoder`, and `JSONDecoder`. ARC is handled with weak outlets and `[weak self]`. |
| **2: UIKit and MVVM** | Storyboard scenes use outlets/actions for the main tabs. Programmatic UIKit screens use Auto Layout, `UIScrollView`, vertical/horizontal `UIStackView`, table views, reusable cells, search bars, segmented controls, menus, alerts, MapKit, `UIDatePicker`, and custom seat views. Models, Views, and ViewModels have separate responsibilities. |
| **3: Intermediate Swift** | Closures support filtering, sorting, alerts, and notifications. `map`, `filter`, `reduce`, `sorted`, and `first(where:)` handle content and bookings. Protocols isolate repositories/services. Local notifications use `UserNotifications`; UI work returns to the main thread. |
| **4: Networking and Dependencies** | `PosterPlaceholderView` checks bundled images, the FileManager cache, then downloads with `URLSession`. Movie poster fallback URLs use TMDB image CDN paths, but the app does not call the full TMDB API. MapKit and UIKit are native dependencies; no CocoaPods are required. |
| **5: Data Persistence and Security** | `CatalogStore` decodes seven category JSON files and initializes a writable `Documents/Catalog` copy. `BookingFileRepository`, `ProfileFileRepository`, and `ReviewFileRepository` save user-created records to separate JSON files. Settings and seat layouts use plist repositories. UserDefaults stores small preferences/session ID, while passwords use Keychain. |
| **6: Clean Architecture and DI** | Presentation is in `View`/`ViewModel`; contracts and use cases are in `Domain`; persistence is separated by feature; and `AppFactory` is the composition root. Movie/event clients, repositories, authentication, reviews, settings, notifications, and booking actions are injected through protocols. Shared list headers and settings rows remove duplicated UI code. |

## Data Scope

The catalog JSON is a functional **local app catalog**, not a shared internet database. It is suitable for offline coursework and local testing. Bookings, profiles, and reviews are created by the user and stay inside that installation's app container. A production launch still needs a server API/database for shared accounts, inventory locking, payments, synchronized reviews, cancellations, and cross-device ticket transfers. See `TICKETPLEASE_LIVE_READINESS_CHECKLIST.md`.

## Development Change List

- **June 15, 2026 (Monday) - Initial UIKit/MVVM setup:** Created the project from the wireframe, storyboard tabs, Models/View/ViewModel folders, outlets/actions, table views, reusable cells, and initial Movies, Bookings, and Profile flows.
- **June 17, 2026 (Wednesday) - Booking, profile, and persistence:** Added movie details, scheduled cinemas, peso pricing, seats, checkout, account creation/login/editing/logout, validation, duplicate-email checks, restored sessions, JSON persistence, Keychain passwords, and offline posters.
- **June 19, 2026 (Friday) - Catalog, cinema rules, and seating:** Expanded movie content and ratings, added schedules, filters/sorting, URL/cache poster fallback, eight standard/VIP cinemas, varied seat maps, reserved states, and booking-detail seat maps.
- **June 22, 2026 (Monday) - Schedules, notifications, and DI:** Added nested dates/times, one-week schedules, multiple daily showtimes, live date labels, local reminders without APNs, protocol-based DI, use cases, `AppFactory`, DTOs, and mappers.
- **June 23, 2026 (Tuesday) - Plist and UI polish:** Added plist settings and seat layouts, shared fonts/spacing/sizes, settings/changelog screens, larger minimum fonts, warning fixes, persisted reserved seats, and confirmed local reset controls.
- **June 24, 2026 (Wednesday) - Showings, maps, and sharing:** Added the Showings category landing page, separate concert/seminar JSON and screens, Locations MapKit pins/zoom, event schedules and quantities, ticket assignments/sharing, empty launch booking data, and separate runtime storage.
- **June 25, 2026 (Thursday) - Interactive location details:** Added pin callouts, Cinema Details, grouped assigned schedules, tappable showtime chips, date/time preselection, scalable showtime lists, and assigned-cinema-only booking.
- **June 29, 2026 (Monday) - Event booking separation:** Separated Concert and Seminar models, view models, and controllers; added search/status/rating/venue filters, venue maps, quantity checkout, reminders, sharing, cancellation/history, app icon, and test coverage.
- **June 30, 2026 (Tuesday) - TicketPlease reviews and release organization:** Applied the public TicketPlease brand and `TP` booking IDs; standardized Movie/Concert/Seminar list placement; removed generated accounts, bookings, and reviews; added persistent account-owned review create/edit/delete with completed-showing eligibility; isolated test controls in Developer Mode; renamed starter content to `Catalog`; extracted shared list/settings views, duration parsing, and changelog data; and added the live-readiness checklist.
