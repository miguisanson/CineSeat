import UIKit

// module 2 movie detail screen
// the user picks a fixed showing instead of choosing any cinema
final class MovieDetailViewController: ScrollableViewController {
    var movie: Movie!
    var factory = AppFactory.shared

    private lazy var scheduleViewModel = factory.makeMovieScheduleViewModel(movie: movie)
    // beginner-style time button references like separate storyboard outlets
    // each time already has the cinema assigned in sample data
    private let datePicker = UIDatePicker()
    private var firstTimeButton: UIButton!
    private var secondTimeButton: UIButton!
    private var thirdTimeButton: UIButton!
    private let assignedCinemaLabel = UILabel()
    private var selectSeatsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movie Detail"
        buildInterface()
        updateScheduleViews()
    }

    private func buildInterface() {
        let poster = PosterPlaceholderView()
        poster.heightAnchor.constraint(equalToConstant: 220).isActive = true
        poster.loadPoster(from: movie.posterURLString, localName: movie.localPosterName)
        contentStack.addArrangedSubview(poster)

        let titleLabel = UILabel()
        titleLabel.text = movie.title
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = CineSeatTheme.primaryText

        let metadataLabel = UILabel()
        metadataLabel.text = "\(movie.genre)  |  \(movie.duration)  |  ***** \(String(format: "%.1f", movie.rating))"
        metadataLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        metadataLabel.textColor = CineSeatTheme.mutedText
        metadataLabel.numberOfLines = 0

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(metadataLabel)

        let synopsisTitle = CineSeatTheme.captionLabel("Synopsis")
        let synopsisLabel = UILabel()
        synopsisLabel.text = movie.synopsis
        synopsisLabel.font = .systemFont(ofSize: 13)
        synopsisLabel.textColor = CineSeatTheme.secondaryText
        synopsisLabel.numberOfLines = 0
        let synopsisStack = UIStackView(arrangedSubviews: [synopsisTitle, synopsisLabel])
        synopsisStack.axis = .vertical
        synopsisStack.spacing = 7
        contentStack.addArrangedSubview(makeCard(with: synopsisStack))

        if movie.isComingSoon {
            let comingSoonLabel = UILabel()
            comingSoonLabel.text = "This movie is coming soon. You can view the details now, but seat booking opens when it moves to Now Playing."
            comingSoonLabel.font = .systemFont(ofSize: 13)
            comingSoonLabel.textColor = CineSeatTheme.secondaryText
            comingSoonLabel.textAlignment = .center
            comingSoonLabel.numberOfLines = 0
            contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [comingSoonLabel]), padding: 12))
        }

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select date"))
        configureDatePicker()
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [datePicker]), padding: 10))

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select time"))

        firstTimeButton = makeTimeButton(index: 0)
        secondTimeButton = makeTimeButton(index: 1)
        thirdTimeButton = makeTimeButton(index: 2)

        let timesStack = UIStackView(arrangedSubviews: [
            firstTimeButton,
            secondTimeButton,
            thirdTimeButton
        ])
        timesStack.axis = .vertical
        timesStack.spacing = 8
        contentStack.addArrangedSubview(timesStack)

        assignedCinemaLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        assignedCinemaLabel.textColor = CineSeatTheme.secondaryText
        assignedCinemaLabel.numberOfLines = 0
        assignedCinemaLabel.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [assignedCinemaLabel]), padding: 12))

        selectSeatsButton = CineSeatTheme.primaryButton(title: movie.isComingSoon ? "Coming Soon" : "Select Seats")
        selectSeatsButton.addTarget(self, action: #selector(selectSeatsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(selectSeatsButton)
    }

    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = scheduleViewModel.minimumDate
        datePicker.maximumDate = scheduleViewModel.maximumDate
        datePicker.isEnabled = movie.isNowPlaying && scheduleViewModel.minimumDate != nil
        if let selectedDate = scheduleViewModel.selectedSchedule?.date {
            datePicker.date = selectedDate
        }
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    private func makeTimeButton(index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = index
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.accessibilityIdentifier = "timeButton\(index + 1)"
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        button.addTarget(self, action: #selector(timeTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        scheduleViewModel.selectDate(sender.date)
        updateScheduleViews()
    }

    @objc private func timeTapped(_ sender: UIButton) {
        scheduleViewModel.selectTime(at: sender.tag)
        updateScheduleViews()
    }

    private func updateScheduleViews() {
        update(button: firstTimeButton, at: 0)
        update(button: secondTimeButton, at: 1)
        update(button: thirdTimeButton, at: 2)

        if let selectedDate = scheduleViewModel.selectedSchedule?.date,
           !CineSeatDateFormatters.isSameDay(datePicker.date, selectedDate) {
            datePicker.date = selectedDate
        }

        if let schedule = scheduleViewModel.selectedSchedule,
           let time = scheduleViewModel.selectedTime {
            assignedCinemaLabel.text = "date: \(schedule.displayDateWithTitle)\nassigned cinema: \(time.cinema.name)\n\(time.cinema.type.rawValue) ticket - \(CineSeatTheme.money(time.ticketPrice))"
        } else {
            assignedCinemaLabel.text = "no bookable schedule yet"
        }

        let isBookingAvailable = scheduleViewModel.isBookingAvailable
        selectSeatsButton.isEnabled = isBookingAvailable
        selectSeatsButton.alpha = isBookingAvailable ? 1 : 0.45
        selectSeatsButton.setTitle(movie.isComingSoon ? "COMING SOON" : "SELECT SEATS", for: .normal)
    }

    private func update(button: UIButton?, at index: Int) {
        guard let time = scheduleViewModel.time(at: index) else {
            button?.isHidden = true
            return
        }

        let isSelected = scheduleViewModel.selectedTime?.id == time.id
        button?.isHidden = false
        button?.isEnabled = movie.isNowPlaying
        button?.alpha = movie.isNowPlaying ? 1 : 0.5
        button?.setTitle(timeButtonTitle(for: time), for: .normal)
        button?.accessibilityLabel = "\(time.showtime), \(time.cinema.name), \(time.cinema.type.rawValue)"
        button?.backgroundColor = isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card
        button?.setTitleColor(isSelected ? .white : CineSeatTheme.primaryText, for: .normal)
        button?.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
    }

    private func timeButtonTitle(for time: ShowingTime) -> String {
        "\(time.showtime)\n\(time.cinema.shortName) - \(time.cinema.type.rawValue)\n\(CineSeatTheme.money(time.ticketPrice))"
    }

    @objc private func selectSeatsTapped() {
        guard movie.isNowPlaying else {
            let alert = UIAlertController(
                title: "Coming Soon",
                message: "Seat booking opens when this movie moves to Now Playing.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let draft = scheduleViewModel.makeDraft() else {
            let alert = UIAlertController(
                title: "No Showing",
                message: "There is no assigned cinema schedule available for this movie yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let seatViewController = factory.makeSeatSelectionViewController(draft: draft)
        navigationController?.pushViewController(seatViewController, animated: true)
    }
}

// module 2 seat selection screen
// view controller handles flow, seat rules stay in the viewmodel
final class SeatSelectionViewController: ScrollableViewController {
    var draft: BookingDraft!
    var factory = AppFactory.shared

    private lazy var viewModel = factory.makeSeatSelectionViewModel(
        layout: draft.seatLayout,
        ticketPrice: draft.ticketPrice
    )
    private let seatMapView = SeatMapView()
    private let selectedSeatsLabel = UILabel()
    private let totalLabel = UILabel()
    private let continueButton = CineSeatTheme.primaryButton(title: "Continue")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Seats"
        buildInterface()
        updateSeatViews()
    }

    private func buildInterface() {
        let showtimeLabel = CineSeatTheme.captionLabel("\(draft.movie.title) - \(draft.cinema.name) - \(draft.showtime) - \(CineSeatTheme.money(draft.ticketPrice))")
        showtimeLabel.textAlignment = .center
        contentStack.addArrangedSubview(showtimeLabel)

        let screenView = UIView()
        screenView.backgroundColor = CineSeatTheme.mutedText
        screenView.layer.cornerRadius = 3
        screenView.translatesAutoresizingMaskIntoConstraints = false
        let screenContainer = UIView()
        screenContainer.addSubview(screenView)
        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo: screenContainer.topAnchor),
            screenView.centerXAnchor.constraint(equalTo: screenContainer.centerXAnchor),
            screenView.widthAnchor.constraint(equalTo: screenContainer.widthAnchor, multiplier: 0.82),
            screenView.heightAnchor.constraint(equalToConstant: 6),
            screenView.bottomAnchor.constraint(equalTo: screenContainer.bottomAnchor)
        ])
        contentStack.addArrangedSubview(screenContainer)

        let screenLabel = CineSeatTheme.captionLabel("Screen")
        screenLabel.textAlignment = .center
        contentStack.addArrangedSubview(screenLabel)

        // this custom view builds the hstack/vstack seat buttons from the cinema layout
        seatMapView.configure(
            layout: viewModel.layout,
            selectedSeats: viewModel.selectedSeats,
            accessibilityPrefix: "seat",
            seatStateProvider: { [weak self] seat, isHighlighted in
                self?.viewModel.visualState(for: seat, isHighlighted: isHighlighted) ?? .available
            }
        )
        seatMapView.onSeatTapped = { [weak self] seat in
            self?.seatTapped(seat)
        }
        contentStack.addArrangedSubview(seatMapView)

        let legendStack = UIStackView(arrangedSubviews: [
            makeLegendItem(title: "Available", color: CineSeatTheme.seatColor(for: .available)),
            makeLegendItem(title: "Selected", color: CineSeatTheme.seatColor(for: .selected)),
            makeLegendItem(title: "Reserved", color: CineSeatTheme.seatColor(for: .reserved)),
            makeLegendItem(title: "Unavailable", color: CineSeatTheme.seatColor(for: .unavailable))
        ])
        legendStack.axis = .horizontal
        legendStack.distribution = .equalSpacing
        legendStack.alignment = .center
        contentStack.addArrangedSubview(makeCard(with: legendStack, padding: 12))

        selectedSeatsLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        selectedSeatsLabel.textColor = CineSeatTheme.primaryText
        selectedSeatsLabel.textAlignment = .right
        totalLabel.font = .monospacedSystemFont(ofSize: 17, weight: .bold)
        totalLabel.textColor = CineSeatTheme.primaryText
        totalLabel.textAlignment = .right

        let summaryStack = UIStackView(arrangedSubviews: [
            makeSummaryRow(title: "Selected seats", valueLabel: selectedSeatsLabel),
            makeSummaryRow(title: "Total", valueLabel: totalLabel)
        ])
        summaryStack.axis = .vertical
        summaryStack.spacing = 4
        contentStack.addArrangedSubview(makeCard(with: summaryStack, padding: 12))

        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(continueButton)
    }

    private func makeLegendItem(title: String, color: UIColor) -> UIStackView {
        let square = UIView()
        square.backgroundColor = color
        square.layer.cornerRadius = 3
        square.layer.borderWidth = 1
        square.layer.borderColor = CineSeatTheme.border.cgColor
        square.widthAnchor.constraint(equalToConstant: 18).isActive = true
        square.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let label = UILabel()
        label.text = title
        label.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
        label.textColor = CineSeatTheme.secondaryText

        let stack = UIStackView(arrangedSubviews: [square, label])
        stack.axis = .horizontal
        stack.spacing = 5
        return stack
    }

    private func makeSummaryRow(title: String, valueLabel: UILabel) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [CineSeatTheme.captionLabel(title), valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func seatTapped(_ seat: String) {
        viewModel.toggleSeat(seat)
        updateSeatViews()
    }

    private func updateSeatViews() {
        seatMapView.update(selectedSeats: viewModel.selectedSeats)

        let seats = viewModel.sortedSelectedSeats
        selectedSeatsLabel.text = seats.isEmpty ? "None" : seats.joined(separator: ", ")
        totalLabel.text = CineSeatTheme.money(viewModel.total)
        continueButton.isEnabled = !seats.isEmpty
        continueButton.alpha = seats.isEmpty ? 0.45 : 1
    }

    @objc private func continueTapped() {
        draft.seats = viewModel.sortedSelectedSeats
        let summaryViewController = factory.makeBookingSummaryViewController(draft: draft)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

// module 2 booking summary screen
// this checks login before calling the confirm booking use case
final class BookingSummaryViewController: ScrollableViewController {
    var draft: BookingDraft!
    var factory = AppFactory.shared
    var confirmBookingUseCase: ConfirmBookingUseCase = DefaultConfirmBookingUseCase(
        bookingManager: BookingStore.shared
    )
    var authenticationService: Authenticating = AuthenticationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Booking Summary"
        buildInterface()
    }

    private func buildInterface() {
        let movieStack = UIStackView()
        movieStack.axis = .vertical
        movieStack.spacing = 5
        let titleLabel = UILabel()
        titleLabel.text = draft.movie.title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = CineSeatTheme.primaryText
        movieStack.addArrangedSubview(titleLabel)
        movieStack.addArrangedSubview(CineSeatTheme.captionLabel("\(draft.movie.genre) - \(draft.movie.duration) - ***** \(String(format: "%.1f", draft.movie.rating))"))
        contentStack.addArrangedSubview(makeCard(with: movieStack))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(CineSeatTheme.captionLabel("Booking details"))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: draft.dateSummary))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: draft.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: draft.cinema.name))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: draft.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(draft.seats.count) x \(draft.cinema.type.rawValue)"))
        details.addArrangedSubview(makeInfoRow(label: "Ticket price", value: "\(CineSeatTheme.money(draft.ticketPrice)) each"))
        contentStack.addArrangedSubview(makeCard(with: details))

        let price = UIStackView()
        price.axis = .vertical
        price.addArrangedSubview(makeInfoRow(label: "Subtotal", value: CineSeatTheme.money(draft.subtotal)))
        price.addArrangedSubview(makeInfoRow(label: "Booking fee", value: CineSeatTheme.money(draft.bookingFee)))
        price.addArrangedSubview(makeInfoRow(label: "Total", value: CineSeatTheme.money(draft.total)))
        contentStack.addArrangedSubview(makeCard(with: price))

        let confirmButton = CineSeatTheme.primaryButton(title: "Confirm Booking")
        confirmButton.addTarget(self, action: #selector(confirmTapped(_:)), for: .touchUpInside)
        contentStack.addArrangedSubview(confirmButton)

        let editButton = CineSeatTheme.secondaryButton(title: "Edit Seats")
        editButton.addTarget(self, action: #selector(editSeatsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(editButton)
    }

    @objc private func confirmTapped(_ sender: UIButton) {
        guard authenticationService.currentProfile != nil else {
            let alert = UIAlertController(
                title: "Log In Required",
                message: "Please log in or create an account before confirming your booking.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Log In", style: .default) { [weak self] _ in
                guard let self else { return }
                self.navigationController?.pushViewController(self.factory.makeLoginViewController(), animated: true)
            })
            present(alert, animated: true)
            return
        }

        sender.isEnabled = false
        let booking = confirmBookingUseCase.execute(draft: draft)
        let confirmationViewController = factory.makeConfirmationViewController(booking: booking)
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }

    @objc private func editSeatsTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// module 2 confirmation screen
