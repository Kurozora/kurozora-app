//
//  ReviewTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
import IQKeyboardManagerSwift
#endif
import KurozoraKit
import UIKit

protocol ReviewTextEditorViewControllerDelegate: AnyObject {
	func reviewTextEditorViewControllerDidSubmitReview()
	func reviewTextEditorViewControllerDidDeleteReview()
}

extension ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidDeleteReview() {}
}

final class ReviewTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet private var sceneView: ReviewTextEditorView!

	// MARK: - Properties
	/// The model being rated/reviewed.
	var kind: ReviewKind?

	/// The current rating value.
	var rating: Double?

	/// The current review text.
	var review: String?

	/// Whether the user has edited the rating or review since presentation.
	private var isEdited: Bool = false

	private var cancelBarButtonItem: UIBarButtonItem!
	private var sendBarButtonItem: UIBarButtonItem!
	private var deleteBarButtonItem: UIBarButtonItem!

	weak var delegate: ReviewTextEditorViewControllerDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sceneView.delegate = self

		self.title = L10n.writeAReview

		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
		self.sheetPresentationController?.prefersGrabberVisible = true

		self.configureNavigationItems()

		let existing = self.rating ?? 0.0
		let displayedRating = existing > 0 ? existing : 1.0
		self.sceneView.configure(rating: displayedRating, review: self.review)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = false
		#endif
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Preload the off-topic classifier
		OffTopicContentFilter.shared.prewarm()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		self.updateUnsavedChangesState()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		#endif
	}

	// MARK: - Functions
	private func configureNavigationItems() {
		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonPressed(_:)))
		self.sendBarButtonItem = UIBarButtonItem(title: L10n.send, style: .done, target: self, action: #selector(self.sendButtonPressed(_:)))
		self.deleteBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(self.deleteButtonPressed(_:)))
		self.deleteBarButtonItem.tintColor = .systemRed

		let existingRating = self.rating ?? 0

		if existingRating > 0 {
			self.navigationItem.leftBarButtonItems = [self.cancelBarButtonItem, self.deleteBarButtonItem]
		} else {
			self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		}

		self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
	}

	private func updateUnsavedChangesState() {
		self.navigationItem.rightBarButtonItem?.isEnabled = self.isEdited
		self.isModalInPresentation = self.isEdited
	}

	// MARK: - Actions
	@objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
		if self.isEdited {
			self.presentDiscardConfirmation(showingSend: false)
		} else {
			self.dismiss(animated: true)
		}
	}

	@objc private func deleteButtonPressed(_ sender: UIBarButtonItem) {
		self.presentDeleteRatingConfirmation(restoringOnCancel: false)
	}

	@objc private func sendButtonPressed(_ sender: UIBarButtonItem) {
		let reviewText = self.review ?? ""
		sender.isEnabled = false

		Task { @MainActor [weak self] in
			guard let self = self else { return }

			if await OffTopicContentFilter.shared.isOffTopicSourceSeeking(reviewText) {
				self.sendBarButtonItem.isEnabled = true
				self.presentOffTopicWarning()
				return
			}

			await self.performSubmit()
		}
	}

	/// Presents the shared delete-rating confirmation dialog.
	///
	/// - Parameter restoringOnCancel: When `true`, cosmos view snaps back to the previously stored rating on cancel.
	private func presentDeleteRatingConfirmation(restoringOnCancel: Bool) {
		let previousRating = self.rating
		let previousReview = self.review

		self.confirmDeleteRating(onConfirm: { [weak self] in
			guard let self = self else { return }
			self.performDeleteRating()
		}, onCancel: { [weak self] in
			guard let self = self else { return }

			if restoringOnCancel {
				let rating = (previousRating ?? 0) > 0 ? (previousRating ?? 0) : 1.0
				self.sceneView.configure(rating: rating, review: previousReview)
			}
		})
	}

	private func performDeleteRating() {
		guard let kind = self.kind else { return }

		Task { [weak self] in
			guard let self = self else { return }

			do throws(APIError) {
				let didDelete = try await kind.deleteRating()

				guard didDelete else {
					self.presentAlertController(title: L10n.ratingFailed, message: "Not available yet for this type.")
					return
				}

				self.delegate?.reviewTextEditorViewControllerDidDeleteReview()
				self.dismiss(animated: true)
			} catch {
				self.presentAlertController(title: L10n.ratingFailed, message: error.message)
			}
		}
	}

	/// Presents the off-topic content warning.
	///
	/// Cancel returns the user to the editor; "View Guidelines" opens the community
	/// guidelines page and keeps the editor open; "Post Anyway" dispatches the
	/// existing submission path unchanged.
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

	/// Presents the "discard changes" action sheet.
	///
	/// - Parameter showingSend: When `true`, the sheet offers a "Send" action in addition to discard.
	private func presentDiscardConfirmation(showingSend: Bool) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
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
			popoverController.barButtonItem = self.navigationItem.leftBarButtonItem
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Submits the rating and review to the backend.
	@MainActor
	private func performSubmit() async {
		let existing = self.rating ?? 0.0
		let rating = existing > 0 ? existing : 1.0

		guard let kind = self.kind else {
			self.presentAlertController(title: L10n.cantSaveReview, message: "No review kind was specified. Bad developer :O")
			self.sendBarButtonItem.isEnabled = true
			return
		}

		do throws(APIError) {
			let didSubmit = try await kind.rate(using: rating, description: self.review)

			guard didSubmit else {
				self.presentAlertController(title: L10n.cantSaveReview, message: nil)
				self.sendBarButtonItem.isEnabled = true
				return
			}

			self.dismiss(animated: true) {
				self.delegate?.reviewTextEditorViewControllerDidSubmitReview()
			}
		} catch {
			print(error.localizedDescription)
			self.presentAlertController(title: L10n.cantSaveReview, message: error.message)
			self.sendBarButtonItem.isEnabled = true
		}
	}
}

// MARK: - ReviewTextEditorViewDelegate
extension ReviewTextEditorViewController: ReviewTextEditorViewDelegate {
	func reviewTextEditorView(_ view: ReviewTextEditorView, rateWith rating: Double) {
		if rating == 0 {
			self.presentDeleteRatingConfirmation(restoringOnCancel: true)
			return
		}

		self.isEdited = true
		self.rating = rating
		self.updateUnsavedChangesState()
	}

	func reviewTextEditorView(_ view: ReviewTextEditorView, textDidChange text: String) {
		self.isEdited = true
		self.review = text
		self.updateUnsavedChangesState()
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ReviewTextEditorViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		self.presentDiscardConfirmation(showingSend: true)
	}
}
