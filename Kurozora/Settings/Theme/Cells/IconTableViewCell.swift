//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell {
	@IBOutlet weak var iconTitleLabel: UILabel! {
		didSet {
			iconTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var selectedView: UIView! {
		didSet {
			selectedView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	var alternativeIconsElement: AlternativeIconsElement? {
		didSet {
			setup()
		}
	}

	fileprivate func setup() {
		guard let alternativeIconsElement = alternativeIconsElement else { return }

		iconTitleLabel.text = alternativeIconsElement.name
		if let imageString = alternativeIconsElement.image {
			iconImageView.image = UIImage(named: imageString)
		}
	}
}
