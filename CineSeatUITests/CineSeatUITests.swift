import XCTest

// module 2 ui tests
// these tap the same storyboard buttons and table cells shown in the app
final class CineSeatUITests: XCTestCase {
    override func setUpWithError() throws {
        // stop the test early when a ui step fails
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // no teardown steps needed yet
    }

    func testMovieToSeatSelectionFlow() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["TicketPlease Showings"].waitForExistence(timeout: 3))
        let moviesCategory = app.buttons["showingCategory_Movies"]
        XCTAssertTrue(moviesCategory.waitForExistence(timeout: 3))
        moviesCategory.tap()
        app.segmentedControls.buttons["All"].tap()

        let firstMovie = app.tables.cells["movieCell_Star Wars: Episode IV - A New Hope"]
        XCTAssertTrue(firstMovie.waitForExistence(timeout: 3))
        firstMovie.tap()

        XCTAssertTrue(app.navigationBars["Movie Detail"].waitForExistence(timeout: 2))
        app.buttons["movieReviewsButton"].tap()
        XCTAssertTrue(app.navigationBars["Reviews"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.segmentedControls["reviewSourceControl"].exists)
        XCTAssertFalse(app.buttons["reviewActionButton"].exists)
        app.navigationBars["Reviews"].buttons["Movie Detail"].tap()
        app.buttons["SELECT SEATS"].tap()

        XCTAssertTrue(app.navigationBars["Select Seats"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["CONTINUE"].exists)
    }

    func testCancelledBookingPreferenceIsConnected() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetProfileSessionForUITests"]
        app.launch()
        app.tabBars.buttons["Bookings"].tap()

        let showCancelledSwitch = app.switches.element(boundBy: 0)
        XCTAssertTrue(showCancelledSwitch.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["LOG IN TO VIEW BOOKINGS"].waitForExistence(timeout: 2))
    }

    func testConcertCanOpenTicketQuantityAndSummary() throws {
        let app = XCUIApplication()
        app.launch()

        let concertsCategory = app.buttons["showingCategory_Concerts"]
        XCTAssertTrue(concertsCategory.waitForExistence(timeout: 3))
        concertsCategory.tap()
        XCTAssertTrue(app.segmentedControls["concertsStatusFilter"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["concertsRatingSort"].exists)

        let concert = app.tables.cells["eventCell_Taylor Swift: The Eras Tour"]
        XCTAssertTrue(concert.waitForExistence(timeout: 3))
        concert.tap()

        XCTAssertTrue(app.navigationBars["Concert"].waitForExistence(timeout: 2))
        app.buttons["ticketedShowingReviewsButton"].tap()
        XCTAssertTrue(app.navigationBars["Reviews"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.segmentedControls["reviewSourceControl"].exists)
        XCTAssertFalse(app.buttons["reviewActionButton"].exists)
        app.navigationBars["Reviews"].buttons["Concert"].tap()
        XCTAssertTrue(app.steppers["eventTicketQuantityStepper"].exists)
        let bookButton = app.buttons["bookEventTicketsButton"]
        XCTAssertTrue(bookButton.exists)
        for _ in 0..<6 where !bookButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(bookButton.isHittable)
        XCTAssertTrue(bookButton.isEnabled)
        sleep(1)
        bookButton.tap()
        sleep(1)
        XCTAssertTrue(app.navigationBars["Booking Summary"].exists)
        XCTAssertTrue(app.staticTexts["TICKETS"].exists)
    }

    func testShowingListControlsUseTheSameVerticalOrder() {
        let app = XCUIApplication()
        app.launch()

        assertShowingHeaderOrder(
            app: app,
            category: "Movies",
            countIdentifier: "moviesResultCount",
            ratingIdentifier: "moviesRatingSort",
            locationIdentifier: "moviesCinemaFilter"
        )
        assertShowingHeaderOrder(
            app: app,
            category: "Concerts",
            countIdentifier: "concertsResultCount",
            ratingIdentifier: "concertsRatingSort",
            locationIdentifier: "concertsVenueFilter"
        )
        assertShowingHeaderOrder(
            app: app,
            category: "Seminars",
            countIdentifier: "seminarsResultCount",
            ratingIdentifier: "seminarsRatingSort",
            locationIdentifier: "seminarsVenueFilter"
        )
    }

    func testCreateAccountLogoutAndLogin() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetProfileSessionForUITests"]
        app.launch()
        app.tabBars.buttons["Profile"].tap()

        app.buttons["profileCreateAccountButton"].tap()
        XCTAssertTrue(app.navigationBars["Create Account"].waitForExistence(timeout: 2))

        let uniqueEmail = "mia.reyes\(Int(Date().timeIntervalSince1970 * 1000))@example.com"
        app.textFields["createNameField"].tap()
        app.textFields["createNameField"].typeText("Mia Reyes")
        app.textFields["createEmailField"].tap()
        app.textFields["createEmailField"].typeText(uniqueEmail)
        app.textFields["createPhoneField"].tap()
        app.textFields["createPhoneField"].typeText("09171234567")
        app.secureTextFields["createPasswordField"].tap()
        app.secureTextFields["createPasswordField"].typeText("MoviePass2026")
        app.secureTextFields["createConfirmPasswordField"].tap()
        app.secureTextFields["createConfirmPasswordField"].typeText("MoviePass2026")
        app.buttons["createAccountSubmitButton"].tap()

        let profileName = app.staticTexts["Mia Reyes"]
        if !profileName.waitForExistence(timeout: 3) {
            let alertText = app.alerts.element.staticTexts.allElementsBoundByIndex
                .map(\.label)
                .joined(separator: " | ")
            XCTFail("Profile was not created. Alert: \(alertText)")
        }
        app.buttons["logoutButton"].tap()
        app.alerts.buttons["Log Out"].tap()
        XCTAssertTrue(app.buttons["profileLoginButton"].waitForExistence(timeout: 2))

        app.buttons["profileLoginButton"].tap()
        app.textFields["loginEmailField"].tap()
        app.textFields["loginEmailField"].typeText(uniqueEmail)
        app.secureTextFields["loginPasswordField"].tap()
        app.secureTextFields["loginPasswordField"].typeText("MoviePass2026")
        app.buttons["loginSubmitButton"].tap()

        XCTAssertTrue(app.staticTexts["Mia Reyes"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["editProfileButton"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // basic launch timing from the xcode template
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    private func assertShowingHeaderOrder(
        app: XCUIApplication,
        category: String,
        countIdentifier: String,
        ratingIdentifier: String,
        locationIdentifier: String
    ) {
        let categoryButton = app.buttons["showingCategory_\(category)"]
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 3))
        categoryButton.tap()

        let count = app.staticTexts[countIdentifier]
        let rating = app.buttons[ratingIdentifier]
        let location = app.buttons[locationIdentifier]
        XCTAssertTrue(count.waitForExistence(timeout: 3))
        XCTAssertTrue(rating.exists)
        XCTAssertTrue(location.exists)
        XCTAssertLessThan(count.frame.minY, rating.frame.minY)
        XCTAssertLessThan(rating.frame.minY, location.frame.minY)
        XCTAssertTrue(rating.label.contains("↓"))
        rating.tap()
        XCTAssertTrue(rating.label.contains("↑"))

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
}

/// Demo drivers for the training-video screen recordings.
///
/// These are not assertion-based tests. They walk the app slowly, with deliberate
/// pauses, so the simulator can be screen-recorded and the footage is watchable.
///
/// Run one at a time while `xcrun simctl io booted recordVideo` is running:
///     xcodebuild test-without-building \
///       -only-testing:CineSeatUITests/DemoRecording/demo01_AppMontage ...
final class DemoRecording: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true          // never abort a recording mid-take
        app = XCUIApplication()
    }

    // MARK: - pacing helpers

    private func beat(_ seconds: Double = 1.6) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func hold(_ seconds: Double = 2.6) {
        Thread.sleep(forTimeInterval: seconds)
    }

    /// Tap only if the element is already on screen. Used for genuinely optional steps.
    @discardableResult
    private func tap(_ element: XCUIElement, wait: TimeInterval = 4, pause: Double = 1.6) -> Bool {
        guard element.waitForExistence(timeout: wait), element.isHittable else { return false }
        element.tap()
        beat(pause)
        return true
    }

    /// Tap a required control. XCUITest scrolls the element into view itself, so this
    /// must NOT pre-check isHittable — doing so silently skips the tap.
    @discardableResult
    private func forceTap(_ element: XCUIElement, wait: TimeInterval = 6, pause: Double = 2.0) -> Bool {
        guard element.waitForExistence(timeout: wait) else { return false }
        element.tap()
        beat(pause)
        return true
    }

    private func back() {
        let bar = app.navigationBars.element(boundBy: 0)
        if bar.exists, bar.buttons.count > 0 {
            bar.buttons.element(boundBy: 0).tap()
            beat()
        }
    }

    private func launchFresh(reset: Bool = false) {
        app = XCUIApplication()
        if reset { app.launchArguments = ["-resetProfileSessionForUITests"] }
        app.launch()
        hold(2.0)
    }

    private func typeInto(_ field: XCUIElement, _ text: String) {
        guard field.waitForExistence(timeout: 4) else { return }
        field.tap()
        beat(0.5)
        field.typeText(text)
        beat(0.6)
    }

    private func selectAFewSeats() {
        for id in ["D4", "D5", "E4", "E5", "C3", "C4"] {
            let seat = app.buttons[id]
            if seat.exists, seat.isHittable {
                seat.tap()
                beat(0.9)
            }
        }
        hold()
    }

    // MARK: - 00  Seed data (also produces the full booking-flow footage)

    /// Creates an account and completes one movie booking.
    /// Run this FIRST — later demos need an account and a booking to look real.
    func demo00_SeedAccountAndBooking() {
        launchFresh(reset: true)

        // --- account ---
        forceTap(app.tabBars.buttons["Profile"])
        forceTap(app.buttons["profileCreateAccountButton"])

        let email = "demo.seed\(Int(Date().timeIntervalSince1970 * 1000))@example.com"
        typeInto(app.textFields["createNameField"], "Mia Reyes")
        typeInto(app.textFields["createEmailField"], email)
        typeInto(app.textFields["createPhoneField"], "09171234567")
        typeInto(app.secureTextFields["createPasswordField"], "MoviePass2026")
        typeInto(app.secureTextFields["createConfirmPasswordField"], "MoviePass2026")
        forceTap(app.buttons["createAccountSubmitButton"], pause: 3.0)

        // --- booking ---
        forceTap(app.tabBars.buttons["Showings"])
        forceTap(app.buttons["showingCategory_Movies"])
        hold()

        forceTap(app.tables.cells["movieCell_Star Wars: Episode IV - A New Hope"], pause: 2.4)
        forceTap(app.buttons["SELECT SEATS"], pause: 2.4)
        selectAFewSeats()
        forceTap(app.buttons["CONTINUE"], pause: 2.4)

        // summary -> confirm
        for label in ["CONFIRM BOOKING", "CONFIRM", "BOOK NOW", "CONFIRM AND PAY"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 2) {
                b.tap()
                beat(2.8)
                break
            }
        }
        hold(3.0)
    }

    // MARK: - 01  App montage  (Video 1, shot 1.1)

    func demo01_AppMontage() {
        launchFresh()
        hold(2.4)                                   // Showings hub

        forceTap(app.buttons["showingCategory_Movies"], pause: 2.2)
        hold(2.0)                                   // movies list

        forceTap(app.tables.cells["movieCell_Star Wars: Episode IV - A New Hope"], pause: 2.4)
        hold(2.0)                                   // movie detail

        forceTap(app.buttons["SELECT SEATS"], pause: 2.4)
        selectAFewSeats()                           // seat map

        back(); back()
        forceTap(app.tabBars.buttons["Locations"], pause: 2.6)
        hold(3.0)                                   // map
    }

    // MARK: - 02  The four tabs  (Video 2, shot 2.1)

    func demo02_FourTabs() {
        launchFresh()
        for tab in ["Showings", "Bookings", "Locations", "Profile"] {
            forceTap(app.tabBars.buttons[tab], pause: 2.4)
        }
        forceTap(app.tabBars.buttons["Showings"], pause: 2.0)
    }

    // MARK: - 03  Search and rating sort  (Video 2, shot 2.4)

    func demo03_SearchAndSort() {
        launchFresh()
        forceTap(app.buttons["showingCategory_Movies"], pause: 2.0)

        let search = app.searchFields.element(boundBy: 0)
        if search.waitForExistence(timeout: 3) {
            search.tap(); beat(0.8)
            for ch in "dune" { search.typeText(String(ch)); beat(0.45) }
            hold(2.4)
            let clear = app.buttons["Clear text"]
            if clear.exists { clear.tap() }
            beat(1.2)
        }

        // toggle the sort twice so both arrow directions are captured
        forceTap(app.buttons["moviesRatingSort"], pause: 2.4)
        forceTap(app.buttons["moviesRatingSort"], pause: 2.4)
    }

    // MARK: - 04  Table view scrolling  (Video 2, shot 2.6)

    func demo04_TableScrolling() {
        launchFresh()
        forceTap(app.buttons["showingCategory_Movies"], pause: 2.0)
        for _ in 0..<3 { app.swipeUp(); beat(1.0) }
        for _ in 0..<3 { app.swipeDown(); beat(1.0) }
        hold()
    }

    // MARK: - 05  Reviews: local vs online  (Video 3, shot 3.1)

    func demo05_ReviewsSegments() {
        launchFresh()
        forceTap(app.buttons["showingCategory_Movies"], pause: 1.8)
        forceTap(app.tables.cells["movieCell_Star Wars: Episode IV - A New Hope"], pause: 2.0)
        forceTap(app.buttons["movieReviewsButton"], pause: 2.4)

        let segments = app.segmentedControls["reviewSourceControl"]
        if segments.waitForExistence(timeout: 3) {
            hold(2.2)                                        // TicketPlease reviews
            if segments.buttons.count > 1 {
                segments.buttons.element(boundBy: 1).tap()   // Online / TMDB
                hold(3.4)                                    // let the network call land
            }
            if segments.buttons.count > 0 {
                segments.buttons.element(boundBy: 0).tap()
                hold(2.0)
            }
        }
    }

    // MARK: - 06  Bookings persisted across relaunch  (Video 3, shot 3.5)

    func demo06_BookingsPersist() {
        launchFresh()
        forceTap(app.tabBars.buttons["Bookings"], pause: 2.6)
        hold(3.0)
        if app.tables.cells.count > 0 {
            app.tables.cells.element(boundBy: 0).tap()
            hold(3.2)                                        // booking detail + seat map
        }
    }

    // MARK: - 07  Locations map and pin callout  (Video 5, shots 5.1 / 5.2)

    func demo07_MapAndPins() {
        launchFresh()
        forceTap(app.tabBars.buttons["Locations"], pause: 3.0)
        hold(2.6)

        let pins = app.otherElements.matching(NSPredicate(format: "elementType == 39"))
        if pins.count > 0 {
            pins.element(boundBy: 0).tap()
            hold(2.6)                                        // callout
            let callouts = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'detail' OR label CONTAINS[c] 'more'")
            )
            if callouts.count > 0 {
                callouts.element(boundBy: 0).tap()
                hold(3.2)                                    // cinema detail
            }
        }
        hold(2.0)
    }

    // MARK: - 08  Concerts: quantity booking  (Chapter 8)

    func demo08_ConcertQuantity() {
        launchFresh()
        forceTap(app.buttons["showingCategory_Concerts"], pause: 2.2)
        hold(1.8)
        forceTap(app.tables.cells["eventCell_Taylor Swift: The Eras Tour"], pause: 2.4)

        let stepper = app.steppers["eventTicketQuantityStepper"]
        if stepper.waitForExistence(timeout: 3), stepper.buttons.count > 1 {
            for _ in 0..<2 { stepper.buttons.element(boundBy: 1).tap(); beat(1.0) }
        }
        hold(2.4)
    }

    // MARK: - 09  Settings and the in-app changelog  (Video 6, shot 6.5)

    func demo09_SettingsAndChangelog() {
        launchFresh()
        forceTap(app.tabBars.buttons["Profile"], pause: 2.0)
        forceTap(app.buttons["settingsButton"], pause: 2.6)
        hold(2.2)
        forceTap(app.buttons["viewChangelogButton"], pause: 2.6)
        for _ in 0..<4 { app.swipeUp(); beat(1.3) }          // scroll the change list
        hold(2.2)
    }

    // MARK: - 10  Profile: create, log out, log back in  (Video 3, shot 3.8)

    func demo10_ProfileAuth() {
        launchFresh(reset: true)
        forceTap(app.tabBars.buttons["Profile"], pause: 2.0)
        forceTap(app.buttons["profileCreateAccountButton"], pause: 1.8)

        let email = "demo.user\(Int(Date().timeIntervalSince1970 * 1000))@example.com"
        typeInto(app.textFields["createNameField"], "Demo User")
        typeInto(app.textFields["createEmailField"], email)
        typeInto(app.textFields["createPhoneField"], "09171234567")
        typeInto(app.secureTextFields["createPasswordField"], "MoviePass2026")
        typeInto(app.secureTextFields["createConfirmPasswordField"], "MoviePass2026")
        forceTap(app.buttons["createAccountSubmitButton"], pause: 3.0)

        forceTap(app.buttons["logoutButton"], pause: 1.4)
        forceTap(app.alerts.buttons["Log Out"], pause: 2.4)

        forceTap(app.buttons["profileLoginButton"], pause: 1.8)
        typeInto(app.textFields["loginEmailField"], email)
        typeInto(app.secureTextFields["loginPasswordField"], "MoviePass2026")
        forceTap(app.buttons["loginSubmitButton"], pause: 3.2)
        hold(2.0)
    }
}
