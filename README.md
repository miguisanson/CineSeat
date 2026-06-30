# TicketPlease

TicketPlease is a UIKit showing and ticket-booking app for movies, concerts, and seminars.

## Features

- Choose between Movies, Concerts, and Seminars from the Showings tab
- Search Movies, Concerts, and Seminars independently
- Filter all three categories by All, Now Showing, or Coming Soon
- Sort all three categories by highest or lowest effective rating
- Open a separate reviews page from any detail screen
- Keep online ratings separate from TicketPlease user averages and use the app average as fallback
- Book concerts and seminars by date, time, and ticket quantity without seat selection
- View event venue MapKit previews and event venue pins in Locations
- Load bundled movie poster images offline, with online cache fallback when needed
- View movie details and scheduled showings
- Block seat booking for Coming Soon movies
- Use fixed cinema schedules: 6 standard cinemas at ₱350 and 2 VIP cinemas at ₱550
- Select available seats from cinema-specific seat maps
- Review ticket price, booking fee, and total
- Confirm a booking and receive a booking ID
- Share a purchased seat ticket to another local account by email
- View booking history after login and cancel confirmed bookings
- Switch the native MapKit Locations tab between cinemas and event venues
- Keep bookings after the app is closed and reopened
- Save movie and booking-filter preferences
- Create an account, log in, edit a profile, and log out
- Restore the signed-in profile after relaunch

## Project Structure

- `Models/Showings/`: shared category, status filter, rating sort, and ticket schedule wrapper types
- `Models/Movies/`: movie, cinema, showing, category, and cinema type structs/enums
- `Models/Concerts/Concert.swift`: concrete concert model decoded from `Concerts.json`
- `Models/Seminars/Seminar.swift`: concrete seminar model decoded from `Seminars.json`
- `Models/Locations/`: shared cinema/event venue map values
- `Models/Booking/`: booking, ticket assignment, draft, status, and seat layout structs/enums
- `Models/Profile/`: profile, seed account, authentication error, and account validation structs/enums
- `Models/Reviews/`: review, subject, content type, and online/app rating summary values
- `Persistence/SeedData/Cinemas.json`: cinema names, prices, types, and MapKit coordinates
- `Persistence/SeedData/Movies.json`: movie details, ratings, categories, posters, and poster URLs
- `Persistence/SeedData/Concerts.json`: concert, festival, orchestra, and theater examples with online poster URLs
- `Persistence/SeedData/Seminars.json`: seminar and conference examples with online poster URLs
- `Persistence/SeedData/EventVenues.json`: reusable event addresses and map coordinates
- `Persistence/SeedData/EventShowings.json`: live relative dates, times, venue IDs, prices, and capacities
- `Persistence/SeedData/Showings.json`: nested movie schedule dates and assigned cinema times
- `Persistence/SeedData/Bookings.json`: intentionally empty launch booking file so the app starts without fake booking history
- `Persistence/SeedData/ProfileAccounts.json`: the single starter profile used for local login
- `Persistence/SeedData/Reviews.json`: 60 casual TicketPlease reviews covering every movie, concert, and seminar
- `PosterImages/`: bundled poster image files used for offline display
- `Persistence/SeedData/`: JSON DTOs, decoder loader, mapper, and seed data entry point
- `Persistence/Shared/`: reusable JSON FileManager reader/writer helpers
- `Persistence/Booking/`: booking JSON repository and booking store
- `Persistence/Profile/`: profile JSON repository, Keychain passwords, authentication service, and session storage
- `Persistence/Reviews/BundledReviewRepository.swift`: FileManager/JSONDecoder review data source
- `Persistence/AppPreferences.swift`: UserDefaults preferences and flags
- `Domain/DependencyProtocols.swift`: protocol-based DI contracts for movie/event fetch, preferences, bookings, and auth
- `Domain/UseCases.swift`: movie/event browsing, booking, confirmation, ticket sharing, and cancellation use cases
- `Domain/Reviews/`: protocol-based review fetching, filtering, and rating-summary use case
- `ViewModel/ShowingsViewModel.swift`: Showings landing category counts
- `ViewModel/MoviesViewModels.swift`: movie search, category filtering, rating sorting, and movie count text
- `ViewModel/Concerts/ConcertViewModels.swift`: concert-only search, status, rating, and venue filtering
- `ViewModel/Seminars/SeminarViewModels.swift`: seminar-only search, status, rating, and venue filtering
- `ViewModel/Reviews/ReviewsViewModel.swift`: review ordering and online/app rating presentation
- `ViewModel/TicketedShowingScheduleViewModel.swift`: shared date, time, venue, quantity, and total rules
- `ViewModel/BookingViewModels.swift`: booking filtering, fixed showing selection, and seat-selection business logic
- `ViewModel/ProfileViewModels.swift`: login, registration, and profile business logic
- `View/ShowingsViewController.swift`: Showings landing screen
- `View/MoviesViewController.swift`: Movies table view screen
- `View/Concerts/`: concert list and concrete detail controllers
- `View/Seminars/`: seminar list and concrete detail controllers
- `View/TicketedShowingListViewController.swift`: reusable list layout used by the two concrete category controllers
- `View/TicketedShowingDetailViewController.swift`: shared map, schedule, and quantity layout
- `View/TicketedShowingBookingSummaryViewController.swift`: shared concert/seminar checkout summary
- `View/Reviews/ReviewsViewController.swift`: separate user reviews and rating-source screen
- `View/BookingFlowViewControllers.swift`: detail, seat, summary, and confirmation screens
- `View/BookingsViewControllers.swift`: booking list and booking detail screens
- `View/CinemaLocationsViewController.swift`: filtered MapKit cinema/event venue pins and zoom controls
- `View/ShowingVenueDetailViewController.swift`: concerts/seminars assigned to a selected venue pin
- `View/CinemaDetailViewController.swift`: cinema information and assigned movie schedules from a selected pin
- `View/ProfileViewControllers.swift`: Profile tab and account screens
- `Design/AppFactory.swift`: factory pattern and composition root for dependencies
- `CustomViews/`: reusable theme, cards, poster view, movie/event/review cells, scroll container, and custom seating views
- `CINESEAT_ONE_PAGE.md`: compact TicketPlease application overview and lecture-module reflection

