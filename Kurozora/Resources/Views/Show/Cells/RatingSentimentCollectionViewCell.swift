//
//  RatingSentimentCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RatingSentimentCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var symbolImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Functions
	/// Configure the cell with the given `MediaStat` object.
	func configure(using stats: MediaStat) {
		self.symbolImageView.theme_tintColor = KThemePicker.textColor.rawValue

		self.symbolImageView.image = UIImage(systemName: "star.fill")

		self.primaryLabel.text = "\(stats.highestRatingPercentage.rounded().withoutTrailingZeros)%"
		self.primaryLabel.font = .systemFont(ofSize: self.primaryLabel.font.pointSize, weight: .bold)

		self.secondaryLabel.text = stats.sentiment
	}
}
