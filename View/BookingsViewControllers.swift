import UIKit

// module 2 bookings screen
// storyboard switch and table view connect to the bookings viewmodel
final class BookingsViewController: UIViewController {
    // this outlet connects to the total bookings count label
    @IBOutlet private weak var countLabel: UILabel!
    // this outlet connects to the my bookings table view
    @IBOutlet private weak var bookingsTableView: UITableView!
    // this outlet connects to the show cancelled bookings switch
    @IBOutlet private weak var showCancelledSwitch: UISwitch!

    private let factory = AppFactory.shared
    private lazy var viewModel = factory.makeBookingsViewModel()
    private let emptyStateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bookingsTableView.register(BookingTableViewCell.self, forCellReuseIdentifier: BookingTableViewCell.reuseIdentifier)
        bookingsTableView.backgroundColor = .white
        bookingsTableView.separatorStyle = .none
        bookingsTableView.rowHeight = UITableView.automaticDimension
        bookingsTableView.estimatedRowHeight = 150
        configureEmptyStateLabel()
        showCancelledSwitch.isOn = viewModel.showCancelledBookings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookingsDidChange),
            name: viewModel.bookingsDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged),
            name: viewModel.authenticationDidChangeNotification,
            object: nil
        )
        reloadBookings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadBookings()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func bookingsDidChange() {
        reloadBookings()
    }

    @objc private func authenticationChanged() {
        reloadBookings()
    }

    private func configureEmptyStateLabel() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textColor = CineSeatTheme.secondaryText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emptyStateLabel.centerYAnchor.constraint(equalTo: bookingsTableView.centerYAnchor)
        ])
    }

    private func reloadBookings() {
        countLabel.text = viewModel.countText
        showCancelledSwitch.isEnabled = viewModel.isLoggedIn
        let shouldShowEmptyState = !viewModel.isLoggedIn || viewModel.bookings.isEmpty
        emptyStateLabel.text = viewModel.emptyStateText
        emptyStateLabel.isHidden = !shouldShowEmptyState
        bookingsTableView.isHidden = shouldShowEmptyState
        bookingsTableView.reloadData()
    }

    // value changed action from the storyboard cancelled-bookings switch
    @IBAction private func showCancelledChanged(_ sender: UISwitch) {
        viewModel.showCancelledBookings = sender.isOn
        reloadBookings()
    }
}

extension BookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BookingTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? BookingTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.booking(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = factory.makeBookingDetailViewController(
            booking: viewModel.booking(at: indexPath.row)
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// module 2 booking detail screen
// the cinema map is rebuilt here so booked seats can be checked again
final class BookingDetailViewController: ScrollableViewController {
    var booking: Booking!
    var cancelBookingUseCase: CancelBookingUseCase = DefaultCancelBookingUseCase(
        bookingManager: BookingStore.shared
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Booking Detail"
        buildInterface()
    }

    private func buildInterface() {
        let movieTitle = UILabel()
        movieTitle.text = booking.movie.title
        movieTitle.font = .systemFont(ofSize: 17, weight: .bold)
        movieTitle.textColor = CineSeatTheme.primaryText

        let movieDetails = CineSeatTheme.captionLabel("\(booking.movie.genre) - \(booking.movie.duration)")
        let statusLabel = UILabel()
        statusLabel.text = booking.status.rawValue.uppercased()
        statusLabel.textAlignment = .center
        statusLabel.textColor = booking.status.isConfirmed ? .white : CineSeatTheme.secondaryText
        statusLabel.backgroundColor = booking.status.isConfirmed ? CineSeatTheme.primaryText : CineSeatTheme.border
        statusLabel.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 92).isActive = true
        statusLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let statusRow = UIStackView(arrangedSubviews: [movieTitle, UIView(), statusLabel])
        statusRow.axis = .horizontal
        statusRow.alignment = .center
        let movieStack = UIStackView(arrangedSubviews: [statusRow, movieDetails])
        movieStack.axis = .vertical
        movieStack.spacing = 5
        contentStack.addArrangedSubview(makeCard(with: movieStack))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(CineSeatTheme.captionLabel("Booking information"))
        details.addArrangedSubview(makeInfoRow(label: "Booking ID", value: booking.id))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: booking.dateSummary))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: booking.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: booking.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: booking.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(booking.seats.count) x \(ticketTypeText)"))
        details.addArrangedSubview(makeInfoRow(label: "Subtotal", value: CineSeatTheme.money(booking.subtotal)))
        details.addArrangedSubview(makeInfoRow(label: "Booking fee", value: CineSeatTheme.money(booking.bookingFee)))
        details.addArrangedSubview(makeInfoRow(label: "Total paid", value: CineSeatTheme.money(booking.total)))
        contentStack.addArrangedSubview(makeCard(with: details))

        let seatCardStack = UIStackView(arrangedSubviews: [
            CineSeatTheme.captionLabel("Cinema map"),
            makeScreenLabel(),
            makeBookedSeatMap(),
            CineSeatTheme.captionLabel("Tap a highlighted seat to check the row and number again")
        ])
        seatCardStack.axis = .vertical
        seatCardStack.spacing = 10
        contentStack.addArrangedSubview(makeCard(with: seatCardStack))

        let note = CineSeatTheme.captionLabel("Cancellation is available up to 2 hours before showtime. The booking fee is non-refundable.")
        note.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [note]), padding: 12))

        if booking.status.isConfirmed {
            let cancelButton = CineSeatTheme.secondaryButton(title: "Cancel Booking")
            cancelButton.setTitleColor(.systemRed, for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            contentStack.addArrangedSubview(cancelButton)
        }
    }

    private var ticketTypeText: String {
        booking.ticketPrice >= 550 ? "VIP" : "Standard"
    }

    private func makeScreenLabel() -> UIStackView {
        let screenView = UIView()
        screenView.backgroundColor = CineSeatTheme.mutedText
        screenView.layer.cornerRadius = 3
        screenView.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let screenText = CineSeatTheme.captionLabel("Screen")
        screenText.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [screenView, screenText])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func makeBookedSeatMap() -> SeatMapView {
        let seatMapView = SeatMapView()
        let bookedSeats = Set(booking.seats)
        seatMapView.configure(
            layout: booking.seatLayout,
            selectedSeats: [],
            highlightedSeats: bookedSeats,
            showsSeatIDForHighlightedSeats: true,
            accessibilityPrefix: "bookingSeat"
        )
        seatMapView.onSeatTapped = { [weak self] seat in
            self?.showBookedSeatAlert(seat)
        }
        return seatMapView
    }

    private func showBookedSeatAlert(_ seat: String) {
        let alert = UIAlertController(
            title: "Seat \(seat)",
            message: "This highlighted seat is inside \(booking.cinema).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func cancelTapped() {
        let alert = UIAlertController(
            title: "Cancel Booking?",
            message: "This changes the booking status to Cancelled. The booking fee is not refunded.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep Booking", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cancel Booking", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.cancelBookingUseCase.execute(id: self.booking.id)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
