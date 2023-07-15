//
//  AchievementTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class AchievementTableViewCell: UITableViewCell, SkeletonDisplayable {
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	@IBOutlet weak var symbolImageView: ProfileImageView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using achievement: Badge?) {
		guard let achievement = achievement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary text.
		self.primaryLabel.text = achievement.attributes.name
		self.primaryLabel.textColor = UIColor(hexString: achievement.attributes.textColor)

		// Configure secondary text.
		self.secondaryLabel.text = achievement.attributes.description
		self.secondaryLabel.textColor = UIColor(hexString: achievement.attributes.textColor)

		// Configure background color.
		self.contentView.backgroundColor = UIColor(hexString: achievement.attributes.backgroundColor)

		// Configure symbol image.
		self.symbolImageView.setImage(with: achievement.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}
}
