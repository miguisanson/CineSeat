import UIKit

// TicketPlease and online reviews use separate data sources on the same screen
final class ReviewsViewController: UIViewController {
    var factory = AppFactory.shared
    var viewModel: ReviewsViewModel!
    var onlineViewModel: OnlineReviewsViewModel!

    private let onlineRatingLabel = UILabel()
    private let appRatingLabel = UILabel()
    private let sourceControl = UISegmentedControl(items: ["TicketPlease", "Online"])
    private let writeAccessLabel = UILabel()
    private let attributionLabel = UILabel()
    private let countLabel = CineSeatTheme.captionLabel("")
    private let reviewActionButton = CineSeatTheme.primaryButton(title: "Write a Review")
    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    private var showsOnlineReviews: Bool {
        sourceControl.selectedSegmentIndex == 1
    }

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
        reloadReviewSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
        reloadReviewSource()
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

        onlineRatingLabel.font = CineSeatFont.metadata
        onlineRatingLabel.textColor = CineSeatTheme.secondaryText
        appRatingLabel.font = CineSeatFont.metadataSemibold
        appRatingLabel.textColor = CineSeatTheme.primaryText
        appRatingLabel.numberOfLines = 0

        sourceControl.selectedSegmentIndex = 0
        sourceControl.accessibilityIdentifier = "reviewSourceControl"
        sourceControl.addTarget(self, action: #selector(sourceChanged), for: .valueChanged)

        writeAccessLabel.text = "Reviews can be written from Booking Detail after the booked showtime."
        writeAccessLabel.font = CineSeatFont.bodySmall
        writeAccessLabel.textColor = CineSeatTheme.secondaryText
        writeAccessLabel.numberOfLines = 0

        attributionLabel.text = "Online written reviews are provided by TMDB."
        attributionLabel.font = CineSeatFont.bodySmall
        attributionLabel.textColor = CineSeatTheme.secondaryText
        attributionLabel.numberOfLines = 0

        reviewActionButton.addTarget(self, action: #selector(reviewActionTapped), for: .touchUpInside)
        reviewActionButton.accessibilityIdentifier = "reviewActionButton"

        let summaryStack = UIStackView(arrangedSubviews: [
            typeLabel,
            titleLabel,
            onlineRatingLabel,
            appRatingLabel,
            sourceControl,
            writeAccessLabel,
            attributionLabel,
            reviewActionButton
        ])
        summaryStack.axis = .vertical
        summaryStack.spacing = CineSeatSpacing.small
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.reuseIdentifier)
        tableView.register(OnlineReviewTableViewCell.self, forCellReuseIdentifier: OnlineReviewTableViewCell.reuseIdentifier)
        tableView.backgroundColor = CineSeatTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        tableView.dataSource = self
        tableView.delegate = self

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
        viewModel.reload()
        reloadReviewSource()
    }

    @objc private func sourceChanged() {
        reloadReviewSource()
        guard showsOnlineReviews else { return }
        Task { [weak self] in
            guard let self else { return }
            await onlineViewModel.load()
            reloadReviewSource()
        }
    }

    private func reloadReviewSource() {
        let ratingSummary = viewModel.ratingSummary
        onlineRatingLabel.text = ratingSummary.onlineRating.map {
            RatingDisplayFormatter.sourcedText(for: $0, source: "Online")
        }
        onlineRatingLabel.isHidden = ratingSummary.onlineRating == nil
        let reviewWord = ratingSummary.reviewCount == 1 ? "review" : "reviews"
        appRatingLabel.text = ratingSummary.appRating.map {
            "\(RatingDisplayFormatter.sourcedText(for: $0, source: AppConstants.Brand.name)) from \(ratingSummary.reviewCount) \(reviewWord)"
        }
        appRatingLabel.isHidden = ratingSummary.appRating == nil
        attributionLabel.isHidden = !showsOnlineReviews
        writeAccessLabel.isHidden = showsOnlineReviews || viewModel.showsReviewAction
        reviewActionButton.isHidden = showsOnlineReviews || !viewModel.showsReviewAction
        reviewActionButton.setTitle(viewModel.reviewActionTitle.uppercased(), for: .normal)

        if showsOnlineReviews {
            countLabel.text = onlineViewModel.countText.uppercased()
            emptyLabel.text = onlineViewModel.emptyStateText
            emptyLabel.isHidden = !onlineViewModel.reviews.isEmpty
        } else {
            countLabel.text = viewModel.reviewCountText.uppercased()
            emptyLabel.text = "No TicketPlease reviews yet."
            emptyLabel.isHidden = !viewModel.reviews.isEmpty
        }
        tableView.reloadData()
    }

    @objc private func reviewActionTapped() {
        guard let profile = viewModel.currentProfile else {
            showMessage(title: "Login Required", message: viewModel.eligibility.message)
            return
        }

        let existingReview = viewModel.reviewForAction
        if existingReview == nil && !viewModel.eligibility.canReview {
            showMessage(title: "Review Not Available", message: viewModel.eligibility.message)
            return
        }

        navigationController?.pushViewController(
            factory.makeReviewEditorViewController(
                subject: viewModel.subject,
                author: profile,
                existingReview: existingReview,
                allowsMultipleReviews: viewModel.reviewTestingEnabled
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
        showsOnlineReviews ? onlineViewModel.reviews.count : viewModel.reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showsOnlineReviews {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: OnlineReviewTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? OnlineReviewTableViewCell else { return UITableViewCell() }
            cell.configure(with: onlineViewModel.reviews[indexPath.row])
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ReviewTableViewCell else { return UITableViewCell() }
        let review = viewModel.reviews[indexPath.row]
        cell.configure(with: review, isCurrentUser: viewModel.canEdit(review))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showsOnlineReviews {
            guard let url = onlineViewModel.reviews[indexPath.row].sourceURL else { return }
            UIApplication.shared.open(url)
            return
        }

        let review = viewModel.reviews[indexPath.row]
        guard viewModel.canEdit(review), let profile = viewModel.currentProfile else { return }
        navigationController?.pushViewController(
            factory.makeReviewEditorViewController(
                subject: viewModel.subject,
                author: profile,
                existingReview: review,
                allowsMultipleReviews: viewModel.reviewTestingEnabled
            ),
            animated: true
        )
    }
}
