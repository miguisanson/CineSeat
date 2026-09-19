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
    private lazy var listHeaderView = ShowingListTableHeaderView(
        frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: ShowingListTableHeaderView.height),
        countAccessibilityIdentifier: "moviesResultCount",
        ratingAccessibilityIdentifier: "moviesRatingSort",
        locationAccessibilityIdentifier: "moviesCinemaFilter"
    )

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

        listHeaderView.ratingSortButton.addTarget(self, action: #selector(ratingSortTapped), for: .touchUpInside)
        movieTableView.tableHeaderView = listHeaderView
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
        listHeaderView.countLabel.text = viewModel.filterSummaryText.uppercased()
        listHeaderView.ratingSortButton.isHidden = !viewModel.canSortRating
        listHeaderView.ratingSortButton.setTitle(viewModel.ratingSortButtonTitle.uppercased(), for: .normal)
        listHeaderView.locationFilterButton.configuration?.title = viewModel.cinemaFilterTitle
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
        listHeaderView.locationFilterButton.menu = UIMenu(
            title: "Cinemas",
            options: .singleSelection,
            children: [allCinemas] + cinemas
        )
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
