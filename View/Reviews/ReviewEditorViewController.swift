import UIKit

// review create and edit form
// delete only appears when the current account already owns a review
final class ReviewEditorViewController: ScrollableViewController {
    var viewModel: ReviewEditorViewModel!

    private let ratingControl = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
    private let commentTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.pageTitle
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = viewModel.subject.title
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Rating"))
        ratingControl.selectedSegmentIndex = max(0, min(4, viewModel.initialRating - 1))
        ratingControl.accessibilityIdentifier = "reviewRatingControl"
        contentStack.addArrangedSubview(ratingControl)

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Comment"))
        commentTextView.text = viewModel.initialComment
        commentTextView.font = CineSeatFont.body
        commentTextView.textColor = CineSeatTheme.primaryText
        commentTextView.backgroundColor = CineSeatTheme.card
        commentTextView.layer.cornerRadius = CineSeatRadius.medium
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = CineSeatTheme.border.cgColor
        commentTextView.accessibilityIdentifier = "reviewCommentTextView"
        commentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
        contentStack.addArrangedSubview(commentTextView)

        let helpLabel = CineSeatTheme.captionLabel("3 to 500 characters")
        contentStack.addArrangedSubview(helpLabel)

        let saveButton = CineSeatTheme.primaryButton(title: "Save Review")
        saveButton.accessibilityIdentifier = "saveReviewButton"
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(saveButton)

        if viewModel.canDelete {
            let deleteButton = CineSeatTheme.secondaryButton(title: "Delete Review")
            deleteButton.accessibilityIdentifier = "deleteReviewButton"
            deleteButton.setTitleColor(.systemRed, for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            contentStack.addArrangedSubview(deleteButton)
        }
    }

    @objc private func saveTapped() {
        do {
            try viewModel.save(
                rating: ratingControl.selectedSegmentIndex + 1,
                comment: commentTextView.text
            )
            navigationController?.popViewController(animated: true)
        } catch {
            showError(error)
        }
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Review?",
            message: "This permanently removes your rating and comment.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep Review", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            do {
                try self.viewModel.delete()
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showError(error)
            }
        })
        present(alert, animated: true)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Review Not Saved",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
