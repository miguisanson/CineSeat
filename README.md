# CineSeat

CineSeat is a UIKit cinema-seat booking app based on the supplied Figma wireframe. It uses local movie, account, and booking data for the class build.

## Features

- Search and filter the movie table view
- Sort All, Now Playing, and Coming Soon movies by highest or lowest rating
- Load bundled movie poster images offline, with online cache fallback when needed
- View movie details and scheduled showings
- Block seat booking for Coming Soon movies
- Use fixed cinema schedules: 6 standard cinemas at ₱350 and 2 VIP cinemas at ₱550
- Select available seats from cinema-specific seat maps
- Review ticket price, booking fee, and total
- Confirm a booking and receive a booking ID
- View booking history after login and cancel confirmed bookings
- Keep bookings after the app is closed and reopened
- Save movie and booking-filter preferences
- Create an account, log in, edit a profile, and log out
- Restore the signed-in profile after relaunch

## Project Structure

- `Models/Movies/`: movie, cinema, showing, category, rating sort, and cinema type structs/enums
- `Models/Booking/`: booking, draft, status, and seat layout structs/enums
- `Models/Profile/`: profile, sample account, authentication error, and account validation structs/enums
- `Persistence/SampleData/SampleDataJson.json`: seeded movies, cinema schedules, bookings, and profile accounts used by the local demo data source
- `PosterImages/`: bundled poster image files used for offline display
- `Persistence/SampleData/`: JSON DTOs, decoder loader, mapper, and sample data entry point
- `Persistence/Shared/`: reusable JSON FileManager reader/writer helpers
- `Persistence/Booking/`: booking JSON repository and booking store
- `Persistence/Profile/`: profile JSON repository, Keychain passwords, authentication service, and session storage
- `Persistence/AppPreferences.swift`: UserDefaults preferences and flags
- `Domain/DependencyProtocols.swift`: protocol-based DI contracts for API fetch, preferences, bookings, and auth
- `Domain/UseCases.swift`: movie, booking, confirmation, and cancellation use cases
- `ViewModel/MoviesViewModels.swift`: movie search, category filtering, rating sorting, and movie count text
- `ViewModel/BookingViewModels.swift`: booking filtering, fixed showing selection, and seat-selection business logic
- `ViewModel/ProfileViewModels.swift`: login, registration, and profile business logic
- `View/MoviesViewController.swift`: Movies table view screen
- `View/BookingFlowViewControllers.swift`: detail, seat, summary, and confirmation screens
- `View/BookingsViewControllers.swift`: booking list and booking detail screens
- `View/ProfileViewControllers.swift`: Profile tab and account screens
- `Design/AppFactory.swift`: factory pattern and composition root for dependencies
- `CustomViews/`: reusable theme, cards, poster view, table cells, scroll container, and custom seating views
- `CINESEAT_ONE_PAGE.md`: compact application overview and lecture-module reflection

## Storyboard Connections

`Main.storyboard` owns the Movies, Bookings, and Profile navigation tabs.

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
- Domain: protocol-based DI contracts and use cases for fetching movies, filtering bookings, confirming bookings, cancelling bookings, and authentication access
- Design: shared UI theme, reusable custom views, layout helpers, and the factory that composes dependencies
- Model/Data: movie, booking, draft, profile, storage repository, and authentication service

## Module 5 Persistence

- `UserDefaults` stores the first-launch flag, selected movie category, and the Show Cancelled Bookings setting.
- `Movie`, `Cinema`, and `Booking` conform to `Codable`.
- `BookingFileRepository` gets the Documents directory with `FileManager`.
- Bookings are encoded to `bookings.json` and decoded when the app starts.
- Creating a booking inserts and saves it. Cancelling a booking updates and saves it.
- New installs start with no booking history, so My Bookings stays empty until a signed-in user confirms a booking.

Core Data is not used because the current data is small and the Codable/FileManager approach is sufficient. Account passwords use Keychain because they are sensitive and must not be stored in UserDefaults or plain JSON.

## Profile Accounts

- Profile metadata is encoded to `profiles.json` in the Documents directory.
- Passwords are stored separately in the iOS Keychain and are never written to JSON or UserDefaults.
- UserDefaults stores only the current signed-in profile ID so the session can be restored.
- Multiple local accounts are supported and duplicate email addresses are rejected.
- Registration validates the name, email format, password strength, and password confirmation.
- The Profile tab automatically changes between signed-out and signed-in interfaces.

## Run

Open `CineSeat.xcodeproj`, select the `CineSeat` scheme, choose an iPhone simulator, and press Run.
