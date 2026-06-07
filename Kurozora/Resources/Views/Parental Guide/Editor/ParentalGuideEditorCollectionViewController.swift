//
//  ParentalGuideEditorCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ParentalGuideEditorCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The media context driving the submission.
	var mediaType: ParentalGuide.MediaType?

	/// The category being edited.
	var category: ParentalGuideCategory?

	/// The user's existing entry in this category, if any.
	var existingEntry: ParentalGuideEntry?

	/// The current rating selection.
	var rating: ParentalGuideRating?

	/// The current frequency selection.
	var frequency: ParentalGuideFrequency?

	/// The current depiction selection. `nil` for categories that don't support depiction or before the user picks.
	var depiction: ParentalGuideDepiction?

	/// The current free-text reason.
	var reason: String = ""

	/// Whether the reason is flagged as a spoiler.
	var isSpoiler: Bool = false

	/// Whether the user has changed the form since opening.
	var isEdited: Bool = false

	private var cancelBarButtonItem: UIBarButtonItem!
	private var submitBarButtonItem: UIBarButtonItem!

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.seedFormState()
		self.configureNavigationItems()
		self.configureSheetPresentation()
		self.configureDataSource()
		self.updateDataSource()
	}

	// MARK: - Functions
	private func seedFormState() {
		guard let category = self.category else { return }

		if self.existingEntry == nil {
			self.title = L10n.addParentalGuideCategory(category.displayName)
		} else {
			self.title = L10n.editParentalGuideCategory(category.displayName)
		}

		if let existing = self.existingEntry {
			self.rating = existing.attributes.rating
			self.frequency = existing.attributes.frequency
			self.depiction = existing.attributes.depiction
			self.reason = existing.attributes.reason ?? ""
			self.isSpoiler = existing.attributes.isSpoiler
		} else {
			self.rating = nil
			self.frequency = nil
			self.depiction = nil
			self.reason = ""
			self.isSpoiler = false
		}
	}

	private func configureNavigationItems() {
		self.navigationController?.navigationBar.prefersLargeTitles = false

		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
		self.submitBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.submitTapped))
		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		self.navigationItem.rightBarButtonItem = self.submitBarButtonItem

		self.updateSubmitEnabled()
	}

	/// Re-evaluates whether the Save button should be enabled.
	///
	/// Save is enabled only when the rating, frequency, and (for supported categories)
	/// depiction selections have all been made by the user.
	func updateSubmitEnabled() {
		guard let category = self.category else {
			self.submitBarButtonItem?.isEnabled = false
			return
		}

		let hasRating = self.rating != nil
		let isNoneRating = self.rating == ParentalGuideRating.none
		let hasFrequency = isNoneRating || !category.supportsFrequency || self.frequency != nil
		let hasDepiction = isNoneRating || !category.supportsDepiction || self.depiction != nil

		self.submitBarButtonItem?.isEnabled = hasRating && hasFrequency && hasDepiction
	}

	private func configureSheetPresentation() {
		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersGrabberVisible = true
	}

	// MARK: - Actions
	@objc private func cancelTapped() {
		self.attemptDismiss()
	}

	@objc private func submitTapped() {
		self.submitBarButtonItem.isEnabled = false
		Task { [weak self] in
			guard let self = self else { return }
			await self.submit()
			self.submitBarButtonItem.isEnabled = true
		}
	}

	/// Posts the submit request to the server.
	private func submit() async {
		guard let mediaType = self.mediaType, let category = self.category else { return }
		guard let rating = self.rating else { return }

		let hasSeverity = rating != .none

		let payload = ParentalGuideEntryRequest(
			category: category,
			rating: rating,
			frequency: hasSeverity && category.supportsFrequency ? self.frequency : nil,
			depiction: hasSeverity && category.supportsDepiction ? self.depiction : nil,
			reason: self.reason.isEmpty ? nil : self.reason,
			isSpoiler: self.isSpoiler
		)

		do {
			let response: ParentalGuideEntryResponse

			if let existingEntry = self.existingEntry {
				let entryIdentity = ParentalGuideEntryIdentity(id: existingEntry.id)
				response = try await KService.updateParentalGuideEntry(entryIdentity, request: payload).response()
			} else {
				switch mediaType {
				case .show(let identity, _, _, _, _):
					response = try await KService.submitParentalGuideEntry(for: identity, request: payload).response()
				case .literature(let identity, _, _, _, _):
					response = try await KService.submitParentalGuideEntry(for: identity, request: payload).response()
				case .game(let identity, _, _, _, _):
					response = try await KService.submitParentalGuideEntry(for: identity, request: payload).response()
				}
			}

			guard let entry = response.data.first else {
				self.presentErrorAlert(message: L10n.parentalGuideEmptyResponse)
				return
			}

			NotificationCenter.default.post(name: .KPGEntryDidUpdate, object: nil, userInfo: ["entry": entry])
			await MainActor.run { [weak self] in
				self?.dismiss(animated: true)
			}
		} catch {
			print(error.localizedDescription)
			self.presentErrorAlert(message: error.localizedDescription)
		}
	}

	@MainActor
	private func presentErrorAlert(message: String?) {
		let alert = UIAlertController(
			title: L10n.parentalGuideErrorTitle,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: L10n.okay, style: .default))
		self.present(alert, animated: true)
	}

	private func attemptDismiss() {
		guard self.isEdited else {
			self.dismiss(animated: true)
			return
		}

		let actionSheet = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheet in
			actionSheet.addAction(UIAlertAction(title: L10n.discard, style: .destructive) { _ in
				self?.dismiss(animated: true)
			})
		}

		if let popover = actionSheet.popoverPresentationController {
			popover.barButtonItem = self.cancelBarButtonItem
		}

		self.present(actionSheet, animated: true)
	}
}

