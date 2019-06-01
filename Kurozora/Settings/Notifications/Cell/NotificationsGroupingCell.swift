//
//  NotificationsGroupingCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsGroupingCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var selectedImageView: UIImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}
	@IBOutlet weak var selectedView: UIView! {
		didSet {
			self.selectedView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			self.selectedView.clipsToBounds = true
			self.selectedView.cornerRadius = 10
		}
	}

	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.selectedImageView.image = #imageLiteral(resourceName: "check")
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			} else {
				self.selectedImageView.image = nil
			}
		}
	}

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				self.selectedView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
				self.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			} else {
				self.selectedView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
				self.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			}
		}
	}
}
