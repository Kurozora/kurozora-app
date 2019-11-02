//
//  BrowserSettingsTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BrowserSettingsTableViewCell: SelectableSettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryTitleLabel: UILabel! {
		didSet {
			primaryTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var browser: KBrowser? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		guard let browser = browser else { return }
		let selected = UserSettings.defaultBrowser

		primaryTitleLabel.text = browser.stringValue
		iconImageView?.image = browser.image

		if browser.rawValue == selected {
			isSelected = true
		}
	}
}
