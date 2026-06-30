import UIKit

// shared UIKit list layout for concerts and seminars
// concrete controllers decide which detail screen should open
class TicketedShowingListViewController: UIViewController {
    var factory = AppFactory.shared
    var listViewModel: TicketedShowingListViewModeling!

    private let pageTitleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let statusSegmentedControl = UISegmentedControl(items: ShowingStatusFilter.allCases.map(\.title))
    private let ratingSortButton = UIButton(type: .system)
    private let venueFilterButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let headerLabel = CineSeatTheme.captionLabel("")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = listViewModel.title
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        reloadListings()
    }

    func makeDetailViewController(for listing: EventListing) -> UIViewController {
        preconditionFailure("A concert or seminar controller must provide its detail screen")
    }

    private func buildInterface() {
        pageTitleLabel.text = listViewModel.title
        pageTitleLabel.font = CineSeatFont.pageTitleHeavy
        pageTitleLabel.textColor = CineSeatTheme.primaryText
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = CineSeatFont.metadata
        searchBar.searchTextField.placeholder = listViewModel.searchPlaceholder
        searchBar.backgroundImage = UIImage()

        statusSegmentedControl.selectedSegmentIndex = listViewModel.selectedStatusFilter.rawValue
        statusSegmentedControl.addTarget(self, action: #selector(statusChanged(_:)), for: .valueChanged)
        statusSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        statusSegmentedControl.accessibilityIdentifier = "\(listViewModel.title.lowercased())StatusFilter"

        ratingSortButton.contentHorizontalAlignment = .left
        ratingSortButton.titleLabel?.font = CineSeatFont.metadataSemibold
        ratingSortButton.setTitleColor(CineSeatTheme.primaryText, for: .normal)
        ratingSortButton.addTarget(self, action: #selector(ratingSortTapped), for: .touchUpInside)
        ratingSortButton.translatesAutoresizingMaskIntoConstraints = false
        ratingSortButton.accessibilityIdentifier = "\(listViewModel.title.lowercased())RatingSort"

        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "mappin.and.ellipse")
        configuration.imagePadding = CineSeatSpacing.small
        configuration.titleLineBreakMode = .byTruncatingTail
        venueFilterButton.configuration = configuration
        venueFilterButton.translatesAutoresizingMaskIntoConstraints = false
        venueFilterButton.showsMenuAsPrimaryAction = true
        venueFilterButton.accessibilityIdentifier = "\(listViewModel.title.lowercased())VenueFilter"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TicketedShowingTableViewCell.self, forCellReuseIdentifier: TicketedShowingTableViewCell.reuseIdentifier)
        tableView.backgroundColor = CineSeatTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 138
        tableView.dataSource = self
        tableView.delegate = self

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 36))
        headerLabel.frame = CGRect(x: CineSeatSpacing.pageHorizontal, y: 8, width: view.bounds.width - 40, height: 22)
        header.addSubview(headerLabel)
        tableView.tableHeaderView = header

        view.addSubview(pageTitleLabel)
        view.addSubview(searchBar)
        view.addSubview(statusSegmentedControl)
        view.addSubview(ratingSortButton)
        view.addSubview(venueFilterButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CineSeatSpacing.medium),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            searchBar.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: CineSeatSpacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.medium),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.medium),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            statusSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: CineSeatSpacing.small),
            statusSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            statusSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            statusSegmentedControl.heightAnchor.constraint(equalToConstant: 36),

            ratingSortButton.topAnchor.constraint(equalTo: statusSegmentedControl.bottomAnchor, constant: CineSeatSpacing.small),
            ratingSortButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            ratingSortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            ratingSortButton.heightAnchor.constraint(equalToConstant: 34),

            venueFilterButton.topAnchor.constraint(equalTo: ratingSortButton.bottomAnchor, constant: CineSeatSpacing.small),
            venueFilterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            venueFilterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            venueFilterButton.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: venueFilterButton.bottomAnchor, constant: CineSeatSpacing.small),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func reloadListings() {
        headerLabel.text = listViewModel.headerText.uppercased()
        ratingSortButton.setTitle(listViewModel.ratingSortButtonTitle.uppercased(), for: .normal)
        venueFilterButton.configuration?.title = listViewModel.venueFilterTitle
        updateVenueMenu()
        tableView.reloadData()
    }

    @objc private func statusChanged(_ sender: UISegmentedControl) {
        listViewModel.selectedStatusFilter = ShowingStatusFilter(rawValue: sender.selectedSegmentIndex) ?? .all
        reloadListings()
    }

    @objc private func ratingSortTapped() {
        listViewModel.toggleRatingSortOrder()
        reloadListings()
    }

    private func updateVenueMenu() {
        let allVenues = UIAction(
            title: "All Venues",
            state: listViewModel.venueFilterTitle == "All Venues" ? .on : .off
        ) { [weak self] _ in
            self?.listViewModel.selectVenue(nil)
            self?.reloadListings()
        }

        let venues = listViewModel.availableVenues.map { venue in
            UIAction(
                title: venue,
                state: listViewModel.venueFilterTitle == venue ? .on : .off
            ) { [weak self] _ in
                self?.listViewModel.selectVenue(venue)
                self?.reloadListings()
            }
        }
        venueFilterButton.menu = UIMenu(title: "Venues", options: .singleSelection, children: [allVenues] + venues)
    }
}

extension TicketedShowingListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listViewModel.searchText = searchText
        reloadListings()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TicketedShowingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listViewModel.listings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TicketedShowingTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TicketedShowingTableViewCell else { return UITableViewCell() }
        let listing = listViewModel.listings[indexPath.row]
        cell.configure(with: listing, ratingSummary: listViewModel.ratingSummary(for: listing))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            makeDetailViewController(for: listViewModel.listings[indexPath.row]),
            animated: true
        )
    }
}
