//
//  ReviewEditorCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
import IQKeyboardManagerSwift
#endif
import KurozoraKit
import UIKit

protocol ReviewEditorCollectionViewControllerDelegate: AnyObject {
	func reviewEditorCollectionViewControllerDidSubmitReview()
	func reviewEditorCollectionViewControllerDidDeleteReview()
}

extension ReviewEditorCollectionViewControllerDelegate {
	func reviewEditorCollectionViewControllerDidDeleteReview() {}
}

/// The values a screen hands the review editor for the item it shows.
struct ReviewEditorContext {
	/// The model being rated and reviewed.
	let kind: ReviewKind

	/// The user's rating of the model.
	let rating: Double?

	/// The user's review of the model.
	let review: String?

	/// The user's private note on the model.
	let note: String?

	/// Whether the user's review contains spoiler material.
	let isSpoiler: Bool

	/// The reviewer's recommendation.
	let recommendation: ReviewRecommendation?
}

protocol ReviewEditorContextProviding: AnyObject {
	/// Returns the editor configuration of the item the screen shows.
	func writeAReviewContext() -> ReviewEditorContext?
}

/// A review editor that adapts to the user's rating style.
final class ReviewEditorCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	/// The model being rated and reviewed.
	var kind: ReviewKind?

	/// The user's current rating of the model.
	var rating: Double?

	/// The user's current review of the model.
	var review: String?

	/// The user's private note on the model.
	var note: String?

	/// Whether the user's review contains spoiler material.
	var isSpoiler: Bool = false

	/// The reviewer's recommendation.
	var recommendation: ReviewRecommendation?

	/// The rating categories of the model with the user's scores.
	var ratingCategories: [RatingCategory] = []

	/// Whether the editor scores the model per rating category.
	var isDetailed: Bool {
		return !self.ratingCategories.isEmpty
	}

	/// The rating shown when the item is unrated.
	static let defaultRating: Double = 2.5

	/// The rating the editor opened with.
	private var originalRating: Double?

	/// The review the editor opened with.
	private var originalReview: String?

	/// The private note the editor opened with.
	private var originalNote: String?

	/// The spoiler state the editor opened with.
	private var originalIsSpoiler: Bool = false

	/// The recommendation the editor opened with.
	private var originalRecommendation: ReviewRecommendation?

	/// The category scores the editor opened with.
	private var originalScores: [KurozoraItemID: Double] = [:]

	/// The per-category reviews the editor opened with.
	private var originalReviews: [KurozoraItemID: String] = [:]

	/// Whether the user changed anything since presentation.
	private var hasChanges: Bool {
		guard self.isDetailed else {
			return self.rating != self.originalRating
				|| (self.review ?? "") != (self.originalReview ?? "")
				|| (self.note ?? "") != (self.originalNote ?? "")
				|| self.isSpoiler != self.originalIsSpoiler
				|| self.recommendation != self.originalRecommendation
		}

		if (self.note ?? "") != (self.originalNote ?? "") { return true }
		if self.isSpoiler != self.originalIsSpoiler { return true }
		if self.recommendation != self.originalRecommendation { return true }

		return self.ratingCategories.contains { ratingCategory in
			ratingCategory.attributes.score != self.originalScores[ratingCategory.id]
				|| (ratingCategory.attributes.review ?? "") != (self.originalReviews[ratingCategory.id] ?? "")
		}
	}

	private var cancelBarButtonItem: UIBarButtonItem!
	private var sendBarButtonItem: UIBarButtonItem!
	private var deleteBarButtonItem: UIBarButtonItem!

	weak var delegate: ReviewEditorCollectionViewControllerDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.writeAReview
		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.collectionView.keyboardDismissMode = .interactive

		self.configureSheetPresentation()
		self.seedUnscoredCategories()
		self.captureOriginalValues()
		self.configureNavigationItems()
		self.updateStarTranslation()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = false
		#endif
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		guard !self.isDetailed else { return }

		OffTopicContentFilter.shared.prewarm()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		#endif
	}

	// MARK: - Functions
	private func configureSheetPresentation() {
		self.sheetPresentationController?.prefersGrabberVisible = true

		guard !self.isDetailed else {
			self.sheetPresentationController?.detents = [.large()]
			return
		}

		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
	}

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

	/// Enables the send button and guards dismissal while the editor holds changes.
	private func updateUnsavedChangesState() {
		self.isModalInPresentation = self.hasChanges

		guard self.isDetailed else {
			let needsReaction = UserSettings.ratingStyle == .quickReaction && (self.rating ?? 0) <= 0
			self.navigationItem.rightBarButtonItem?.isEnabled = self.hasChanges && !needsReaction && self.recommendation != nil
			return
		}

		let hasSubmittableChanges = self.hasChanges || (self.rating ?? 0) <= 0
		self.navigationItem.rightBarButtonItem?.isEnabled = hasSubmittableChanges && !self.ratingCategories.isEmpty && self.recommendation != nil
	}

	/// Stores the values the editor opened with.
	private func captureOriginalValues() {
		self.originalRating = self.rating
		self.originalReview = self.review
		self.originalNote = self.note
		self.originalIsSpoiler = self.isSpoiler
		self.originalRecommendation = self.recommendation

		for ratingCategory in self.ratingCategories {
			self.originalScores[ratingCategory.id] = ratingCategory.attributes.score
			self.originalReviews[ratingCategory.id] = ratingCategory.attributes.review ?? ""
		}
	}

	/// Shows the star rating the category scores currently translate to.
	private func updateStarTranslation() {
		guard self.isDetailed else {
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
			self.presentDiscardConfirmation(showingSend: false)
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

			if !self.isDetailed, await OffTopicContentFilter.shared.isOffTopicSourceSeeking(self.review ?? "") {
				self.sendBarButtonItem.isEnabled = true
				self.presentOffTopicWarning()
				return
			}

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

				self.delegate?.reviewEditorCollectionViewControllerDidDeleteReview()
				self.dismiss(animated: true)
			} catch {
				self.presentAlertController(title: L10n.ratingFailed, message: error.message)
			}
		}
	}

	/// Submits the rating and review to the backend.
	@MainActor
	private func performSubmit() async {
		guard let kind = self.kind else {
			self.presentAlertController(title: L10n.cantSaveReview, message: "No review kind was specified. Bad developer :O")
			self.sendBarButtonItem.isEnabled = true
			return
		}

		do throws(APIError) {
			let didSubmit = try await self.submit(using: kind)

			guard didSubmit else {
				self.presentAlertController(title: L10n.cantSaveReview, message: nil)
				self.sendBarButtonItem.isEnabled = true
				return
			}

			self.dismiss(animated: true) {
				self.delegate?.reviewEditorCollectionViewControllerDidSubmitReview()
			}
		} catch {
			print(error.localizedDescription)
			self.presentAlertController(title: L10n.cantSaveReview, message: error.message)
			self.sendBarButtonItem.isEnabled = true
		}
	}

	/// Sends the editor's values in the shape the user's rating style calls for.
	///
	/// - Parameter kind: The model being rated and reviewed.
	///
	/// - Returns: `true` when the submission succeeds.
	private func submit(using kind: ReviewKind) async throws(APIError) -> Bool {
		guard !self.isDetailed else {
			return try await kind.rate(categoryScores: self.ratingCategories, description: nil, note: self.note, isSpoiler: self.isSpoiler, recommendation: self.recommendation)
		}

		let existingRating = self.rating ?? 0.0
		let rating = existingRating > 0 ? existingRating : Self.defaultRating

		return try await kind.rate(using: rating, description: self.review, note: self.note, isSpoiler: self.isSpoiler, recommendation: self.recommendation)
	}

	/// Presents the off-topic content warning.
	private func presentOffTopicWarning() {
		let alertController = UIAlertController.alert(
			title: L10n.offTopicWarningHeadline,
			message: L10n.offTopicWarningSubheadline,
			defaultActionButtonTitle: L10n.cancel
		) { alertController in
			alertController.addAction(UIAlertAction(title: L10n.offTopicViewGuidelines, style: .default) { _ in
				UIApplication.shared.kOpen(.communityGuidelinesURL)
			})

			alertController.addAction(UIAlertAction(title: L10n.offTopicPostAnyway, style: .destructive) { [weak self] _ in
				guard let self = self else { return }
				self.sendBarButtonItem.isEnabled = false

				Task { @MainActor in
					await self.performSubmit()
				}
			})
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(alertController, animated: true, completion: nil)
		}
	}

	/// Presents the discard changes action sheet.
	///
	/// - Parameter showingSend: Whether the sheet offers a send action alongside discard.
	private func presentDiscardConfirmation(showingSend: Bool) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			if showingSend {
				actionSheetAlertController.addAction(UIAlertAction(title: L10n.send, style: .default) { _ in
					Task { @MainActor in
						await self.performSubmit()
					}
				})
			}

			actionSheetAlertController.addAction(UIAlertAction(title: L10n.discard, style: .destructive) { [weak self] _ in
				self?.dismiss(animated: true)
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

// MARK: - RateCollectionViewCellDelegate
extension ReviewEditorCollectionViewController: RateCollectionViewCellDelegate {
	func rateCollectionViewCell(_ cell: RateCollectionViewCell, rateWith rating: Double) {
		guard rating > 0 else { return }

		self.rating = rating
		self.updateUnsavedChangesState()
	}
}

// MARK: - ReviewInputCollectionViewCellDelegate
extension ReviewEditorCollectionViewController: ReviewInputCollectionViewCellDelegate {
	func reviewInputCollectionViewCell(_ cell: ReviewInputCollectionViewCell, didChangeText text: String) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let section = self.sections[safe: indexPath.section]
		else { return }

		switch section {
		case .privateNote:
			self.note = text.isEmpty ? nil : text
		default:
			self.review = text
		}

		self.updateUnsavedChangesState()
	}
}

// MARK: - RecommendationSegmentedCollectionViewCellDelegate
extension ReviewEditorCollectionViewController: RecommendationSegmentedCollectionViewCellDelegate {
	func recommendationSegmentedCollectionViewCell(_ cell: RecommendationSegmentedCollectionViewCell, didSelect recommendation: ReviewRecommendation?) {
		self.recommendation = recommendation
		self.updateUnsavedChangesState()
	}
}

// MARK: - SpoilerToggleCollectionViewCellDelegate
extension ReviewEditorCollectionViewController: SpoilerToggleCollectionViewCellDelegate {
	func spoilerToggleCollectionViewCell(_ cell: SpoilerToggleCollectionViewCell, didSet isOn: Bool) {
		self.isSpoiler = isOn
		self.updateUnsavedChangesState()
	}
}

// MARK: - RatingCategoryCollectionViewCellDelegate
extension ReviewEditorCollectionViewController: RatingCategoryCollectionViewCellDelegate {
	func ratingCategoryCollectionViewCell(_ cell: RatingCategoryCollectionViewCell, didChangeScore score: Double) {
		guard let ratingCategory = self.ratingCategory(for: cell) else { return }

		ratingCategory.attributes.score = score
		self.updateStarTranslation()
		self.updateUnsavedChangesState()
	}

	func ratingCategoryCollectionViewCell(_ cell: RatingCategoryCollectionViewCell, didChangeReview review: String) {
		guard let ratingCategory = self.ratingCategory(for: cell) else { return }

		ratingCategory.attributes.review = review.isEmpty ? nil : review
		self.updateUnsavedChangesState()
	}

	/// Returns the rating category the given cell scores.
	///
	/// - Parameter cell: The cell the user interacted with.
	private func ratingCategory(for cell: RatingCategoryCollectionViewCell) -> RatingCategory? {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let section = self.sections[safe: indexPath.section],
			case .category(let index) = section
		else { return nil }

		return self.ratingCategories[safe: index]
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ReviewEditorCollectionViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		self.presentDiscardConfirmation(showingSend: !self.isDetailed)
	}
}
