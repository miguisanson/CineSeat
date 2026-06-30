# TicketPlease Live Readiness Checklist

This checklist separates implemented local features from work required before a public, multi-user release.

## Implemented

- [x] UIKit navigation for Showings, Bookings, Locations, and Profile
- [x] Separate Movie, Concert, and Seminar models, views, and view models
- [x] Uniform search, status, result count, rating order, and location controls
- [x] Predetermined movie cinemas and event venues
- [x] Cinema-specific seat layouts and reserved-seat checks
- [x] Quantity booking for concerts and seminars
- [x] Current relative dates and multiple daily showtimes for one week
- [x] MapKit pins, callouts, details, assigned showings, and zoom controls
- [x] Local notification reminders without APNs
- [x] Local account creation, email/password validation, login, editing, logout, and restored session
- [x] Keychain password storage
- [x] FileManager/Codable JSON persistence for profiles, bookings, and reviews
- [x] Plist persistence for settings and seat layouts
- [x] One account review per item with create, edit, delete, rating, and comment
- [x] Review eligibility checks confirmed ticket ownership and completed showing duration
- [x] Developer Mode isolates review simulation, notification testing, and destructive resets
- [x] Offline movie posters with URLSession/FileManager cache fallback
- [x] Unit coverage for catalog rules, persistence, validation, booking, sharing, reviews, maps, and settings

## Local Data Status

- [x] Seven bundled JSON files are separated by catalog responsibility
- [x] `CatalogStore` decodes DTOs and maps IDs into domain models
- [x] Bundled catalog files initialize `Documents/Catalog` on first use
- [x] New installations contain no generated accounts, bookings, or reviews
- [x] Runtime files are separate: `profiles.json`, `bookings.json`, and `reviews.json`
- [ ] Add catalog version migration so an App Store update can replace or migrate an older Documents catalog
- [ ] Replace fatal catalog-loading failure with recoverable error reporting and a user-facing retry state

The current JSON implementation is a local database substitute for one device. Editing the project JSON changes bundled release content, while user interactions write to the app container. It cannot synchronize two users or protect shared inventory. A live service requires a remote database and authenticated API.

## Production Blockers

- [ ] Implement a backend API and shared database for accounts, showings, capacities, bookings, ticket ownership, and reviews
- [ ] Replace local-only authentication with server authentication, secure password hashing, token refresh, logout/revocation, and account recovery
- [ ] Add transactional seat/ticket locking to prevent two devices purchasing the same inventory
- [ ] Integrate a PCI-compliant payment provider; never store card details directly
- [ ] Add server receipts, refunds, booking expiration, cancellation policy, and idempotent checkout
- [ ] Move ticket sharing to server-authoritative ownership with acceptance/revocation and audit history
- [ ] Add review moderation, reporting, rate limits, deletion policy, and server-side one-review enforcement
- [ ] Use APNs for venue cancellations, schedule changes, transfers, and reminders that must originate from the server
- [ ] Add API loading, empty, offline, timeout, retry, and maintenance states
- [ ] Add privacy policy, terms, consent, data export/deletion, and retention rules
- [ ] Confirm rights/licensing and attribution for movie metadata, TMDB images, event posters, and venue information

## Release Polish

- [ ] Choose the production bundle identifier and update the internal Xcode product/target names if the old `CineSeat` identifiers should be removed
- [ ] Configure production signing, capabilities, App Store Connect record, version/build numbers, and archive validation
- [ ] Add complete app icon sizes, screenshots, description, support URL, privacy labels, and age rating
- [ ] Perform VoiceOver, Dynamic Type, contrast, touch-target, keyboard, and reduced-motion checks
- [ ] Test compact and large iPhones plus supported iPads in portrait/landscape as applicable
- [ ] Add localization for user-facing strings, dates, times, and Philippine currency/locale behavior
- [ ] Add analytics and privacy-safe crash reporting
- [ ] Split remaining large legacy files such as `BookingFlowViewControllers.swift`, `ProfileViewControllers.swift`, and `Domain/UseCases.swift` by concrete type during continued maintenance
- [ ] Run full unit/UI regression tests on the release configuration and at least one physical device
- [ ] Disable Developer Mode for release builds or gate it behind a debug/internal entitlement

## Current Decision

The project is suitable for a local portfolio or classroom demonstration. It is not ready for a real multi-user launch until the Production Blockers are completed, especially backend inventory, authentication, payment, and server-authoritative ownership.
