import UIKit

// module 2 reviews screen
// this page displays app reviews separately from the online score
final class ReviewsViewController: UIViewController {
    var viewModel: ReviewsViewModel!

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.pageTitle
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
    }

    private func buildInterface() {
        let typeLabel = CineSeatTheme.captionLabel(viewModel.subjectTypeText)

        let titleLabel = UILabel()
        titleLabel.text = viewModel.subject.title
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        let onlineLabel = UILabel()
        onlineLabel.text = viewModel.ratingSummary.onlineRatingText
        onlineLabel.font = CineSeatFont.metadata
        onlineLabel.textColor = CineSeatTheme.secondaryText

        let appRatingLabel = UILabel()
        appRatingLabel.text = viewModel.ratingSummary.appRatingText
        appRatingLabel.font = CineSeatFont.metadataSemibold
        appRatingLabel.textColor = CineSeatTheme.primaryText
        appRatingLabel.numberOfLines = 0

        let summaryStack = UIStackView(arrangedSubviews: [typeLabel, titleLabel, onlineLabel, appRatingLabel])
        summaryStack.axis = .vertical
        summaryStack.spacing = CineSeatSpacing.small
        summaryStack.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = CineSeatTheme.captionLabel(viewModel.reviewCountText)
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.reuseIdentifier)
        tableView.backgroundColor = CineSeatTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.dataSource = self

        view.addSubview(summaryStack)
        view.addSubview(countLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CineSeatSpacing.large),
            summaryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            summaryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            countLabel.topAnchor.constraint(equalTo: summaryStack.bottomAnchor, constant: CineSeatSpacing.large),
            countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            countLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            tableView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: CineSeatSpacing.small),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ReviewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ReviewTableViewCell else { return UITableViewCell() }
        cell.configure(with: viewModel.reviews[indexPath.row])
        return cell
    }
}
