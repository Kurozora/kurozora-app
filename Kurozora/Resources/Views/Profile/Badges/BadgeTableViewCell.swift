//
//  BadgeTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BadgeTableViewCell: UITableViewCell, SkeletonDisplayable {
	@IBOutlet weak var badgeTitleLabel: UILabel!
	@IBOutlet weak var badgeDescriptionLabel: UILabel!
	@IBOutlet weak var badgeImageView: ProfileImageView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using badge: Badge?) {
		guard let badge = badge else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Set title and text color.
		self.badgeTitleLabel.text = badge.attributes.name
		self.badgeTitleLabel.textColor = UIColor(hexString: badge.attributes.textColor)

		// Set description and text color.
		self.badgeDescriptionLabel.text = badge.attributes.description
		self.badgeDescriptionLabel.textColor = UIColor(hexString: badge.attributes.textColor)

		// Set background color.
		self.contentView.backgroundColor = UIColor(hexString: badge.attributes.backgroundColor)

		// Set badge image and border color
		self.badgeImageView.setImage(with: badge.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}
}