## Storyboard Connections

`Main.storyboard` owns the Showings, Bookings, Locations, and Profile navigation tabs.

The Showings scene is the root of the first tab. It opens:

- Movies
- Concerts
- Seminars

The Movies scene connects:

- `movieTableView` outlet
- `searchBar` outlet and delegate
- `categorySegmentedControl` outlet
- `categoryChanged:` action
- table view data source and delegate

The Profile scene connects:

- `scrollView` outlet
- `contentStack` outlet
- `signedOutButtonStackView` outlet using a horizontal `UIStackView`
- `profileLoginButton` outlet and `profileLoginButtonTapped:` action
- `profileCreateAccountButton` outlet and `profileCreateAccountButtonTapped:` action

The My Bookings scene connects:

- `bookingsTableView` outlet
- `countLabel` outlet
- `showCancelledSwitch` outlet
- `showCancelledChanged:` action
- table view data source and delegate

All storyboard views use Auto Layout. The booking-flow screens use `UIStackView` inside `UIScrollView` so they also fit compact devices such as iPhone SE. The seating UI is a custom UIKit view made from vertical and horizontal `UIStackView` rows with `UIButton` seats, so every cinema can have a different row count, aisle position, reserved seats, and unavailable seats.

## Architecture

The project follows a small MVVM and clean architecture structure:

- Presentation: storyboard scenes, view controllers, view models, table cells, buttons, labels, and stack views
- Domain: protocol-based DI contracts and use cases for fetching movies/events, filtering bookings, confirming bookings, cancelling bookings, and authentication access
- Design: shared UI theme, reusable custom views, layout helpers, and the factory that composes dependencies
- Model/Data: movie, event, booking, draft, profile, storage repository, and authentication service

## Module 5 Persistence

- `UserDefaults` stores the first-launch flag, selected movie category, and the Show Cancelled Bookings setting.
- `Movie`, `Cinema`, and `Booking` conform to `Codable`.
- `BookingFileRepository` gets the Documents directory with `FileManager`.
- Bookings are encoded to `bookings.json` and decoded when the app starts.
- Creating a booking inserts and saves it. Cancelling a booking updates and saves it.
- `BookingItem` distinguishes movie and event records inside the same `bookings.json` file.
- Each saved booking includes `TicketAssignment` rows so seats or numbered event tickets can be transferred by email.
- New installs start with no booking history, so My Bookings stays empty until a signed-in user confirms a booking.

Core Data is not used because the current data is small and the Codable/FileManager approach is sufficient. Account passwords use Keychain because they are sensitive and must not be stored in UserDefaults or plain JSON.

## Runtime Data

- Bundled JSON files in `Persistence/SeedData` are read-only starter data copied into the app bundle.
- Seeded TicketPlease reviews are read from `Reviews.json`; they are currently demo content rather than user-editable records.
- New bookings are written to the app container Documents file `bookings.json`.
- New profile metadata is written to the app container Documents file `profiles.json`.
- Passwords are written to Keychain, not JSON.
- Settings are written to the app container Documents file `CineSeatSettings.plist`.
- Seat layouts are copied from the bundled plist into the app container Documents area so the app can treat them like an editable local database.

## Profile Accounts

- Profile metadata is encoded to `profiles.json` in the Documents directory.
- Passwords are stored separately in the iOS Keychain and are never written to JSON or UserDefaults.
- UserDefaults stores only the current signed-in profile ID so the session can be restored.
- Multiple local accounts are supported and duplicate email addresses are rejected.
- Registration validates the name, email format, password strength, and password confirmation.
- The Profile tab automatically changes between signed-out and signed-in interfaces.

## Run

Open `CineSeat.xcodeproj`, select the `CineSeat` scheme, choose an iPhone simulator, and press Run.
