//
//  ReportCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReportCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The content the report is filed against.
	var subject: ReportSubject!

	/// The currently selected reason.
	var selectedOption: ReportOption?

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

		self.title = self.subject?.navigationTitle
		self.selectedOption = self.selectedOption ?? self.subject?.options.first

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
		guard !self.isSubmitting, let selectedOption = self.selectedOption else {
			self.submitBarButtonItem?.isEnabled = false
			return
		}

		guard selectedOption.requiresDetails else {
			self.submitBarButtonItem?.isEnabled = true
			return
		}

		let trimmed = self.details.trimmingCharacters(in: .whitespacesAndNewlines)
		self.submitBarButtonItem?.isEnabled = !trimmed.isEmpty
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
		guard let subject = self.subject, let selectedOption = self.selectedOption else { return }

		let trimmedDetails = self.details.trimmingCharacters(in: .whitespacesAndNewlines)
		let detailsParameter: String? = trimmedDetails.isEmpty ? nil : trimmedDetails

		do {
			try await subject.submit(option: selectedOption, details: detailsParameter)

			let presenter = self.presentingViewController

			self.dismiss(animated: true) {
				presenter?.presentAlertController(title: subject.successTitle, message: subject.successMessage)
			}
		} catch let error as APIError {
			print(error.localizedDescription)
			self.presentErrorAlert(message: error.message)
		} catch {
			print(error.localizedDescription)
			self.presentErrorAlert(message: error.localizedDescription)
		}
	}

	/// Presents an error alert.
	///
	/// - Parameter message: The message body.
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
extension ReportCollectionViewController {
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
		case .reasonOption(let option):
			collectionView.deselectItem(at: indexPath, animated: true)
			guard self.selectedOption != option else { return }

			self.selectedOption = option
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

		let reasonItems = (self.subject?.options ?? []).map { ItemKind.reasonOption($0) }
		current?.reloadItems(reasonItems)
		current?.reloadItems([.detailsEditor])

		if let updated = current {
			self.dataSource.apply(updated, animatingDifferences: false)
			self.snapshot = updated
		}
	}
}

// MARK: - ReportDetailsTextCollectionViewCellDelegate
extension ReportCollectionViewController: ReportDetailsTextCollectionViewCellDelegate {
	func reportDetailsTextCollectionViewCell(_ cell: ReportDetailsTextCollectionViewCell, didChange text: String) {
		self.details = text
		self.updateSubmitEnabled()
	}
}
