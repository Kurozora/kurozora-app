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
	@IBOutlet weak var progressView1: KProgressView!
	@IBOutlet weak var progressView2: KProgressView!
	@IBOutlet weak var progressView3: KProgressView!
	@IBOutlet weak var progressView4: KProgressView!
	@IBOutlet weak var progressView5: KProgressView!

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

		self.primaryLabel.text = L10n.ratingsCount(stats.ratingCount.formatted(.number), count: stats.ratingCount)

		let progressViews = [
			(self.progressView1, rating1Percentage, rating1TooltipInteraction),
			(self.progressView2, rating2Percentage, rating2TooltipInteraction),
			(self.progressView3, rating3Percentage, rating3TooltipInteraction),
			(self.progressView4, rating4Percentage, rating4TooltipInteraction),
			(self.progressView5, rating5Percentage, rating5TooltipInteraction)
		]

		for (progressView, percentage, tooltip) in progressViews {
			progressView?.theme_progressTintColor = KThemePicker.textColor.rawValue
			progressView?.theme_trackTintColor = KThemePicker.subTextColor.rawValue
			progressView?.accessibilityValue = tooltip.defaultToolTip
			progressView?.setProgress(percentage / 100, animated: true)
			progressView?.addInteraction(tooltip)
		}
	}
}
