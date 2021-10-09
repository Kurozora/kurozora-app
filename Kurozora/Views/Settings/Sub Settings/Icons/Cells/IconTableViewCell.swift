//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: SelectableSettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var iconTitleLabel: UILabel! {
		didSet {
			iconTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var alternativeIconsElement: AlternativeIconsElement! {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		self.isSelected = alternativeIconsElement.name == UserSettings.appIcon

		self.iconTitleLabel.text = alternativeIconsElement.name
		self.iconImageView?.image = UIImage(named: alternativeIconsElement.name)
	}
}
