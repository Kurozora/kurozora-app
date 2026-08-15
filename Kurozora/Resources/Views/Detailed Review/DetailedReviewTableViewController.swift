//
//  DetailedReviewTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol DetailedReviewTableViewControllerDelegate: AnyObject {
	func detailedReviewTableViewControllerDidSubmitReview()
	func detailedReviewTableViewControllerDidDeleteReview()
}

/// A review editor that scores a model per rating category.
final class DetailedReviewTableViewController: KTableViewController {
	// MARK: - Properties
	// Refresh control
	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// Activity indicator
	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	/// The model being rated.
	var kind: ReviewKind?

	/// The user's current rating of the model.
	var rating: Double?

	/// The user's private note on the model.
	var note: String?

	/// The rating categories of the model with the user's scores.
	var ratingCategories: [RatingCategory] = []

	/// The scores the editor opened with.
	private var originalScores: [KurozoraItemID: Double] = [:]

	/// The per-category reviews the editor opened with.
	private var originalReviews: [KurozoraItemID: String] = [:]

	/// The private note the editor opened with.
	private var originalNote: String?

	/// Whether the user made a change since presentation.
	private var hasChanges: Bool {
		if self.note != self.originalNote { return true }

		return self.ratingCategories.contains { ratingCategory in
			ratingCategory.attributes.score != self.originalScores[ratingCategory.id]
				|| (ratingCategory.attributes.review ?? "") != (self.originalReviews[ratingCategory.id] ?? "")
		}
	}

	private var cancelBarButtonItem: UIBarButtonItem!
	private var sendBarButtonItem: UIBarButtonItem!
	private var deleteBarButtonItem: UIBarButtonItem!

	weak var delegate: DetailedReviewTableViewControllerDelegate?

	// MARK: - Initializers
	init() {
		super.init(style: .grouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.writeAReview

		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.sheetPresentationController?.detents = [.large()]
		self.sheetPresentationController?.prefersGrabberVisible = true

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.tableView.keyboardDismissMode = .interactive
		self.tableView.separatorStyle = .none
		self.tableView.sectionHeaderTopPadding = 0

		self.seedUnscoredCategories()
		self.captureOriginalValues()
		self.configureNavigationItems()
		self.updateStarTranslation()
	}

	// MARK: - Functions
	private func configureNavigationItems() {
		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonPressed(_:)))
		self.sendBarButtonItem = UIBarButtonItem(title: L10n.send, style: .done, target: self, action: #selector(self.sendButtonPressed(_:)))
		self.deleteBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(self.deleteButtonPressed(_:)))
		self.deleteBarButtonItem.tintColor = .systemRed

		if (self.rating ?? 0) > 0 {
			self.navigationItem.leftBarButtonItems = [self.cancelBarButtonItem, self.deleteBarButtonItem]
		} else {
			self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		}

