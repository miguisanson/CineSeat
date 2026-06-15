import UIKit

final class MovieDetailViewController: ScrollableViewController {
    var movie: Movie!

    private let dateTitles = ["Today", "Sat 15", "Sun 16", "Mon 17"]
    private let dateValues = ["Friday, June 14", "Saturday, June 15", "Sunday, June 16", "Monday, June 17"]
    private let showtimes = ["10:30 AM", "1:45 PM", "4:15 PM", "7:00 PM", "9:30 PM"]
    private var selectedDateIndex = 1
    private var selectedShowtimeIndex = 2
    private var dateButtons: [UIButton] = []
    private var showtimeButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movie Detail"
        buildInterface()
        updateChoiceButtons()
    }

    private func buildInterface() {
        let poster = PosterPlaceholderView()
        poster.heightAnchor.constraint(equalToConstant: 220).isActive = true
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

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select date and showtime"))

        let datesStack = UIStackView()
        datesStack.axis = .horizontal
        datesStack.spacing = 8
        datesStack.distribution = .fillEqually
        for (index, title) in dateTitles.enumerated() {
            let button = makeChoiceButton(title: title, tag: index, action: #selector(dateTapped(_:)))
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            dateButtons.append(button)
            datesStack.addArrangedSubview(button)
        }
        contentStack.addArrangedSubview(datesStack)

        let firstShowtimeRow = makeShowtimeRow(indices: 0...2)
        let secondShowtimeRow = makeShowtimeRow(indices: 3...4)
        contentStack.addArrangedSubview(firstShowtimeRow)
        contentStack.addArrangedSubview(secondShowtimeRow)

        let selectSeatsButton = CineSeatTheme.primaryButton(title: "Select Seats")
        selectSeatsButton.addTarget(self, action: #selector(selectSeatsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(selectSeatsButton)
    }

    private func makeShowtimeRow(indices: ClosedRange<Int>) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually

        for index in indices {
            let button = makeChoiceButton(title: showtimes[index], tag: index, action: #selector(showtimeTapped(_:)))
            button.heightAnchor.constraint(equalToConstant: 38).isActive = true
            showtimeButtons.append(button)
            stack.addArrangedSubview(button)
        }

        if indices.count < 3 {
            stack.addArrangedSubview(UIView())
        }
        return stack
    }

    private func makeChoiceButton(title: String, tag: Int, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 10, weight: .semibold)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func dateTapped(_ sender: UIButton) {
        selectedDateIndex = sender.tag
        updateChoiceButtons()
    }

    @objc private func showtimeTapped(_ sender: UIButton) {
        selectedShowtimeIndex = sender.tag
        updateChoiceButtons()
    }

    private func updateChoiceButtons() {
        update(buttons: dateButtons, selectedIndex: selectedDateIndex)
        update(buttons: showtimeButtons, selectedIndex: selectedShowtimeIndex)
    }

    private func update(buttons: [UIButton], selectedIndex: Int) {
        for button in buttons {
            let isSelected = button.tag == selectedIndex
            button.backgroundColor = isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card
            button.setTitleColor(isSelected ? .white : CineSeatTheme.primaryText, for: .normal)
            button.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
        }
    }

    @objc private func selectSeatsTapped() {
        let seatViewController = SeatSelectionViewController()
        seatViewController.draft = BookingDraft(
            movie: movie,
            date: dateValues[selectedDateIndex],
            showtime: showtimes[selectedShowtimeIndex]
        )
        navigationController?.pushViewController(seatViewController, animated: true)
    }
}

final class SeatSelectionViewController: ScrollableViewController {
    var draft: BookingDraft!

    private var viewModel = SeatSelectionViewModel()
    private var seatButtons: [String: UIButton] = [:]
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
        let showtimeLabel = CineSeatTheme.captionLabel("\(draft.movie.title) - \(draft.showtime) - \(draft.date)")
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

        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 6
        gridStack.alignment = .center

        for row in viewModel.rows {
            gridStack.addArrangedSubview(makeSeatRow(row))
        }
        contentStack.addArrangedSubview(gridStack)

        let legendStack = UIStackView(arrangedSubviews: [
            makeLegendItem(title: "Available", color: CineSeatTheme.card),
            makeLegendItem(title: "Selected", color: CineSeatTheme.primaryText),
            makeLegendItem(title: "Reserved", color: CineSeatTheme.reservedSeat)
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

    private func makeSeatRow(_ row: String) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 4
        rowStack.alignment = .center

        let leadingLabel = makeRowLabel(row)
        rowStack.addArrangedSubview(leadingLabel)
        for number in 1...viewModel.seatsPerRow {
            if number == 5 {
                let aisle = UIView()
                aisle.widthAnchor.constraint(equalToConstant: 8).isActive = true
                rowStack.addArrangedSubview(aisle)
            }

            let seat = "\(row)\(number)"
            let button = UIButton(type: .system)
            button.accessibilityIdentifier = seat
            button.accessibilityLabel = "Seat \(seat)"
            button.titleLabel?.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
            button.heightAnchor.constraint(equalToConstant: 25).isActive = true
            button.addTarget(self, action: #selector(seatTapped(_:)), for: .touchUpInside)
            seatButtons[seat] = button
            rowStack.addArrangedSubview(button)
        }
        rowStack.addArrangedSubview(makeRowLabel(row))
        return rowStack
    }

    private func makeRowLabel(_ row: String) -> UILabel {
        let label = CineSeatTheme.captionLabel(row)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 14).isActive = true
        return label
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

    @objc private func seatTapped(_ sender: UIButton) {
        guard let seat = sender.accessibilityIdentifier else { return }
        viewModel.toggleSeat(seat)
        updateSeatViews()
    }

    private func updateSeatViews() {
        for (seat, button) in seatButtons {
            let isReserved = viewModel.reservedSeats.contains(seat)
            let isSelected = viewModel.selectedSeats.contains(seat)
            button.isEnabled = !isReserved
            button.backgroundColor = isReserved ? CineSeatTheme.reservedSeat : (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card)
            button.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
            button.setTitle(isSelected ? "X" : "", for: .normal)
            button.setTitleColor(.white, for: .normal)
        }

        let seats = viewModel.sortedSelectedSeats
        selectedSeatsLabel.text = seats.isEmpty ? "None" : seats.joined(separator: ", ")
        totalLabel.text = CineSeatTheme.money(viewModel.total)
        continueButton.isEnabled = !seats.isEmpty
        continueButton.alpha = seats.isEmpty ? 0.45 : 1
    }

    @objc private func continueTapped() {
        draft.seats = viewModel.sortedSelectedSeats
        let summaryViewController = BookingSummaryViewController()
        summaryViewController.draft = draft
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

final class BookingSummaryViewController: ScrollableViewController {
    var draft: BookingDraft!

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
        details.addArrangedSubview(makeInfoRow(label: "Date", value: draft.date))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: draft.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: draft.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: draft.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(draft.seats.count) x Standard"))
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
        sender.isEnabled = false
        let booking = BookingStore.shared.addBooking(from: draft)
        let confirmationViewController = ConfirmationViewController()
        confirmationViewController.booking = booking
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }

    @objc private func editSeatsTapped() {
        navigationController?.popViewController(animated: true)
    }
}

final class ConfirmationViewController: ScrollableViewController {
    var booking: Booking!

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
        details.addArrangedSubview(makeInfoRow(label: "Date", value: booking.date))
        details.addArrangedSubview(makeInfoRow(label: "Showtime", value: booking.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: booking.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: booking.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Total paid", value: CineSeatTheme.money(booking.total)))
        contentStack.addArrangedSubview(makeCard(with: details))

        let viewBookingsButton = CineSeatTheme.primaryButton(title: "View My Bookings")
        viewBookingsButton.addTarget(self, action: #selector(viewBookingsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(viewBookingsButton)

        let backToMoviesButton = CineSeatTheme.secondaryButton(title: "Back to Movies")
        backToMoviesButton.addTarget(self, action: #selector(backToMoviesTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(backToMoviesButton)
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
