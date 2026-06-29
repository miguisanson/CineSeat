import UIKit

// module 2 main showings screen
// this keeps movies concerts and seminars under one searchable tab
final class ShowingsViewController: UIViewController {
    var factory = AppFactory.shared
    private lazy var viewModel = factory.makeShowingsViewModel()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let categorySegmentedControl = UISegmentedControl()
    private let searchBar = UISearchBar()
    private let movieStatusSegmentedControl = UISegmentedControl(items: MovieCategory.allCases.map(\.title))
    private let locationFilterButton = UIButton(type: .system)
    private let ratingSortButton = UIButton(type: .system)
    private let filterButtonStack = UIStackView()
    private let summaryLabel = CineSeatTheme.captionLabel("")
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private var movieStatusHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Showings"
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        reloadShowings()
    }

    private func buildInterface() {
        configureHeader()
        configureCategoryFilter()
        configureSearchBar()
        configureMovieFilters()
        configureTableView()

        let controls = [
            titleLabel,
            subtitleLabel,
            categorySegmentedControl,
            searchBar,
            movieStatusSegmentedControl,
            filterButtonStack,
            summaryLabel,
            tableView
        ]
        controls.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        movieStatusHeightConstraint = movieStatusSegmentedControl.heightAnchor.constraint(equalToConstant: 34)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CineSeatSpacing.medium),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CineSeatSpacing.tiny),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            categorySegmentedControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: CineSeatSpacing.medium),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 34),

            searchBar.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: CineSeatSpacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.medium),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.medium),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            movieStatusSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: CineSeatSpacing.small),
            movieStatusSegmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            movieStatusSegmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            movieStatusHeightConstraint,

            filterButtonStack.topAnchor.constraint(equalTo: movieStatusSegmentedControl.bottomAnchor, constant: CineSeatSpacing.small),
            filterButtonStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            filterButtonStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            filterButtonStack.heightAnchor.constraint(equalToConstant: 44),

            summaryLabel.topAnchor.constraint(equalTo: filterButtonStack.bottomAnchor, constant: CineSeatSpacing.small),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: CineSeatSpacing.small),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureHeader() {
        titleLabel.text = "CineSeat Showings"
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        subtitleLabel.text = viewModel.headerText
        subtitleLabel.font = CineSeatFont.body
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0
    }

    private func configureCategoryFilter() {
        for (index, category) in viewModel.categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category.title, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategory.rawValue
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged(_:)), for: .valueChanged)
        categorySegmentedControl.accessibilityIdentifier = "showingCategoryFilter"
    }

    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = CineSeatFont.metadata
        searchBar.backgroundImage = UIImage()
        searchBar.accessibilityIdentifier = "showingsSearchBar"
    }

    private func configureMovieFilters() {
        movieStatusSegmentedControl.selectedSegmentIndex = viewModel.selectedMovieCategory.rawValue
        movieStatusSegmentedControl.addTarget(self, action: #selector(movieStatusChanged(_:)), for: .valueChanged)
        movieStatusSegmentedControl.accessibilityIdentifier = "movieStatusFilter"

        configureFilterButton(locationFilterButton, imageName: "mappin.and.ellipse")
        locationFilterButton.showsMenuAsPrimaryAction = true
        locationFilterButton.accessibilityIdentifier = "locationFilterButton"

        configureFilterButton(ratingSortButton, imageName: "arrow.up.arrow.down")
        ratingSortButton.addTarget(self, action: #selector(ratingSortTapped), for: .touchUpInside)
        ratingSortButton.accessibilityIdentifier = "ratingSortButton"

        filterButtonStack.axis = .horizontal
        filterButtonStack.spacing = CineSeatSpacing.small
        filterButtonStack.distribution = .fillEqually
        filterButtonStack.addArrangedSubview(locationFilterButton)
        filterButtonStack.addArrangedSubview(ratingSortButton)
    }

    private func configureFilterButton(_ button: UIButton, imageName: String) {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: imageName)
        configuration.imagePadding = CineSeatSpacing.small
        configuration.titleLineBreakMode = .byTruncatingTail
        button.configuration = configuration
    }

    private func configureTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.backgroundColor = CineSeatTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 138
        tableView.dataSource = self
        tableView.delegate = self

        emptyStateLabel.font = CineSeatFont.body
        emptyStateLabel.textColor = CineSeatTheme.secondaryText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }

    private func reloadShowings() {
        searchBar.searchTextField.placeholder = viewModel.searchPlaceholder
        movieStatusSegmentedControl.isHidden = !viewModel.showsMovieFilters
        movieStatusHeightConstraint.constant = viewModel.showsMovieFilters ? 34 : 0
        ratingSortButton.isHidden = !viewModel.showsMovieFilters
        updateLocationMenu()
        updateFilterButtonTitles()
        summaryLabel.text = viewModel.filterSummaryText.uppercased()
        emptyStateLabel.text = viewModel.emptyStateText
        tableView.backgroundView = viewModel.filteredItems.isEmpty ? emptyStateLabel : nil
        tableView.reloadData()
    }

    private func updateLocationMenu() {
        let allLocations = UIAction(
            title: viewModel.selectedCategory.allLocationsTitle,
            state: viewModel.selectedLocationName == nil ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.selectLocation(nil)
            self?.reloadShowings()
        }

        let locations = viewModel.availableLocationNames.map { locationName in
            UIAction(
                title: locationName,
                state: viewModel.selectedLocationName == locationName ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.selectLocation(locationName)
                self?.reloadShowings()
            }
        }

        locationFilterButton.menu = UIMenu(
            title: viewModel.selectedCategory.locationFilterLabel,
            options: .singleSelection,
            children: [allLocations] + locations
        )
    }

    private func updateFilterButtonTitles() {
        locationFilterButton.configuration?.title = viewModel.locationFilterTitle
        ratingSortButton.configuration?.title = viewModel.ratingSortButtonTitle
    }

    @objc private func categoryChanged(_ sender: UISegmentedControl) {
        viewModel.selectCategory(at: sender.selectedSegmentIndex)
        reloadShowings()
    }

    @objc private func movieStatusChanged(_ sender: UISegmentedControl) {
        viewModel.selectedMovieCategory = MovieCategory(rawValue: sender.selectedSegmentIndex) ?? .all
        reloadShowings()
    }

    @objc private func ratingSortTapped() {
        viewModel.toggleRatingSortOrder()
        reloadShowings()
    }
}

extension ShowingsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        reloadShowings()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ShowingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.item(at: indexPath.row) {
        case .movie(let movie):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MovieTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? MovieTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: movie)
            return cell
        case .event(let event):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EventTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? EventTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: event)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.item(at: indexPath.row) {
        case .movie(let movie):
            navigationController?.pushViewController(
                factory.makeMovieDetailViewController(movie: movie),
                animated: true
            )
        case .event(let event):
            navigationController?.pushViewController(
                factory.makeEventDetailViewController(event: event),
                animated: true
            )
        }
    }
}
