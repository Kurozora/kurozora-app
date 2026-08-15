//
//  RatingStyleTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class RatingStyleTableViewController: SubSettingsViewController {
	// MARK: - Properties
	private var selectedRatingStyle: RatingStyle = UserSettings.ratingStyle

	/// The rating styles, in order of increasing detail.
	private let ratingStyles: [RatingStyle] = [.quickReaction, .standard, .detailed]

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.star
		self.headerTitle = L10n.ratingStyle
		self.headerDescription = L10n.ratingStyleHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	// MARK: - Functions
	/// Stores the given rating style locally and on the user's account.
	private func select(_ ratingStyle: RatingStyle) {
		guard ratingStyle != self.selectedRatingStyle else { return }

		let previousRatingStyle = self.selectedRatingStyle
		self.selectedRatingStyle = ratingStyle
		self.store(ratingStyle)
		self.tableView.reloadData()

		Task { [weak self] in
			guard let self = self else { return }

			do {
				_ = try await KService.updateSettings()
					.ratingStyle(ratingStyle)
					.response()
			} catch {
				print(error.localizedDescription)

				self.selectedRatingStyle = previousRatingStyle
				self.store(previousRatingStyle)
				self.tableView.reloadData()
				self.presentAlertController(title: L10n.ratingStyle, message: L10n.ratingStyleUpdateFailed)
			}
		}
	}

	/// Writes the given rating style to the settings store and announces the change.
	private func store(_ ratingStyle: RatingStyle) {
		UserSettings.set(ratingStyle.rawValue, forKey: .ratingStyle)
		NotificationCenter.default.post(name: .KSRatingStyleDidChange, object: nil)
	}
}

// MARK: - KTableViewDataSource
extension RatingStyleTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			IconTableViewCell.self,
			RatingStylePreviewTableViewCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension RatingStyleTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section) else { return 1 }

		switch Section(rawValue: contentSection) {
		case .preview:
			return 1
		default:
			return self.ratingStyles.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		if let contentSection = self.contentSection(for: indexPath.section), Section(rawValue: contentSection) == .preview {
			guard let previewTableViewCell = tableView.dequeueReusableCell(withIdentifier: RatingStylePreviewTableViewCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(RatingStylePreviewTableViewCell.reuseID)")
			}

			previewTableViewCell.delegate = self
			previewTableViewCell.configure(using: self.selectedRatingStyle)

			return previewTableViewCell
		}

		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID)")
		}

		let ratingStyle = self.ratingStyles[indexPath.row]
		iconTableViewCell.configure(title: ratingStyle.localizedName)
		iconTableViewCell.setSelected(ratingStyle == self.selectedRatingStyle)

		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section) else { return nil }

		switch Section(rawValue: contentSection) {
		case .preview:
			return L10n.preview
		default:
			return L10n.ratingStyles
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section) else { return nil }

		switch Section(rawValue: contentSection) {
		case .preview:
			return nil
		default:
			return L10n.ratingStyleFooter
		}
	}
}

// MARK: - UITableViewDelegate
extension RatingStyleTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }

		if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
			return .leastNormalMagnitude
		}

		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			Section(rawValue: contentSection) == .styles
		else { return }

		self.select(self.ratingStyles[indexPath.row])
	}
}

// MARK: - RatingStylePreviewTableViewCellDelegate
extension RatingStyleTableViewController: RatingStylePreviewTableViewCellDelegate {
	func ratingStylePreviewTableViewCellDidChangeHeight(_ cell: RatingStylePreviewTableViewCell) {
		UIView.performWithoutAnimation {
			self.tableView.performBatchUpdates(nil)
		}
	}
}

extension RatingStyleTableViewController {
	/// List of rating style table section layout kind.
	enum Section: Int, CaseIterable {
		/// The section for the available rating styles.
		case styles

		/// The section for the example of the selected style.
		case preview
	}
}
