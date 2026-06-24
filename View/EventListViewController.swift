import UIKit

// module 2 event list screen
// concerts and seminars have browsing only for now
final class EventListViewController: UIViewController {
    var factory = AppFactory.shared
    var viewModel: EventListViewModel!

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let headerLabel = CineSeatTheme.captionLabel("")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        reloadEvents()
    }

    private func buildInterface() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = CineSeatTheme.card
        searchBar.searchTextField.font = CineSeatFont.metadata
        searchBar.searchTextField.placeholder = viewModel.searchPlaceholder
        searchBar.backgroundImage = UIImage()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
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

        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CineSeatSpacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.medium),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.medium),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: CineSeatSpacing.small),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func reloadEvents() {
        headerLabel.text = viewModel.headerText.uppercased()
        tableView.reloadData()
    }
}

extension EventListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        reloadEvents()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension EventListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EventTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? EventTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.event(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            factory.makeEventDetailViewController(event: viewModel.event(at: indexPath.row)),
            animated: true
        )
    }
}
