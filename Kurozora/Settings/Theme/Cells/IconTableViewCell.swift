//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: SelectableSettingsCell {
	@IBOutlet weak var iconTitleLabel: UILabel! {
		didSet {
			iconTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var iconImageView: UIImageView!

	var alternativeIconsElement: AlternativeIconsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let alternativeIconsElement = alternativeIconsElement else { return }
		let selected = UserSettings.appIcon

		iconTitleLabel.text = alternativeIconsElement.name
		if let imageString = alternativeIconsElement.image {
			iconImageView.image = UIImage(named: imageString)

			if imageString == selected {
				isSelected = true
			}
		}
	}
}
