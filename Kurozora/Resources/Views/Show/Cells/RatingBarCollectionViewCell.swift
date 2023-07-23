//
//  RatingBarCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RatingBarCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet var symbolImageViews: [UIImageView]!
	@IBOutlet weak var primaryLabel: KSecondaryLabel!
	@IBOutlet weak var progressView1: UIProgressView!
	@IBOutlet weak var progressView2: UIProgressView!
	@IBOutlet weak var progressView3: UIProgressView!
	@IBOutlet weak var progressView4: UIProgressView!
	@IBOutlet weak var progressView5: UIProgressView!

	// MARK: - Functions
	/// Configure the cell with the given `MediaStat` object.
	func configure(using stats: MediaStat) {
		let ratingCount = 100.0 / Float(max(stats.ratingCount, 1))
		let rating1 = Float(stats.ratingCountList[8] + stats.ratingCountList[9])
		let rating2 = Float(stats.ratingCountList[6] + stats.ratingCountList[7])
		let rating3 = Float(stats.ratingCountList[4] + stats.ratingCountList[5])
		let rating4 = Float(stats.ratingCountList[2] + stats.ratingCountList[3])
		let rating5 = Float(stats.ratingCountList[0] + stats.ratingCountList[1])

		let rating1Percentage = (ratingCount * rating1).rounded()
		let rating2Percentage = (ratingCount * rating2).rounded()
		let rating3Percentage = (ratingCount * rating3).rounded()
		let rating4Percentage = (ratingCount * rating4).rounded()
		let rating5Percentage = (ratingCount * rating5).rounded()

		let rating1TooltipInteraction = UIToolTipInteraction(defaultToolTip: "\(rating1Percentage)% rated 5 stars.")
		let rating2TooltipInteraction = UIToolTipInteraction(defaultToolTip: "\(rating2Percentage)% rated 4 stars.")
		let rating3TooltipInteraction = UIToolTipInteraction(defaultToolTip: "\(rating3Percentage)% rated 3 stars.")
		let rating4TooltipInteraction = UIToolTipInteraction(defaultToolTip: "\(rating4Percentage)% rated 2 stars.")
		let rating5TooltipInteraction = UIToolTipInteraction(defaultToolTip: "\(rating5Percentage)% rated 1 star.")

		self.symbolImageViews.forEach { imageView in
			imageView.theme_tintColor = KThemePicker.textColor.rawValue
		}

		self.primaryLabel.text = "\(stats.ratingCount.formatted(.number)) Ratings"

		self.progressView1.theme_progressTintColor = KThemePicker.textColor.rawValue
		self.progressView1.theme_trackTintColor = KThemePicker.subTextColor.rawValue
		self.progressView1.setProgress(rating1Percentage / 100, animated: true)
		self.progressView1.addInteraction(rating1TooltipInteraction)

		self.progressView2.theme_progressTintColor = KThemePicker.textColor.rawValue
		self.progressView2.theme_trackTintColor = KThemePicker.subTextColor.rawValue
		self.progressView2.setProgress(rating2Percentage / 100, animated: true)
		self.progressView2.addInteraction(rating2TooltipInteraction)

		self.progressView3.theme_progressTintColor = KThemePicker.textColor.rawValue
		self.progressView3.theme_trackTintColor = KThemePicker.subTextColor.rawValue
		self.progressView3.setProgress(rating3Percentage / 100, animated: true)
		self.progressView3.addInteraction(rating3TooltipInteraction)

		self.progressView4.theme_progressTintColor = KThemePicker.textColor.rawValue
		self.progressView4.theme_trackTintColor = KThemePicker.subTextColor.rawValue
		self.progressView4.setProgress(rating4Percentage / 100, animated: true)
		self.progressView4.addInteraction(rating4TooltipInteraction)

		self.progressView5.theme_progressTintColor = KThemePicker.textColor.rawValue
		self.progressView5.theme_trackTintColor = KThemePicker.subTextColor.rawValue
		self.progressView5.setProgress(rating5Percentage / 100, animated: true)
		self.progressView5.addInteraction(rating5TooltipInteraction)
	}
}