// MARK: - UICollectionViewDelegate
extension ParentalGuideEditorCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return false
	}
}

// MARK: - RatingSegmentedCollectionViewCellDelegate
extension ParentalGuideEditorCollectionViewController: RatingSegmentedCollectionViewCellDelegate {
	func ratingSegmentedCollectionViewCell(_ cell: RatingSegmentedCollectionViewCell, didSelect rating: ParentalGuideRating?) {
		self.rating = rating
		self.isEdited = true
		self.updateDataSource()
		self.updateSubmitEnabled()
	}
}

// MARK: - FrequencySegmentedCollectionViewCellDelegate
extension ParentalGuideEditorCollectionViewController: FrequencySegmentedCollectionViewCellDelegate {
	func frequencySegmentedCollectionViewCell(_ cell: FrequencySegmentedCollectionViewCell, didSelect frequency: ParentalGuideFrequency?) {
		self.frequency = frequency
		self.isEdited = true
		self.updateSubmitEnabled()
	}
}

// MARK: - DepictionSegmentedCollectionViewCellDelegate
extension ParentalGuideEditorCollectionViewController: DepictionSegmentedCollectionViewCellDelegate {
	func depictionSegmentedCollectionViewCell(_ cell: DepictionSegmentedCollectionViewCell, didSelect depiction: ParentalGuideDepiction?) {
		self.depiction = depiction
		self.isEdited = true
		self.updateSubmitEnabled()
	}
}

// MARK: - ReasonTextCollectionViewCellDelegate
extension ParentalGuideEditorCollectionViewController: ReasonTextCollectionViewCellDelegate {
	func reasonTextCollectionViewCell(_ cell: ReasonTextCollectionViewCell, didChange text: String) {
		self.reason = text
		self.isEdited = true
	}
}

// MARK: - SpoilerToggleCollectionViewCellDelegate
extension ParentalGuideEditorCollectionViewController: SpoilerToggleCollectionViewCellDelegate {
	func spoilerToggleCollectionViewCell(_ cell: SpoilerToggleCollectionViewCell, didSet isOn: Bool) {
		self.isSpoiler = isOn
		self.isEdited = true
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ParentalGuideEditorCollectionViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		return !self.isEdited
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		self.attemptDismiss()
	}
}
