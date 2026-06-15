# CineSeat

CineSeat is a UIKit cinema-seat booking prototype based on the supplied Figma wireframe. It uses simulated movie and booking data, so no real payment or reservation is made.

## Features

- Search and filter the movie table view
- View movie details, dates, and showtimes
- Select available seats from a 7-row seat map
- Review ticket price, booking fee, and total
- Confirm a booking and receive a booking ID
- View booking history and cancel confirmed bookings
- Browse the Info and seat-legend screen

## Project Structure

- `Models.swift`: `Movie`, `Booking`, `BookingDraft`, sample data, and `BookingStore`
- `ViewModels.swift`: movie filtering and seat-selection business logic
- `ViewController.swift`: Movies table view screen
- `BookingFlowViewControllers.swift`: detail, seat, summary, and confirmation screens
- `BookingsViewControllers.swift`: booking list, booking detail, and Info screens
- `UIComponents.swift`: reusable cells, cards, buttons, theme, and scroll layout

## Storyboard Connections

`Main.storyboard` owns the main tab bar and its three navigation controllers.

The Movies scene connects:

- `movieTableView` outlet
- `searchBar` outlet and delegate
- `categorySegmentedControl` outlet
- `categoryChanged:` action
- table view data source and delegate

The My Bookings scene connects:

- `bookingsTableView` outlet
- `countLabel` outlet
- table view data source and delegate

All storyboard views use Auto Layout. The booking-flow screens use `UIStackView` inside `UIScrollView` so they also fit compact devices such as iPhone SE.

## Architecture

The project follows a small MVVM structure:

- Model: movie, booking, and booking-draft data
- View: storyboard scenes, table cells, buttons, labels, and stack views
- ViewModel: filtering, reserved-seat validation, selected-seat ordering, and price calculation

## Run

Open `CineSeat.xcodeproj`, select the `CineSeat` scheme, choose an iPhone simulator, and press Run.