		self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
		self.updateUnsavedChangesState()
	}

	private func updateUnsavedChangesState() {
		let hasSubmittableChanges = self.hasChanges || (self.rating ?? 0) <= 0
		self.navigationItem.rightBarButtonItem?.isEnabled = hasSubmittableChanges && !self.ratingCategories.isEmpty
		self.isModalInPresentation = self.hasChanges
	}

	/// Stores the values the editor opened with.
	private func captureOriginalValues() {
		self.originalNote = self.note

		for ratingCategory in self.ratingCategories {
			self.originalScores[ratingCategory.id] = ratingCategory.attributes.score
			self.originalReviews[ratingCategory.id] = ratingCategory.attributes.review ?? ""
		}
	}

	/// Shows the star rating the scores currently translate to.
	private func updateStarTranslation() {
		guard !self.ratingCategories.isEmpty else {
			self.navigationItem.prompt = nil
			return
		}

		self.navigationItem.prompt = L10n.outOfFiveStars(self.ratingCategories.formattedStarRating)
	}

	/// Applies a starting score to the categories the user has not scored.
	private func seedUnscoredCategories() {
		let defaultScore = (self.rating ?? 0) > 0
			? (self.rating ?? 0) * (RatingCategory.Attributes.maximumScore / 5.0)
			: RatingCategory.Attributes.maximumScore / 2.0

		for ratingCategory in self.ratingCategories where ratingCategory.attributes.score == nil {
			ratingCategory.attributes.score = defaultScore
		}
	}

	// MARK: - Actions
	@objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
		if self.hasChanges {
			self.presentDiscardConfirmation()
		} else {
			self.dismiss(animated: true)
		}
	}

	@objc private func deleteButtonPressed(_ sender: UIBarButtonItem) {
		self.confirmDeleteRating(onConfirm: { [weak self] in
			guard let self = self else { return }
			self.performDeleteRating()
		}, onCancel: {})
	}

	@objc private func sendButtonPressed(_ sender: UIBarButtonItem) {
		sender.isEnabled = false

		Task { @MainActor [weak self] in
			guard let self = self else { return }
			await self.performSubmit()
		}
	}

	private func performDeleteRating() {
		guard let kind = self.kind else { return }

		Task { [weak self] in
			guard let self = self else { return }

			do throws(APIError) {
				let didDelete = try await kind.deleteRating()

				guard didDelete else {
					self.presentAlertController(title: L10n.ratingFailed, message: L10n.notAvailableForType)
					return
				}

				self.delegate?.detailedReviewTableViewControllerDidDeleteReview()
				self.dismiss(animated: true)
			} catch {
				self.presentAlertController(title: L10n.ratingFailed, message: error.message)
			}
		}
	}

	@MainActor
	private func performSubmit() async {
		guard let kind = self.kind else {
			self.sendBarButtonItem.isEnabled = true
			return
		}

		do throws(APIError) {
			let didSubmit = try await kind.rate(categoryScores: self.ratingCategories, description: nil, note: self.note)

			guard didSubmit else {
				self.presentAlertController(title: L10n.cantSaveReview, message: nil)
				self.sendBarButtonItem.isEnabled = true
				return
			}

			self.dismiss(animated: true) {
				self.delegate?.detailedReviewTableViewControllerDidSubmitReview()
			}
		} catch {
			self.presentAlertController(title: L10n.cantSaveReview, message: error.message)
			self.sendBarButtonItem.isEnabled = true
		}
	}

	private func presentDiscardConfirmation() {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }

			actionSheetAlertController.addAction(UIAlertAction(title: L10n.discard, style: .destructive) { _ in
				self.dismiss(animated: true)
			})
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = self.cancelBarButtonItem
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}
}

// MARK: - KTableViewDataSource
extension DetailedReviewTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			PrivateNoteTableViewCell.self,
			RatingCategoryTableViewCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension DetailedReviewTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.ratingCategories.isEmpty ? 0 : self.ratingCategories.count + 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let ratingCategory = self.ratingCategories[safe: indexPath.section] else {
			guard let privateNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: PrivateNoteTableViewCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(PrivateNoteTableViewCell.reuseID)")
			}

			privateNoteTableViewCell.delegate = self
			privateNoteTableViewCell.configure(using: self.note)

			return privateNoteTableViewCell
		}

		guard let ratingCategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: RatingCategoryTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(RatingCategoryTableViewCell.reuseID)")
		}

		ratingCategoryTableViewCell.delegate = self
		ratingCategoryTableViewCell.configure(using: ratingCategory)

		return ratingCategoryTableViewCell
	}

}

// MARK: - PrivateNoteTableViewCellDelegate
extension DetailedReviewTableViewController: PrivateNoteTableViewCellDelegate {
	func privateNoteTableViewCell(_ cell: PrivateNoteTableViewCell, didChangeNote note: String) {
		self.note = note.isEmpty ? nil : note
		self.updateUnsavedChangesState()
	}
}

// MARK: - UITableViewDelegate
extension DetailedReviewTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return .leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return .leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
}

// MARK: - RatingCategoryTableViewCellDelegate
extension DetailedReviewTableViewController: RatingCategoryTableViewCellDelegate {
	func ratingCategoryTableViewCell(_ cell: RatingCategoryTableViewCell, didChangeScore score: Double) {
		guard
			let indexPath = self.tableView.indexPath(for: cell),
			let ratingCategory = self.ratingCategories[safe: indexPath.section]
		else { return }

		ratingCategory.attributes.score = score
		self.updateStarTranslation()
		self.updateUnsavedChangesState()
	}

	func ratingCategoryTableViewCell(_ cell: RatingCategoryTableViewCell, didChangeReview review: String) {
		guard
			let indexPath = self.tableView.indexPath(for: cell),
			let ratingCategory = self.ratingCategories[safe: indexPath.section]
		else { return }

		ratingCategory.attributes.review = review.isEmpty ? nil : review
		self.updateUnsavedChangesState()
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension DetailedReviewTableViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		self.presentDiscardConfirmation()
	}
}
