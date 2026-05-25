//
//  ParentalGuideReportCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ParentalGuideReportCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The identity of the entry being reported.
	var entryIdentity: ParentalGuideEntryIdentity!

	/// The currently selected reason. Defaults to the first case.
	var selectedReason: ParentalGuideReportReason = ParentalGuideReportReason.allCases.first ?? .inaccurate

	/// The current free-text details.
	var details: String = ""

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

		self.title = L10n.reportParentalGuideEntry

		self.configureNavigationItems()
		self.configureSheetPresentation()

		self.configureDataSource()
		self.updateDataSource()
		self.updateSubmitEnabled()
	}

	// MARK: - Functions
	/// Installs the Cancel and Submit bar button items.
	private func configureNavigationItems() {
		self.navigationController?.navigationBar.prefersLargeTitles = false

		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
		self.submitBarButtonItem = UIBarButtonItem(title: L10n.reportSubmit, style: .done, target: self, action: #selector(self.submitTapped))

		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		self.navigationItem.rightBarButtonItem = self.submitBarButtonItem
	}

	/// Configures the sheet's detents and grabber.
	private func configureSheetPresentation() {
		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersGrabberVisible = true
	}

	/// Re-evaluates whether "Submit" should be enabled.
	func updateSubmitEnabled() {
		guard !self.isSubmitting else {
			self.submitBarButtonItem?.isEnabled = false
			return
		}

		switch self.selectedReason {
		case .other:
			let trimmed = self.details.trimmingCharacters(in: .whitespacesAndNewlines)
			self.submitBarButtonItem?.isEnabled = !trimmed.isEmpty
		default:
			self.submitBarButtonItem?.isEnabled = true
		}
	}

	// MARK: - Actions
	@objc private func cancelTapped() {
		self.dismiss(animated: true)
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

	/// Submits the report.
	@MainActor
	private func submit() async {
		guard let entryIdentity = self.entryIdentity else { return }

		let trimmedDetails = self.details.trimmingCharacters(in: .whitespacesAndNewlines)
		let detailsParameter: String? = trimmedDetails.isEmpty ? nil : trimmedDetails

		do {
			_ = try await KService.reportParentalGuideEntry(entryIdentity, reason: self.selectedReason, details: detailsParameter).response()

			NotificationCenter.default.post(name: .KPGEntryDidReport, object: nil, userInfo: ["entryID": entryIdentity.id])

			let presenter = self.presentingViewController

			self.dismiss(animated: true) {
				presenter?.presentAlertController(title: L10n.reportSuccessTitle, message: L10n.reportSuccessMessage)
			}
		} catch {
			print(error.localizedDescription)
			await self.presentErrorAlert(message: error.localizedDescription)
		}
	}

	/// Presents an error alert.
	///
	/// - Parameter message: The message body, or `nil` to omit it.
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
}

// MARK: - UICollectionViewDelegate
extension ParentalGuideReportCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return false }

		switch itemKind {
		case .reasonOption:
			return true
		case .detailsEditor:
			return false
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .reasonOption(let reason):
			collectionView.deselectItem(at: indexPath, animated: true)
			guard self.selectedReason != reason else { return }

			self.selectedReason = reason
			self.refreshReasonAndDetails()
			self.updateSubmitEnabled()
		case .detailsEditor:
			break
		}
	}

	/// Reloads the reason rows and the details editor.
	private func refreshReasonAndDetails() {
		var current = self.snapshot
		guard current != nil else { return }

		let reasonItems = ParentalGuideReportReason.allCases.map { ItemKind.reasonOption($0) }
		current?.reloadItems(reasonItems)
		current?.reloadItems([.detailsEditor])

		if let updated = current {
			self.dataSource.apply(updated, animatingDifferences: false)
			self.snapshot = updated
		}
	}
}

// MARK: - ReportDetailsTextCollectionViewCellDelegate
extension ParentalGuideReportCollectionViewController: ReportDetailsTextCollectionViewCellDelegate {
	func reportDetailsTextCollectionViewCell(_ cell: ReportDetailsTextCollectionViewCell, didChange text: String) {
		self.details = text
		self.updateSubmitEnabled()
	}
}