// this shows the final booking details after persistence saves the booking
final class ConfirmationViewController: ScrollableViewController {
    var booking: Booking!
    var notificationScheduler: BookingNotificationScheduling?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirmation"
        navigationItem.hidesBackButton = true
        buildInterface()
    }

    private func buildInterface() {
        let successIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        successIcon.tintColor = CineSeatTheme.primaryText
        successIcon.contentMode = .scaleAspectFit
        successIcon.heightAnchor.constraint(equalToConstant: 72).isActive = true
        contentStack.addArrangedSubview(successIcon)

        let titleLabel = UILabel()
        titleLabel.text = "Booking Confirmed!"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 21, weight: .heavy)
        titleLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(titleLabel)

        let idTitle = CineSeatTheme.captionLabel("Booking ID")
        idTitle.textAlignment = .center
        let idLabel = UILabel()
        idLabel.text = booking.id
        idLabel.textAlignment = .center
        idLabel.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
        idLabel.textColor = CineSeatTheme.primaryText
        let idStack = UIStackView(arrangedSubviews: [idTitle, idLabel])
        idStack.axis = .vertical
        idStack.spacing = 5
        contentStack.addArrangedSubview(makeCard(with: idStack))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(makeInfoRow(label: "Movie", value: booking.movie.title))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: booking.dateSummary))
        details.addArrangedSubview(makeInfoRow(label: "Showtime", value: booking.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: booking.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: booking.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Total paid", value: CineSeatTheme.money(booking.total)))
        contentStack.addArrangedSubview(makeCard(with: details))

        let demoReminderButton = CineSeatTheme.secondaryButton(title: "Demo Local Reminder")
        demoReminderButton.addTarget(self, action: #selector(demoReminderTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(demoReminderButton)

        let viewBookingsButton = CineSeatTheme.primaryButton(title: "View My Bookings")
        viewBookingsButton.addTarget(self, action: #selector(viewBookingsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(viewBookingsButton)

        let backToMoviesButton = CineSeatTheme.secondaryButton(title: "Back to Movies")
        backToMoviesButton.addTarget(self, action: #selector(backToMoviesTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(backToMoviesButton)
    }

    @objc private func demoReminderTapped() {
        // schedules a 5 second local notification so it can be shown during presentation
        notificationScheduler?.scheduleDemoReminder(for: booking) { [weak self] scheduled in
            DispatchQueue.main.async {
                guard let self else { return }
                let alert = UIAlertController(
                    title: scheduled ? "Demo Reminder Set" : "Notifications Disabled",
                    message: scheduled
                        ? "Wait about 5 seconds. The local notification banner should appear from the top of the screen."
                        : "Allow notifications for CineSeat in Settings to show the local reminder demo.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    @objc private func viewBookingsTapped() {
        guard let tabBarController else { return }
        tabBarController.selectedIndex = 1
        (tabBarController.selectedViewController as? UINavigationController)?.popToRootViewController(animated: false)
    }

    @objc private func backToMoviesTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
