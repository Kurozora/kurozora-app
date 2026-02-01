//
//  AchievementTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class AchievementTableViewCell: UITableViewCell, SkeletonDisplayable {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var symbolImageView: ProfileImageView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using achievement: Achievement?) {
		guard let achievement = achievement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary text.
		self.primaryLabel.text = achievement.attributes.name

		// Configure secondary text.
		self.secondaryLabel.text = achievement.attributes.description

		// Configure symbol image view.
		self.symbolImageView.layer.borderColor = UIColor(hexString: achievement.attributes.textColor)?.cgColor

		// Configure background color.
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		// Configure symbol image.
		self.symbolImageView.setImage(with: achievement.attributes.symbol?.url ?? "", placeholder: .kurozoraIcon)
	}
}
