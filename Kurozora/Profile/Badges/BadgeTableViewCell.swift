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

	var badge: BadgeElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let badge = badge else { return }

		if let badgeText = badge.text, !badgeText.isEmpty,
			let badgeTextColor = badge.textColor, !badgeTextColor.isEmpty,
			let badgeDescription = badge.description, !badgeDescription.isEmpty,
			let badgeBackgroundColor = badge.backgroundColor, !badgeBackgroundColor.isEmpty {

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
		self.badgeImageView.image = #imageLiteral(resourceName: "following")
	}
}
