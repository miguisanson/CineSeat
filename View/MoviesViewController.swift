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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategory.rawValue
        updateMovieHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func configureTableView() {
        movieTableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        movieTableView.backgroundColor = .white
        movieTableView.separatorStyle = .none
        movieTableView.rowHeight = UITableView.automaticDimension
        movieTableView.estimatedRowHeight = 138

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 72))
        headerLabel.frame = CGRect(x: 20, y: 8, width: view.bounds.width - 40, height: 20)
        header.addSubview(headerLabel)

        ratingSortButton.frame = CGRect(x: 20, y: 34, width: view.bounds.width - 40, height: 30)
        ratingSortButton.contentHorizontalAlignment = .left
        ratingSortButton.titleLabel?.font = .monospacedSystemFont(ofSize: 10, weight: .semibold)
        ratingSortButton.setTitleColor(CineSeatTheme.primaryText, for: .normal)
        ratingSortButton.addTarget(self, action: #selector(ratingSortTapped), for: .touchUpInside)
        header.addSubview(ratingSortButton)
        movieTableView.tableHeaderView = header
    }

    private func configureSearchBar() {
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
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

        cell.configure(with: viewModel.filteredMovies[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = factory.makeMovieDetailViewController(
            movie: viewModel.filteredMovies[indexPath.row]
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
