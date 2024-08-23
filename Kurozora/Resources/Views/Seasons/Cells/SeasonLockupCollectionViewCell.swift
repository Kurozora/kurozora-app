//
//  SeasonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SeasonLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var countLabel: KSecondaryLabel!
	@IBOutlet weak var startDateTitleLabel: KSecondaryLabel!
	@IBOutlet weak var episodeCountTitleLabel: KSecondaryLabel!
	@IBOutlet weak var ratingTitleLabel: KSecondaryLabel!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var firstAiredLabel: KLabel!
	@IBOutlet weak var episodeCountLabel: KLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet var separatorViewLight: [SecondarySeparatorView]?

	// MARK: - Functions
	/// Configure the cell with the season's details.
	///
	/// - Parameters:
	///	   - season: The `Season` object used to configure the cell.
	func configure(using season: Season?) {
		guard let season = season else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure poster
		self.posterImageView.setImage(with: season.attributes.poster?.url ?? "", placeholder: R.image.placeholders.showPoster()!)

		// Configure season number
		self.countLabel.text = "Season \(season.attributes.number)"

		// Configure title
		self.titleLabel.text = season.attributes.title

		// Configure premiere date
		self.firstAiredLabel.text = season.attributes.startedAt?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(season.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "\(season.attributes.ratingAverage)"
	}
}
