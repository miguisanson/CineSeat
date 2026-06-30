import UIKit

// module 2 reviews screen
// app reviews remain separate from the online score
final class ReviewsViewController: UIViewController {
    var factory = AppFactory.shared
    var viewModel: ReviewsViewModel!

    private let onlineLabel = UILabel()
    private let appRatingLabel = UILabel()
    private let countLabel = CineSeatTheme.captionLabel("")
    private let reviewActionButton = CineSeatTheme.primaryButton(title: "Write a Review")
    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.pageTitle
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reviewsChanged),
            name: viewModel.didChangeNotification,
            object: nil
        )
        reloadReviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadReviews()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func buildInterface() {
        let typeLabel = CineSeatTheme.captionLabel(viewModel.subjectTypeText)

        let titleLabel = UILabel()
        titleLabel.text = viewModel.subject.title
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        onlineLabel.font = CineSeatFont.metadata
        onlineLabel.textColor = CineSeatTheme.secondaryText
        appRatingLabel.font = CineSeatFont.metadataSemibold
        appRatingLabel.textColor = CineSeatTheme.primaryText
        appRatingLabel.numberOfLines = 0

        reviewActionButton.addTarget(self, action: #selector(reviewActionTapped), for: .touchUpInside)
        reviewActionButton.accessibilityIdentifier = "reviewActionButton"

        let summaryStack = UIStackView(arrangedSubviews: [
            typeLabel,
            titleLabel,
            onlineLabel,
            appRatingLabel,
            reviewActionButton
        ])
        summaryStack.axis = .vertical
        summaryStack.spacing = CineSeatSpacing.small
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.reuseIdentifier)
        tableView.backgroundColor = CineSeatTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.dataSource = self
        tableView.delegate = self

        emptyLabel.text = "No TicketPlease reviews yet."
        emptyLabel.font = CineSeatFont.body
        emptyLabel.textColor = CineSeatTheme.secondaryText
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.accessibilityIdentifier = "reviewsEmptyLabel"
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(summaryStack)
        view.addSubview(countLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

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
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal)
        ])
    }

    @objc private func reviewsChanged() {
        reloadReviews()
    }

    private func reloadReviews() {
        viewModel.reload()
        onlineLabel.text = viewModel.ratingSummary.onlineRatingText
        appRatingLabel.text = viewModel.ratingSummary.appRatingText
        countLabel.text = viewModel.reviewCountText.uppercased()
        reviewActionButton.setTitle(viewModel.reviewActionTitle.uppercased(), for: .normal)
        emptyLabel.isHidden = !viewModel.reviews.isEmpty
        tableView.reloadData()
    }

    @objc private func reviewActionTapped() {
        guard let profile = viewModel.currentProfile else {
            showMessage(title: "Login Required", message: viewModel.eligibility.message)
            return
        }

        let existingReview = viewModel.currentUserReview
        if existingReview == nil && !viewModel.eligibility.canReview {
            showMessage(title: "Review Not Available", message: viewModel.eligibility.message)
            return
        }

        navigationController?.pushViewController(
            factory.makeReviewEditorViewController(
                subject: viewModel.subject,
                author: profile,
                existingReview: existingReview
            ),
            animated: true
        )
    }

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ReviewTableViewCell else { return UITableViewCell() }
        let review = viewModel.reviews[indexPath.row]
        cell.configure(with: review, isCurrentUser: viewModel.canEdit(review))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = viewModel.reviews[indexPath.row]
        guard viewModel.canEdit(review), let profile = viewModel.currentProfile else { return }
        navigationController?.pushViewController(
            factory.makeReviewEditorViewController(
                subject: viewModel.subject,
                author: profile,
                existingReview: review
            ),
            animated: true
        )
    }
}
