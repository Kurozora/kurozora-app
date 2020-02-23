//
//  BadgeTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class BadgeTableViewCell: UITableViewCell {
	@IBOutlet weak var badgeTitleLabel: UILabel!
	@IBOutlet weak var badgeDescriptionLabel: UILabel!
	@IBOutlet weak var badgeImageView: UIImageView!

	var badgeElement: BadgeElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let badgeElement = badgeElement else { return }

		if let badgeText = badgeElement.text, !badgeText.isEmpty,
			let badgeTextColor = badgeElement.textColor, !badgeTextColor.isEmpty,
			let badgeDescription = badgeElement.description, !badgeDescription.isEmpty,
			let badgeBackgroundColor = badgeElement.backgroundColor, !badgeBackgroundColor.isEmpty {

			// Set title and text color.
			self.badgeTitleLabel.text = badgeText
			self.badgeTitleLabel.textColor = UIColor(hexString: badgeTextColor)

			// Set description and text color.
			self.badgeDescriptionLabel.text = badgeDescription
			self.badgeDescriptionLabel.textColor = UIColor(hexString: badgeTextColor)

			// Set background color.
			self.contentView.backgroundColor = UIColor(hexString: badgeBackgroundColor)
		}

		// Set badge image and border color
		self.badgeImageView.image = R.image.symbols.person_crop_circle_fill()
	}
}
