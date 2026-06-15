import UIKit

final class BookingsViewController: UIViewController {
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var bookingsTableView: UITableView!

    private let store = BookingStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        bookingsTableView.register(BookingTableViewCell.self, forCellReuseIdentifier: BookingTableViewCell.reuseIdentifier)
        bookingsTableView.backgroundColor = .white
        bookingsTableView.separatorStyle = .none
        bookingsTableView.rowHeight = 132
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookingsDidChange),
            name: BookingStore.bookingsDidChange,
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

    private func reloadBookings() {
        countLabel.text = "\(store.bookings.count) BOOKINGS TOTAL"
        bookingsTableView.reloadData()
    }
}

extension BookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BookingTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? BookingTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: store.bookings[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = BookingDetailViewController()
        detailViewController.booking = store.bookings[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

final class BookingDetailViewController: ScrollableViewController {
    var booking: Booking!

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
        statusLabel.textColor = booking.status == .confirmed ? .white : CineSeatTheme.secondaryText
        statusLabel.backgroundColor = booking.status == .confirmed ? CineSeatTheme.primaryText : CineSeatTheme.border
        statusLabel.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.widthAnchor.constraint(equalToConstant: 92).isActive = true
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
        details.addArrangedSubview(makeInfoRow(label: "Date", value: booking.date))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: booking.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: booking.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: booking.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(booking.seats.count) x Standard"))
        details.addArrangedSubview(makeInfoRow(label: "Subtotal", value: CineSeatTheme.money(booking.subtotal)))
        details.addArrangedSubview(makeInfoRow(label: "Booking fee", value: CineSeatTheme.money(booking.bookingFee)))
        details.addArrangedSubview(makeInfoRow(label: "Total paid", value: CineSeatTheme.money(booking.total)))
        contentStack.addArrangedSubview(makeCard(with: details))

        let seatsStack = UIStackView()
        seatsStack.axis = .horizontal
        seatsStack.alignment = .center
        seatsStack.distribution = .equalCentering
        seatsStack.spacing = 8
        for seat in booking.seats {
            let seatLabel = UILabel()
            seatLabel.text = seat
            seatLabel.textColor = .white
            seatLabel.textAlignment = .center
            seatLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
            seatLabel.backgroundColor = CineSeatTheme.primaryText
            seatLabel.layer.cornerRadius = 6
            seatLabel.clipsToBounds = true
            seatLabel.widthAnchor.constraint(equalToConstant: 46).isActive = true
            seatLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
            seatsStack.addArrangedSubview(seatLabel)
        }
        let seatCardStack = UIStackView(arrangedSubviews: [CineSeatTheme.captionLabel("Seat map"), seatsStack])
        seatCardStack.axis = .vertical
        seatCardStack.spacing = 10
        contentStack.addArrangedSubview(makeCard(with: seatCardStack))

        let note = CineSeatTheme.captionLabel("Cancellation is available up to 2 hours before showtime. The booking fee is non-refundable.")
        note.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [note]), padding: 12))

        if booking.status == .confirmed {
            let cancelButton = CineSeatTheme.secondaryButton(title: "Cancel Booking")
            cancelButton.setTitleColor(.systemRed, for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            contentStack.addArrangedSubview(cancelButton)
        }
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
            BookingStore.shared.cancelBooking(id: self.booking.id)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

final class InfoViewController: ScrollableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = "Info"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(titleLabel)

        contentStack.addArrangedSubview(makeTextCard(
            title: "About CineSeat",
            text: "CineSeat is a simulated cinema booking application. Browse movies, select seats, review the total, and receive a booking confirmation."
        ))

        let steps = [
            "01  Browse movies in the Movies tab",
            "02  Tap a movie card to view details",
            "03  Select a date, showtime, and seats",
            "04  Review your booking summary",
            "05  Confirm to receive a booking ID",
            "06  View all bookings in My Bookings"
        ]
        contentStack.addArrangedSubview(makeTextCard(title: "How to use", text: steps.joined(separator: "\n\n")))

        contentStack.addArrangedSubview(makeTextCard(
            title: "Seat legend",
            text: "Available  - Open for selection\n\nSelected   - Your chosen seats\n\nReserved   - Already booked"
        ))

        contentStack.addArrangedSubview(makeTextCard(
            title: "Disclaimer",
            text: "This classroom project uses simulated data. No payment is processed and no real cinema reservation is made."
        ))

        let versionLabel = CineSeatTheme.captionLabel("CineSeat - Low-fidelity wireframe - V1.0")
        versionLabel.textAlignment = .center
        contentStack.addArrangedSubview(versionLabel)
    }

    private func makeTextCard(title: String, text: String) -> CardView {
        let titleLabel = CineSeatTheme.captionLabel(title)
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.textColor = CineSeatTheme.secondaryText
        textLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return makeCard(with: stack)
    }
}
