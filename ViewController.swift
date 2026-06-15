import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var movieTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var categorySegmentedControl: UISegmentedControl!

    private let viewModel = MoviesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        categorySegmentedControl.selectedSegmentIndex = MovieCategory.all.rawValue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func configureTableView() {
        movieTableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        movieTableView.backgroundColor = .white
        movieTableView.separatorStyle = .none
        movieTableView.rowHeight = 126

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 32))
        let label = CineSeatTheme.captionLabel("Now showing - 4 films")
        label.frame = CGRect(x: 20, y: 8, width: view.bounds.width - 40, height: 20)
        header.addSubview(label)
        movieTableView.tableHeaderView = header
    }

    private func configureSearchBar() {
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        searchBar.searchTextField.placeholder = "Search movies..."
        searchBar.backgroundImage = UIImage()
    }

    @IBAction private func categoryChanged(_ sender: UISegmentedControl) {
        viewModel.selectedCategory = MovieCategory(rawValue: sender.selectedSegmentIndex) ?? .all
        movieTableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        movieTableView.reloadData()
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
        let detailViewController = MovieDetailViewController()
        detailViewController.movie = viewModel.filteredMovies[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
