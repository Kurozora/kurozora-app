//
//  IssueTimeoutCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class IssueTimeoutCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The user the timeout will be issued against.
	var targetUser: User!

	/// The currently selected duration.
	var selectedDuration: TimeoutDuration = .oneHour

	/// The currently selected reason.
	var selectedReason: TimeoutReason = TimeoutReason.allCases.first ?? .spam

	/// The current free-text note.
	var note: String = ""

	/// Whether the user has edited any field.
	var isEdited: Bool = false

	/// Whether a submit request is in flight.
	private var isSubmitting: Bool = false

	private var cancelBarButtonItem: UIBarButtonItem!
	private var submitBarButtonItem: UIBarButtonItem!

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self._prefersRefreshControlDisabled = true

		self.title = L10n.issueTimeout

		self.configureNavigationItems()
		self.configureSheetPresentation()

		self.navigationController?.presentationController?.delegate = self

		self.configureDataSource()
		self.updateDataSource()
		self.updateSubmitEnabled()
	}

	/// Re-evaluates whether "Submit" should be enabled.
	private func updateSubmitEnabled() {
		guard !self.isSubmitting else {
			self.submitBarButtonItem?.isEnabled = false
			return
		}

		self.submitBarButtonItem?.isEnabled = !self.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	// MARK: - Functions
	/// Installs the Cancel and Submit bar button items.
	private func configureNavigationItems() {
		self.navigationController?.navigationBar.prefersLargeTitles = false

		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
		self.submitBarButtonItem = UIBarButtonItem(title: L10n.issueTimeoutSubmit, style: .done, target: self, action: #selector(self.submitTapped))

		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		self.navigationItem.rightBarButtonItem = self.submitBarButtonItem
	}

	/// Configures the sheet's detents and grabber.
	private func configureSheetPresentation() {
		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersGrabberVisible = true
	}

	/// Returns the localized title for the given duration.
	///
	/// - Parameter duration: The duration whose title to return.
	///
	/// - Returns: The localized title.
	static func localizedTitle(for duration: TimeoutDuration) -> String {
		switch duration {
		case .oneHour: return L10n.timeoutDuration1Hour
		case .oneDay: return L10n.timeoutDuration24Hours
		case .threeDays: return L10n.timeoutDuration3Days
		case .sevenDays: return L10n.timeoutDuration7Days
		case .thirtyDays: return L10n.timeoutDuration30Days
		case .permanent: return L10n.timeoutDurationPermanent
		}
	}

	/// Returns the localized title for the given reason.
	///
	/// - Parameter reason: The reason whose title to return.
	///
	/// - Returns: The localized title.
	static func localizedTitle(for reason: TimeoutReason) -> String {
		switch reason {
		case .spam: return L10n.timeoutReasonSpam
		case .harassment: return L10n.timeoutReasonHarassment
		case .nsfw: return L10n.timeoutReasonNSFW
		case .impersonation: return L10n.timeoutReasonImpersonation
		case .hate: return L10n.timeoutReasonHate
		case .other: return L10n.timeoutReasonOther
		}
	}

	/// Builds the duration picker menu.
	///
	/// - Returns: A menu listing every preset duration.
	func makeDurationMenu() -> UIMenu {
		let actions: [UIAction] = TimeoutDuration.allCases.map { duration in
			UIAction(title: Self.localizedTitle(for: duration), state: duration == self.selectedDuration ? .on : .off) { [weak self] _ in
				guard let self = self else { return }
				guard self.selectedDuration != duration else { return }
				self.selectedDuration = duration
				self.isEdited = true
				self.refreshDurationRow()
			}
		}

		return UIMenu(title: L10n.chooseDuration, options: [.singleSelection], children: actions)
	}

	/// Builds the reason picker menu.
	///
	/// - Returns: A menu listing every reason category.
	func makeReasonMenu() -> UIMenu {
		let actions: [UIAction] = TimeoutReason.allCases.map { reason in
			UIAction(title: Self.localizedTitle(for: reason), state: reason == self.selectedReason ? .on : .off) { [weak self] _ in
				guard let self = self else { return }
				guard self.selectedReason != reason else { return }
				self.selectedReason = reason
				self.isEdited = true
				self.refreshReasonRow()
			}
		}

		return UIMenu(title: L10n.chooseReason, options: [.singleSelection], children: actions)
	}

	/// Reloads the duration row.
	private func refreshDurationRow() {
		guard var current = self.snapshot else { return }
		current.reloadItems([.durationRow])
		self.dataSource.apply(current, animatingDifferences: false)
		self.snapshot = current
	}

	/// Reloads the reason row.
	private func refreshReasonRow() {
		guard var current = self.snapshot else { return }
		current.reloadItems([.reasonRow])
		self.dataSource.apply(current, animatingDifferences: false)
		self.snapshot = current
	}

	// MARK: - Actions
	@objc private func cancelTapped() {
		self.attemptDismiss()
	}

	@objc private func submitTapped() {
		self.isSubmitting = true
		self.updateSubmitEnabled()

		Task { [weak self] in
			guard let self = self else { return }

			await self.submit()

			self.isSubmitting = false
			self.updateSubmitEnabled()
		}
	}

	/// Submits the issue-timeout request.
	@MainActor
	private func submit() async {
		let trimmedNote = self.note.trimmingCharacters(in: .whitespacesAndNewlines)
		let userIdentity = UserIdentity(id: self.targetUser.id)

		do {
			_ = try await KService.issueTimeout(
				userIdentity,
				duration: self.selectedDuration,
				reason: self.selectedReason,
				note: trimmedNote
			).response()

			NotificationCenter.default.post(name: .KUserTimeoutDidChange, object: self.targetUser.id)
			self.dismiss(animated: true)
		} catch let error as APIError {
			self.presentAlertController(title: nil, message: error.message)
		} catch {
			self.presentAlertController(title: nil, message: error.localizedDescription)
		}
	}

	/// Dismisses immediately when nothing has been edited; otherwise confirms the discard.
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
extension IssueTimeoutCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return false
	}
}

// MARK: - IssueTimeoutNoteCollectionViewCellDelegate
extension IssueTimeoutCollectionViewController: IssueTimeoutNoteCollectionViewCellDelegate {
	func issueTimeoutNoteCollectionViewCell(_ cell: IssueTimeoutNoteCollectionViewCell, didChange text: String) {
		self.note = text
		self.isEdited = true
		self.updateSubmitEnabled()
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension IssueTimeoutCollectionViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		return !self.isEdited
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		self.attemptDismiss()
	}
}
