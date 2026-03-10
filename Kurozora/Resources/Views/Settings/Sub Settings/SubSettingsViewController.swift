//
//  SubSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class SubSettingsViewController: KTableViewController {
	// MARK: - Properties
	// Settings header
	/// The image displayed in the settings header cell.
	var headerImage: UIImage?

	/// The title displayed in the settings header cell. Setting this enables the header.
	var headerTitle: String?

	/// The description displayed below the title in the settings header cell.
	var headerDescription: String?

	/// Whether this view controller has a settings header section.
	var hasSettingsHeader: Bool {
		return self.headerTitle != nil
	}

	/// The number of sections added by the header (0 or 1).
	var headerSectionOffset: Int {
		return self.hasSettingsHeader ? 1 : 0
	}

	/// The title label's bottom edge in the table view's content coordinate space. Computed once, constant thereafter.
	private var titleLabelBottomInContent: CGFloat?

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true
	}

	// MARK: - Functions
	/// Returns the content-relative section index, or `nil` if the section is the header section.
	func contentSection(for section: Int) -> Int? {
		guard !self.hasSettingsHeader || section > 0 else { return nil }
		return section - self.headerSectionOffset
	}

	/// Dequeues and configures a `SettingsHeaderCell` for section 0.
	///
	/// Returns `nil` if the header is not configured or the index path is not the header section.
	func settingsHeaderCell(for tableView: UITableView, at indexPath: IndexPath) -> SettingsHeaderCell? {
		guard self.hasSettingsHeader, indexPath.section == 0 else { return nil }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsHeaderCell.self, for: indexPath) else { return nil }
		cell.configure(image: self.headerImage, title: self.headerTitle ?? "", description: self.headerDescription ?? "")
		return cell
	}
}

// MARK: - KTableViewDataSource
extension SubSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		var cells = super.registerCells(for: tableView)
		if self.hasSettingsHeader {
			cells.append(SettingsHeaderCell.self)
		}
		return cells
	}
}

// MARK: - UITableViewDelegate
extension SubSettingsViewController {
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			headerView.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let selectableSettingsCell = tableView.cellForRow(at: indexPath) as? SelectableSettingsCell {
			selectableSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			selectableSettingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			selectableSettingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			selectableSettingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let selectableSettingsCell = tableView.cellForRow(at: indexPath) as? SelectableSettingsCell {
			selectableSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			selectableSettingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			selectableSettingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			selectableSettingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
}

// MARK: - UIScrollViewDelegate
extension SubSettingsViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard self.hasSettingsHeader else { return }

		// Lazily compute the threshold once the header cell is visible, laid out, and in a window.
		if self.titleLabelBottomInContent == nil,
		   let headerCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsHeaderCell,
		   headerCell.primaryLabel.bounds.height > 0,
		   headerCell.window != nil {
			let labelFrame = headerCell.primaryLabel.convert(headerCell.primaryLabel.bounds, to: self.tableView)
			self.titleLabelBottomInContent = labelFrame.maxY
		}

		guard let threshold = self.titleLabelBottomInContent else { return }

		// The content-space Y of the top visible edge, accounting for the nav bar inset.
		let visibleTop = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
		let shouldShowTitle = visibleTop >= threshold

		if shouldShowTitle, self.title == nil {
			self.title = self.headerTitle
		} else if !shouldShowTitle, self.title != nil {
			self.title = nil
		}
	}
}
