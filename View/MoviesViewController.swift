import UIKit

// module 2 movies screen
// storyboard outlets connect the search filter and table view here
final class MoviesViewController: UIViewController {
    // this outlet connects to the movies table view
    @IBOutlet private weak var movieTableView: UITableView!
    // this outlet connects to the search bar above the movie list
    @IBOutlet private weak var searchBar: UISearchBar!
    // this outlet connects to the category segmented control
    @IBOutlet private weak var categorySegmentedControl: UISegmentedControl!

    private let factory = AppFactory.shared
    private lazy var viewModel = factory.makeMoviesViewModel()
    private let headerLabel = CineSeatTheme.captionLabel("")
    private let ratingSortButton = UIButton(type: .system)
    private let cinemaFilterButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        configureTableView()
        configureSearchBar()
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategory.rawValue
        updateMovieHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isRootScreen = navigationController?.viewControllers.first === self
        navigationController?.setNavigationBarHidden(isRootScreen, animated: animated)
    }

    private func configureTableView() {
        movieTableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        movieTableView.backgroundColor = .white
        movieTableView.separatorStyle = .none
        movieTableView.rowHeight = UITableView.automaticDimension
        movieTableView.estimatedRowHeight = 138

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 110))
        headerLabel.frame = CGRect(x: 20, y: 8, width: view.bounds.width - 40, height: 20)
        header.addSubview(headerLabel)

        ratingSortButton.frame = CGRect(x: 20, y: 34, width: view.bounds.width - 40, height: 30)
        ratingSortButton.contentHorizontalAlignment = .left
        ratingSortButton.titleLabel?.font = CineSeatFont.metadataSemibold
        ratingSortButton.setTitleColor(CineSeatTheme.primaryText, for: .normal)
        ratingSortButton.addTarget(self, action: #selector(ratingSortTapped), for: .touchUpInside)
        header.addSubview(ratingSortButton)

        cinemaFilterButton.frame = CGRect(x: 20, y: 68, width: view.bounds.width - 40, height: 36)
        cinemaFilterButton.contentHorizontalAlignment = .left
        cinemaFilterButton.showsMenuAsPrimaryAction = true
        cinemaFilterButton.accessibilityIdentifier = "moviesCinemaFilter"
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "mappin.and.ellipse")
        configuration.imagePadding = CineSeatSpacing.small
        configuration.titleLineBreakMode = .byTruncatingTail
        cinemaFilterButton.configuration = configuration
        header.addSubview(cinemaFilterButton)
        movieTableView.tableHeaderView = header
    }

    private func configureSearchBar() {
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = CineSeatFont.metadata
        searchBar.searchTextField.placeholder = "Search movies..."
        searchBar.backgroundImage = UIImage()
    }

    // value changed action from the storyboard category segmented control
    @IBAction private func categoryChanged(_ sender: UISegmentedControl) {
        viewModel.selectedCategory = MovieCategory(rawValue: sender.selectedSegmentIndex) ?? .all
        reloadMovies()
    }

    @objc private func ratingSortTapped() {
        viewModel.toggleRatingSortOrder()
        reloadMovies()
    }

    private func reloadMovies() {
        updateMovieHeader()
        movieTableView.reloadData()
    }

    private func updateMovieHeader() {
        headerLabel.text = viewModel.filterSummaryText
        ratingSortButton.isHidden = !viewModel.canSortRating
        ratingSortButton.setTitle(viewModel.ratingSortButtonTitle.uppercased(), for: .normal)
        cinemaFilterButton.configuration?.title = viewModel.cinemaFilterTitle
        updateCinemaMenu()
    }

    private func updateCinemaMenu() {
        let allCinemas = UIAction(
            title: "All Cinemas",
            state: viewModel.selectedCinemaName == nil ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.selectCinema(nil)
            self?.reloadMovies()
        }
        let cinemas = viewModel.availableCinemaNames.map { cinemaName in
            UIAction(
                title: cinemaName,
                state: viewModel.selectedCinemaName == cinemaName ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.selectCinema(cinemaName)
                self?.reloadMovies()
            }
        }
        cinemaFilterButton.menu = UIMenu(title: "Cinemas", options: .singleSelection, children: [allCinemas] + cinemas)
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        reloadMovies()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? MovieTableViewCell else {
            return UITableViewCell()
        }

        let movie = viewModel.filteredMovies[indexPath.row]
        cell.configure(with: movie, ratingSummary: viewModel.ratingSummary(for: movie))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = factory.makeMovieDetailViewController(
            movie: viewModel.filteredMovies[indexPath.row]
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
