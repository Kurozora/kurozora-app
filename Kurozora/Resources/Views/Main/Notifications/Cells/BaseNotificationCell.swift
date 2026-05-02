//
//  BaseNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseNotificationCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var notificationTypeLabel: KSecondaryLabel!
	@IBOutlet weak var dateLabel: KSecondaryLabel!
	@IBOutlet weak var contentLabel: KLabel!
	@IBOutlet weak var readStatusImageView: KImageView!

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .default
		self.theme_tintColor = KThemePicker.tintColor.rawValue
		self.configureSelectionBackground()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		self.applySelectionAppearance(selected: selected)
	}

	// MARK: - Functions
	/// Configures the cell with the given user notification.
	///
	/// - Parameter userNotification: The notification to render.
	func configureCell(using userNotification: UserNotification) {
		self.dateLabel.text = userNotification.attributes.createdAt.relativeToNow
		self.contentLabel.text = userNotification.attributes.description
		self.notificationTypeLabel.text = userNotification.attributes.type.stringValue.uppercased()
		self.readStatusImageView.isHidden = userNotification.attributes.readStatus == .read
	}

	/// Applies a transient highlight appearance for tap interactions outside batch-edit mode.
	///
	/// - Parameter highlighted: A boolean value that indicates whether the cell is highlighted.
	func applyHighlightedAppearance(highlighted: Bool) {
		self.applySelectionAppearance(selected: highlighted)
	}

	/// Configures the selection background.
	private func configureSelectionBackground() {
		let backgroundView = UIView()
		backgroundView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.backgroundView = backgroundView

		let selectedBackgroundView = UIView()
		selectedBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		self.selectedBackgroundView = selectedBackgroundView

		let multipleSelectionBackgroundView = UIView()
		multipleSelectionBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		self.multipleSelectionBackgroundView = multipleSelectionBackgroundView
	}

	/// Applies the selected or default appearance to the cell's foreground content.
	///
	/// - Parameter selected: A boolean value that indicates whether the cell is selected.
	private func applySelectionAppearance(selected: Bool) {
		self.contentView.theme_backgroundColor = selected
			? KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			: KThemePicker.tableViewCellBackgroundColor.rawValue

		let titleColorKey = selected
			? KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			: KThemePicker.tableViewCellTitleTextColor.rawValue
		let subTextColorKey = selected
			? KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			: KThemePicker.tableViewCellSubTextColor.rawValue

		self.contentLabel.theme_textColor = titleColorKey
		self.notificationTypeLabel.theme_textColor = subTextColorKey
		self.dateLabel.theme_textColor = subTextColorKey

		(self as? BasicNotificationCell)?.chevronImageView.theme_tintColor = selected
			? KThemePicker.tableViewCellSelectedChevronColor.rawValue
			: KThemePicker.tableViewCellChevronColor.rawValue
		(self as? IconNotificationCell)?.titleLabel.theme_textColor = selected
			? KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			: KThemePicker.tableViewCellTitleTextColor.rawValue
	}
}
