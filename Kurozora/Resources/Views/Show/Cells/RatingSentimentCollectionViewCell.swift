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
		self.configure(symbolImage: UIImage(systemName: "star.fill"), percentage: stats.positivePercentage, sentiment: stats.sentiment)
	}

	/// Configure the cell with the favorite share of the given `MediaStat` object.
	func configureFavoriteShare(using stats: MediaStat) {
		self.configure(symbolImage: UIImage(systemName: "heart.fill"), percentage: stats.favoriteShare * 100, sentiment: stats.favoriteSentiment)
	}

	/// Configure the cell with the given symbol image, percentage and sentiment.
	private func configure(symbolImage: UIImage?, percentage: Double, sentiment: String) {
		self.symbolImageView.theme_tintColor = KThemePicker.textColor.rawValue

		self.symbolImageView.image = symbolImage

		self.primaryLabel.text = "\(percentage.rounded().withoutTrailingZeros)%"
		self.primaryLabel.font = .systemFont(ofSize: self.primaryLabel.font.pointSize, weight: .bold)

		self.secondaryLabel.text = sentiment
	}
}
