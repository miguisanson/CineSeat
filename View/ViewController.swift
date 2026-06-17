import UIKit

// module 2 movies screen
// storyboard outlets connect the search filter and table view here
final class ViewController: UIViewController {
    // this outlet connects to the movies table view
    @IBOutlet private weak var movieTableView: UITableView!
    // this outlet connects to the search bar above the movie list
    @IBOutlet private weak var searchBar: UISearchBar!
    // this outlet connects to the category segmented control
    @IBOutlet private weak var categorySegmentedControl: UISegmentedControl!
    // storyboard button at the top right, shows profile initials when signed in
    @IBOutlet private weak var profileShortcutButton: UIButton!

    private let factory = AppFactory.shared
    private lazy var viewModel = factory.makeMoviesViewModel()
    private lazy var profileViewModel = factory.makeProfileViewModel()
    private let headerLabel = CineSeatTheme.captionLabel("")
    private let ratingSortButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        configureProfileShortcutButton()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged),
            name: profileViewModel.authenticationDidChangeNotification,
            object: nil
        )
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategory.rawValue
        updateMovieHeader()
        updateProfileShortcutButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateProfileShortcutButton()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    private func configureProfileShortcutButton() {
        profileShortcutButton.layer.cornerRadius = 18
        profileShortcutButton.clipsToBounds = true
        profileShortcutButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        profileShortcutButton.accessibilityIdentifier = "profileShortcutButton"
        profileShortcutButton.accessibilityLabel = "Open Profile"
    }

    @objc private func authenticationChanged() {
        updateProfileShortcutButton()
    }

    private func updateProfileShortcutButton() {
        if let profile = profileViewModel.currentProfile {
            profileShortcutButton.setImage(nil, for: .normal)
            profileShortcutButton.setTitle(profile.initials, for: .normal)
            profileShortcutButton.setTitleColor(.white, for: .normal)
            profileShortcutButton.backgroundColor = CineSeatTheme.primaryText
            profileShortcutButton.layer.borderWidth = 0
        } else {
            profileShortcutButton.setTitle(nil, for: .normal)
            profileShortcutButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            profileShortcutButton.tintColor = CineSeatTheme.mutedText
            profileShortcutButton.backgroundColor = .clear
            profileShortcutButton.layer.borderWidth = 0
        }
    }

    // storyboard action from the profile shortcut button
    @IBAction private func profileShortcutTapped(_ sender: UIButton) {
        tabBarController?.selectedIndex = 2
        if let profileNavigation = tabBarController?.selectedViewController as? UINavigationController {
            profileNavigation.popToRootViewController(animated: false)
        }
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

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        reloadMovies()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
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
